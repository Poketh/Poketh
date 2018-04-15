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
    colors[1] = 0xEDE9E8;
    colors[2] = 0xEDDFED;
    colors[3] = 0xEBEADD;
    colors[4] = 0xEBC9B7;
    colors[5] = 0xDADCE8;
    colors[6] = 0xE8E1B7;
    colors[7] = 0xE6D88A;
    colors[8] = 0xE6A88A;
    colors[9] = 0xE3B8DE;
    colors[10] = 0xE3C85B;
    colors[11] = 0xB4BEDE;
    colors[12] = 0xDE602A;
    colors[13] = 0xDEBF23;
    colors[14] = 0xDE8159;
    colors[15] = 0x5CA4DB;
    colors[16] = 0xD95975;
    colors[17] = 0xD683C3;
    colors[18] = 0x81A6D6;
    colors[19] = 0xD42F4A;
    colors[20] = 0x7D839E;
    colors[21] = 0x9C997E;
    colors[22] = 0x9C4019;
    colors[23] = 0x9A7B9C;
    colors[24] = 0x5F769C;
    colors[25] = 0x9C5E41;
    colors[26] = 0x998377;
    colors[27] = 0x99975C;
    colors[28] = 0x994071;
    colors[29] = 0x995C99;
    colors[30] = 0x99933F;
    colors[31] = 0x99725C;
    colors[32] = 0x968115;
    colors[33] = 0x6B4F40;
    colors[34] = 0x6B416A;
    colors[35] = 0x6B6840;
    colors[36] = 0x3F4F69;
    colors[37] = 0x696529;
    colors[38] = 0x695368;
    colors[39] = 0x693F2A;
    colors[40] = 0x545969;
    colors[41] = 0x665A09;
    colors[42] = 0x63250A;
    colors[43] = 0x332E03;
    colors[44] = 0x2B0801;
    colors[45] = 0x290220;
    colors[46] = 0x020E29;
    colors[47] = 0x1A0300;
    colors[48] = 0x01061A;
    colors[49] = 0x1A0118;
    colors[50] = 0x050505;
    
    idx = 50;
  }
  
  function addColor(uint64 _c) public onlyOwner {
    idx = idx + 1;
    colors[idx] = _c;
  }
  
  function getColor(uint64 _idx) public view returns(uint64) {
    return colors[_idx];
  }
}
