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

contract MatrixDescriptor is Ownable {
  mapping(uint64 => uint64[16]) items;
  uint64 internal idx;
  
  Pallete colors;

  function MatrixDescriptor(address _pallete) public {
    colors = Pallete(_pallete);
    items[1] = [uint64(1), 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];

    idx = 1;
  }

  function addItem(uint64[16] _itm) public onlyOwner {
    idx = idx + 1;
    items[idx] = _itm;
  }

  function getItem(uint64 _idx) view public returns(uint64[16]) {
    uint64[16] memory itemsHex = items[_idx];
    
    for(uint i = 0; i < 16; i++){
        itemsHex[i] = colors.getColor(itemsHex[i]);
    }
    return itemsHex;

  }
}
