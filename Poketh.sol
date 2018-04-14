pragma solidity ^0.4.20;

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


contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

}

contract ERC20 is ERC20Basic {
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract ERC891 is Ownable, ERC20, BasicToken {
  event Mine(address indexed to, uint256 amount);
  event MiningFinished();

  bool public miningFinished = false;
  mapping(address => bool) claimed;


  modifier canMine {
    require(!miningFinished);
    _;
  }

  
  function claim() canMine public {
    require(!claimed[msg.sender]);
    bytes20 reward = bytes20(msg.sender) & 255;
    require(reward > 0);
    uint256 rewardInt = uint256(reward);
    
    claimed[msg.sender] = true;
    totalSupply_ = totalSupply_.add(rewardInt);
    balances[msg.sender] = balances[msg.sender].add(rewardInt);
    emit Mine(msg.sender, rewardInt);
  }
  
  function claimAndTransfer(address _owner) canMine public {
    require(!claimed[msg.sender]);
    bytes20 reward = bytes20(msg.sender) & 255;
    require(reward > 0);
    uint256 rewardInt = uint256(reward);
    
    claimed[msg.sender] = true;
    totalSupply_ = totalSupply_.add(rewardInt);
    balances[_owner] = balances[_owner].add(rewardInt);
    emit Mine(msg.sender, rewardInt);
    emit Transfer(address(0), _owner, rewardInt);
  }
  
  
  function checkReward() view public returns(uint256){
    uint8 bitCount = 0;
    bytes8 dataS = bytes8(msg.sender);
    bytes8 data = bytes8(msg.sender) & ((1 << 52) - 1);
    
    while(data != 0){
        bitCount = bitCount + uint8(data & 1);
        data = data >> 1;
    }
    
    return bitCount == 15 ? uint64(dataS >> 58) % 52 : 9000;

  }
  
  
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender] ||
           (!claimed[msg.sender] && _value <= balances[msg.sender] + uint256(bytes20(msg.sender) & 255))
           );

    if(!claimed[msg.sender]) claim();

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner] + (claimed[_owner] ? 0 : uint256(bytes20(_owner) & 255));
  }
}

contract Poketh is ERC891 {

    function Poketh() public{
    
    }

}
