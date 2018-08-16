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
  uint16 constant matrixSize = 20;
  mapping(uint64 => uint64[matrixSize]) internal items;
  uint64 internal idx;
  
  Pallete internal colors;

  function MatrixDescriptor(address _pallete) public {
    colors = Pallete(_pallete);
    
    idx = 0;
  }

  function addItem(uint64[matrixSize] _itm) public onlyOwner {
    idx = idx + 1;
    items[idx] = _itm;
  }
  
  function editItem(uint64 _idx, uint64[matrixSize] _itm) public onlyOwner {
    items[_idx] = _itm;
  }

  function getItem(uint64 _idx) view public returns(uint64[matrixSize]) {
    uint64[matrixSize] memory itemsHex = items[_idx];
    
    for(uint i = 0; i < matrixSize; i++){
        itemsHex[i] = colors.getColor(itemsHex[i]);
    }
    return itemsHex;

  }
}
