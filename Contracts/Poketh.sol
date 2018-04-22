pragma solidity ^ 0.4.20;

contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns(uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns(uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns(uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns(uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract ERC20Basic {
  function totalSupply() public view returns(uint256);

  function transfer(address to, uint256 value) public returns(bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => mapping(uint256 => bool)) balances;
  uint256 totalSupply_;

  function totalSupply() public view returns(uint256) {
    return totalSupply_;
  }

}



contract ERC891 is Ownable, ERC20Basic, BasicToken {
  event Mine(address indexed to, uint256 amount);
  event MiningFinished();

  bool public miningFinished = false;

  mapping(address => bool) claimed;
  mapping(uint64 => uint8) lookup;
  mapping(uint64 => uint8) acc;
  
  uint64[151] public rewardItemMapping;

  modifier canMine {
    require(!miningFinished);
    _;
  }

  function ERC891() public {
    lookup[15] = 52;
    lookup[13] = 14;
    lookup[12] = 8;
    lookup[11] = 12;
    lookup[10] = 10;
    lookup[9]  = 3;
    lookup[8]  = 4;
    lookup[8]  = 10;
    lookup[7]  = 7;
    lookup[6]  = 31;

    acc[15] = 0;
    acc[13] = acc[15] + lookup[15];
    acc[12] = acc[13] + lookup[13];
    acc[11] = acc[12] + lookup[12];
    acc[10] = acc[11] + lookup[11];
    acc[9]  = acc[10] + lookup[10];
    acc[8]  = acc[9]  + lookup[9];
    acc[8]  = acc[8]  + lookup[8];
    acc[7]  = acc[8]  + lookup[8];
    acc[6]  = acc[7]  + lookup[7];
    
    rewardItemMapping=[16,17,19,20,21,22,23,27,28,29,30,32,33,39,41,42,43,44,46,47,48,49,50,52,54,55,56,60,66,67,69,70,72,73,74,75,79,80,81,84,85,86,88,96,98,100,116,118,129,130,11,14,24,51,53,57,82,87,97,99,101,109,114,119,35,37,71,83,89,92,95,117,12,15,40,45,58,61,64,68,77,93,102,111,25,26,62,63,104,105,108,110,112,128,78,120,124,36,90,91,132,106,107,113,115,122,123,126,127,147,148,1,4,7,125,131,133,143,2,3,5,6,8,9,18,31,34,38,59,65,76,94,103,121,134,135,136,137,138,139,140,141,142,144,145,146,149,150,151];
  }

  function claim() canMine public {
    require(!claimed[msg.sender]);
    uint256 reward = checkFind();
    require(reward != 9000);
    
    claimed[msg.sender] = true;
    balances[msg.sender][reward] = true;
  }


  function checkFind() view public returns(uint64) {
    uint64 bitCount = 0;
    bytes8 dataS = bytes8(msg.sender);
    bytes8 data = bytes8(msg.sender) & ((1 << 52) - 1);

    while (data != 0) {
      bitCount = bitCount + uint64(data & 1);
      data = data >> 1;
    }

    uint64 code = uint64(dataS >> 58);
    return bitCount < 16 ? code % lookup[bitCount] + acc[bitCount] : 9000;

  }

  function checkFindAny(address a) view public returns(uint64) {
    uint64 bitCount = 0;
    bytes8 dataS = bytes8(a);
    bytes8 data = bytes8(a) & ((1 << 52) - 1);

    while (data != 0) {
      bitCount = bitCount + uint64(data & 1);
      data = data >> 1;
    }

    uint64 code = uint64(dataS >> 58);
    return bitCount < 16 ? code % lookup[bitCount] + acc[bitCount] : 9000;

  }


  function transfer(address _to, uint256 _value) public returns(bool) {
    require(_to != address(0));
    require((!claimed[msg.sender]));

    if (!claimed[msg.sender]) claim();

    balances[msg.sender][_value] = false;
    balances[_to][_value] = true;
    emit Transfer(msg.sender, _to, _value);
    return true;
  }


}

contract Poketh is ERC891 {

  function Poketh() public {

  }

}
