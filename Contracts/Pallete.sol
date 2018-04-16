pragma solidity ^ 0.4.21;

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

contract Pallete is Ownable {
  mapping(uint64 => uint64) colors;
  uint64 internal idx;

  function Pallete() public {

    colors[51] = 0xDE161D;
    colors[52] = 0xF79C2E;
    colors[53] = 0xFEEDCE;
    colors[54] = 0xEDC58D;
    colors[55] = 0xE55F32;
    colors[56] = 0xB08A4A;
    colors[57] = 0x216B65;
    colors[58] = 0x2DA37E;
    colors[59] = 0x805B4A;
    
    
/* ----------------
    Pallete HEX
    
    DE161D 51
    F79C2E 52
    FEEDCE 53 
    EDC58D 54
    E55F32 55

    B08A4A 56 
    216B65 57
    2DA37E 58 

    805B4A 59
---------------- */
    
    idx = 59;
  }
  
  function addColor(uint64 _c) public onlyOwner {
    idx = idx + 1;
    colors[idx] = _c;
  }
  
  function editColor(uint64 _idx, uint64 _c) public onlyOwner {
    colors[_idx] = _c;
  }
  
  
  function getColor(uint64 _idx) public view returns(uint64) {
    return colors[_idx];
  }
}
