pragma solidity ^0.4.22;
pragma experimental ABIEncoderV2;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract BloodChain {
    using SafeMath for uint256;

    struct bloodDonationCard{
        string serialNumber;
        string bloodType;
        string sex;
        uint donationDay;
    }
    struct questionnaire{
        address addr;
        string age;
        string name;
        string sex;
        string residentRegistrationNumber;
        bool canBloodDonation;
        /* Delete the annotations in the full version */
        // bool areYouWell;
        // bool vaccinationIn3Month;
        // bool takenMedicineIn3Month;
        // bool malariaZone;
    }
    struct user{
        address addr;
        string name;
        string sex;
        string country;
        uint birth;
        bloodDonationCard[] cardList;
        questionnaire userQuestionnaire;
    }
    struct bloodDonationHouse{
        address addr;
        string name;
        string location;
        string phoneNumber;
        string country;
        questionnaire[] questionnaireList;
    }
    struct hospital{
        address addr;
        string name;
        string location;
        string phoneNumber;
        string country;
    }

    struct addrPairInfo{
        uint idx;
        uint state; // 1 : 헌혈자 2 : 헌혈의집 3 : 병원
    }

    uint idx = 0;
    uint userCnt = 0;
    uint bloodDonationHouseCnt = 0;
    uint hospitalCnt = 0;

    mapping(address => addrPairInfo) addrInfoMap;
    mapping(uint => user) userMap;
    mapping(uint => bloodDonationHouse) bloodDonationHouseMap; // idx를 통해 헌혈의집 변환
    mapping(uint => hospital) hospitalMap; // idx를 통해 병원을 변환
    mapping(string => uint) bloodDonationHouseConvertStringToUint; // 헌혈의집 이름을 받으면 idx로 변환

    function createUser(string _name, string _sex, string _country, uint _birth) public {
        addrInfoMap[msg.sender].idx = idx;
        addrInfoMap[msg.sender].state = 1;

        userMap[idx].addr = msg.sender;
        userMap[idx].name = _name;
        userMap[idx].sex = _sex;
        userMap[idx].country = _country;
        userMap[idx].birth = _birth;

        idx++;
        userCnt++;
    }
    function createBloodDonationHouse(string _name, string _location, string _phoneNumber, string _country) public {
        addrInfoMap[msg.sender].idx = idx;
        addrInfoMap[msg.sender].state = 2;

        bloodDonationHouseMap[idx].addr = msg.sender;
        bloodDonationHouseMap[idx].name = _name;
        bloodDonationHouseMap[idx].location = _location;
        bloodDonationHouseMap[idx].phoneNumber = _phoneNumber;
        bloodDonationHouseMap[idx].country = _country;
        bloodDonationHouseConvertStringToUint[_name] = idx;

        idx++;
        bloodDonationHouseCnt++;
    }
    function createHospital(string _name, string _location, string _phoneNumber, string _country) public {
        addrInfoMap[msg.sender].idx = idx;
        addrInfoMap[msg.sender].state = 3;

        hospitalMap[idx].addr = msg.sender;
        hospitalMap[idx].name = _name;
        hospitalMap[idx].location = _location;
        hospitalMap[idx].phoneNumber = _phoneNumber;
        hospitalMap[idx].country = _country;

        idx++;
        hospitalCnt++;
    }

    function createQuestionnaire(
        string _bloodDonationHouseName, string _age, string _residentRegistrationNumber) public {
        addrPairInfo memory addrInfo = addrInfoMap[msg.sender];
        require(
            addrInfo.state == 1,
            "Questionnaire makes blood donator only"
        );
        require(
            bloodDonationHouseCnt >= 1,
            "BloodDonationHouse is empty"
        );
        /*
            만약 문진표 한번만 제출해야한다면 이 require을 사용한다.
            하지만 현재 무슨 이유인지 모르겠지만 addr != msg.sender인데도 require에 걸린다.
            require(
                userMap[addrInfo.idx].userQuestionnaire.addr == msg.sender,
                "Questionnaire is already exist"
            );
        */
        uint mapIdx = bloodDonationHouseConvertStringToUint[_bloodDonationHouseName];
        questionnaire memory card;
        card.addr = msg.sender;
        card.age = _age;
        card.name = userMap[addrInfo.idx].name;
        card.sex = userMap[addrInfo.idx].sex;
        card.residentRegistrationNumber = _residentRegistrationNumber;
        card.canBloodDonation = false;

        bloodDonationHouseMap[mapIdx].questionnaireList.push(card);

        userMap[addrInfo.idx].userQuestionnaire = card;
    }

    // 문진표를 확인한다.
    function getQuestionnaire() public view returns (address[], string[], string[], string[], string[], bool[]){
        addrPairInfo memory addrInfo = addrInfoMap[msg.sender];
        require(
            addrInfo.state == 1 || addrInfo.state == 2,
            "Blood donator and blood donation house only"
        );

        address[] memory addresses;
        string[] memory ages;
        string[] memory names;
        string[] memory sexes;
        string[] memory residentRegistrationNumbers;
        bool[] memory canBloodDonations;
        // 헌혈자면
        if(addrInfo.state == 1){
            addresses = new address[](1);
            ages = new string[](1);
            names = new string[](1);
            sexes = new string[](1);
            residentRegistrationNumbers = new string[](1);
            canBloodDonations = new bool[](1);

            addresses[0] = userMap[addrInfo.idx].userQuestionnaire.addr;
            ages[0] = userMap[addrInfo.idx].userQuestionnaire.age;
            names[0] = userMap[addrInfo.idx].userQuestionnaire.name;
            sexes[0] = userMap[addrInfo.idx].userQuestionnaire.sex;
            residentRegistrationNumbers[0] = userMap[addrInfo.idx].userQuestionnaire.residentRegistrationNumber;
            canBloodDonations[0] = userMap[addrInfo.idx].userQuestionnaire.canBloodDonation;
            
            return (addresses, ages, names, sexes, residentRegistrationNumbers, canBloodDonations);
        }
        // 헌혈의집이면
        else if(addrInfo.state == 2){
            uint len = bloodDonationHouseMap[addrInfo.idx].questionnaireList.length;
            addresses = new address[](len);
            ages = new string[](len);
            names = new string[](len);
            sexes = new string[](len);
            residentRegistrationNumbers = new string[](len);
            canBloodDonations = new bool[](len);

            for(uint i = 0 ; i < len ; i++){
                addresses[i] = bloodDonationHouseMap[addrInfo.idx].questionnaireList[i].addr;
                ages[i] = bloodDonationHouseMap[addrInfo.idx].questionnaireList[i].age;
                names[i] = bloodDonationHouseMap[addrInfo.idx].questionnaireList[i].name;
                sexes[i] = bloodDonationHouseMap[addrInfo.idx].questionnaireList[i].sex;
                residentRegistrationNumbers[i] = bloodDonationHouseMap[addrInfo.idx].questionnaireList[i].residentRegistrationNumber;
                canBloodDonations[i] = bloodDonationHouseMap[addrInfo.idx].questionnaireList[i].canBloodDonation;
            }

            return (addresses, ages, names, sexes, residentRegistrationNumbers, canBloodDonations);
        }
    }

    // 문진표를 검수하고 헌혈 여부를 알려준다.
    function setQuestionnaire(uint _idx, bool _canBloodDonation) public {
        addrPairInfo memory addrInfo = addrInfoMap[msg.sender];
        require(
            addrInfo.state == 2,
            "Questionnaire inspection is only available for blood donation house"
        );

        bloodDonationHouseMap[addrInfo.idx].questionnaireList[_idx].canBloodDonation = _canBloodDonation;
        address userAddr = bloodDonationHouseMap[addrInfo.idx].questionnaireList[_idx].addr;
        addrPairInfo memory userAddrInfo = addrInfoMap[userAddr];
        userMap[userAddrInfo.idx].userQuestionnaire.canBloodDonation = _canBloodDonation;
    }

    function getUserCardList() public view returns (string[], string[], string[], uint[]){
        addrPairInfo memory addrInfo = addrInfoMap[msg.sender];
        require(
            addrInfo.state == 1,
            "Blood donation card list can see blood donator only"
        );
        uint len = userMap[addrInfo.idx].cardList.length;

        string[] memory serialNumbers = new string[](len);
        string[] memory bloodTypes = new string[](len);
        string[] memory sexs = new string[](len);
        uint[] memory donationDays = new uint[](len);

        for(uint i = 0; i < len; i++){
            bloodDonationCard memory card = userMap[addrInfo.idx].cardList[i];
            serialNumbers[i] = card.serialNumber;
            bloodTypes[i] = card.bloodType;
            sexs[i] = card.sex;
            donationDays[i] = card.donationDay;
        }

        return (serialNumbers, bloodTypes, sexs, donationDays);
    }
}