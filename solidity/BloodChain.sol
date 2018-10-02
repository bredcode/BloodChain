pragma solidity ^0.4.19;
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

    struct user{
        address addr;
        string name;
        string sex;
        string country;
        uint birth;
        bloodDonationCard[] cardList;
    }
    struct bloodDonationHouse{
        address addr;
        string name;
        string location;
        string phoneNumber;
        string country;
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
    mapping(address => addrPairInfo) addrInfoMap;
    mapping(uint => user) userMap;
    mapping(uint => bloodDonationHouse) bloodDonationHouseMap;
    mapping(uint => hospital) hospitalMap;
    function createUser(address _addr, string _name, string _sex, string _country, uint _birth) public {
        addrInfoMap[_addr].idx = idx;
        addrInfoMap[_addr].state = 1;

        userMap[idx].addr = _addr;
        userMap[idx].name = _name;
        userMap[idx].sex = _sex;
        userMap[idx].country = _country;
        userMap[idx].birth = _birth;

        idx++;
    }
    function createBloodDonationHouse(address _addr, string _name, string _location, string _phoneNumber, string _country) public {
        addrInfoMap[_addr].idx = idx;
        addrInfoMap[_addr].state = 2;

        bloodDonationHouseMap[idx].addr = _addr;
        bloodDonationHouseMap[idx].name = _name;
        bloodDonationHouseMap[idx].location = _location;
        bloodDonationHouseMap[idx].phoneNumber = _phoneNumber;
        bloodDonationHouseMap[idx].country = _country;

        idx++;
    }
    function createHospital(address _addr, string _name, string _location, string _phoneNumber, string _country) public {
        addrInfoMap[_addr].idx = idx;
        addrInfoMap[_addr].state = 3;

        hospitalMap[idx].addr = _addr;
        hospitalMap[idx].name = _name;
        hospitalMap[idx].location = _location;
        hospitalMap[idx].phoneNumber = _phoneNumber;
        hospitalMap[idx].country = _country;

        idx++;
    }
    function getUserCardList(address _addr) public view returns (string[], string[], string[], uint[]){
        addrPairInfo memory addrInfo = addrInfoMap[_addr];
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