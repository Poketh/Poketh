pragma solidity ^ 0.4.23;

contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
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
  function transfer(address to, uint256 value) public returns(bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => mapping(uint256 => uint256)) balances;
  
  uint256 totalSupply_;
  function totalSupply() public view returns(uint256) {
    return totalSupply_;
  }
}


contract ERC891 is Ownable, ERC20Basic, BasicToken {
    
    // Events 
  event Mine(address indexed to, uint256 amount);
  event MiningFinished();


    // Settings
  bool public miningFinished = false;
  uint256 public fee;
  uint256 diffMask = 3;


    // Collection Database
  mapping(address => bool) claimed;
  mapping(address => bool) feepaid;
  mapping(uint8 => uint8) lookup;
  mapping(uint8 => uint8) acc;


    // Item mapping from codes to IDs
  uint8[151] private rewardItemMapping;

  modifier canMine {
    require(!miningFinished);
    _;
  }

  constructor() public {
    lookup[15] = 52;
    lookup[13] = 14;
    lookup[12] = 8;
    lookup[11] = 12;
    lookup[10] = 10;
    lookup[9]  = 3;
    lookup[8]  = 4;
    lookup[8]  = 10;
    lookup[7]  = 7;
    lookup[6]  = 26;
    lookup[3]  = 5;

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
    acc[3]  = acc[6]  + lookup[6];

    rewardItemMapping = [16, 17, 19, 20, 21, 22, 23, 27, 28, 29, 30, 32, 33, 39, 41, 42, 43, 44, 46, 47, 48, 49, 50, 52, 54, 55, 56, 60, 66, 67, 69, 70, 72, 73, 74, 75, 79, 80, 81, 84, 85, 86, 88, 96, 98, 100, 116, 118, 129, 130, 11, 14, 24, 51, 53, 57, 82, 87, 97, 99, 101, 109, 114, 119, 35, 37, 71, 83, 89, 92, 95, 117, 12, 15, 40, 45, 58, 61, 64, 68, 77, 93, 102, 111, 25, 26, 62, 63, 104, 105, 108, 110, 112, 128, 78, 120, 124, 36, 90, 91, 132, 106, 107, 113, 115, 122, 123, 126, 127, 147, 148, 1, 4, 7, 125, 131, 133, 143, 2, 3, 5, 6, 8, 9, 18, 31, 34, 38, 59, 65, 76, 94, 103, 121, 134, 135, 136, 137, 138, 139, 140, 141, 142, 144, 145, 146, 149, 150, 151];
  }

    /* -----------------------------------------------------
        claim() 
        
        - Realizes the balance of the address.
        - Requires to have an unclaimed property.
        - The claimed value should be in the mapping 
        i.e. not error 9000
        
        reward          <- item ID from checkFind(sender)

        
    ----------------------------------------------------- */

  function claim() canMine public {
    uint256 reward = checkFind(msg.sender);
    require(!claimed[msg.sender]);
   
    require(reward != 9000);
    require(balances[msg.sender][reward] < 1000);


    claimed[msg.sender] = true;
    balances[msg.sender][reward] = balances[msg.sender][reward] + 1;
    
    emit Mine(msg.sender, reward);
  }

    /* -----------------------------------------------------
        checkFind(address) returns (uint16)
        
        - Checks the reward for address.
        - Zero returning is not possible. Connected to
        the wrong network or error.
        - Returning 9000 signals an invalid address for
        the current difficulty mask.
        
        dataSelector    <- address trimmed to 64 bits
        data            <- address masked to 52 bits
        bitCount        <- store the 1 bit count in data
        code            <- discriminator for same-tier
                            items
        
        Apply the diff mask by cheking the single case 
        2^(diffMask)-1 AND the first 16 bits of the address
        which needs to be 0.
        
    ----------------------------------------------------- */

  function checkFind(address _add) view public returns(uint16) {
    uint8  bitCount = 0;
    
    bytes8 dataSelector = bytes8(_add);
    bytes8 data = bytes8(_add) & ((1 << 52) - 1); 

    while (data != 0) {
      bitCount = bitCount + uint8(data & 1);
      data = data >> 1;
    }

    uint64 code = uint64(dataSelector >> 58);

    if (uint256(_add) >> (136) & ((uint256(1) << diffMask) - 1) != 0) return 9000;
    return lookup[bitCount] > 0 ? rewardItemMapping[code % lookup[bitCount] + acc[bitCount]] : 9000;
  }

    /* -----------------------------------------------------
        transfer(address,uint256) returns (bool)
            (API friendly)
        
        - Sends the item with ID from value.
        - Doesn't allow sending to 0x0.
        - Requires a registration fee sent to owner.
        - Returns leftover eth to the sender.
        - If the address has an item, it is claimed.
        - Max balance for each item is 1000.
        
    ----------------------------------------------------- */

  function transfer(address _to, uint256 _value) public returns(bool) {
    require(_to != address(0));
    require(feepaid[msg.sender]);
    
    if (!claimed[msg.sender] && checkFind(msg.sender) != 9000) claim();
    require(balances[msg.sender][_value] > 0 && balances[_to][_value] < 1000);

    balances[msg.sender][_value]--;
    balances[_to][_value]++;
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  
    /* -----------------------------------------------------
        fallback
            (API friendly)
        
        - Pays the fee to the owner and returns the
        excess to the sender.
        
    ----------------------------------------------------- */
  
  function() payable public {
    require(msg.value >= fee);
    owner.transfer(fee);
    msg.sender.transfer(msg.value-fee);
    
    feepaid[msg.sender] = true;
  }
  
    /* -----------------------------------------------------
        transfer(address,uint256) returns (bool)
            (web3 friendly)
        
        - Combines the payable fallback and the API 
        friendly transfer() in a single call.
        
    ----------------------------------------------------- */
  function payFeeAndTransfer(address _to, uint256 _value) payable public returns(bool){
    require(msg.value >= fee);
    owner.transfer(fee);
    msg.sender.transfer(msg.value-fee);
    
    feepaid[msg.sender] = true;
    
    return transfer(_to, _value);
  }
  
    /* -----------------------------------------------------
        balanceOf(address) returns (uint256[151])
        
        - Take the balance of the address, store into a 
        memory type and return the collection.
        - The collection runs from ID 1 to 151.
        
    ----------------------------------------------------- */

  function balanceOf(address _add) view public returns(uint256[151]) {
    uint256[151] memory collection;

    for (uint256 i = 0; i <= 150; i++) {
      collection[i] = balances[_add][i+1];
    }

    return collection;
  }
  
    /* -----------------------------------------------------
        itemMapping(address) returns (uint256[151])
        
        - Get the mapping for the rarity tiers.
        - The mapping runs from 0 to 150.
        
    ----------------------------------------------------- */
  
  function itemMapping() view public returns(uint256[151]){
    uint256[151] memory collection;

    for (uint256 i = 0; i < 151; i++) {
      collection[i] = rewardItemMapping[i];
    }

    return collection;
  }
}



contract Poketh is ERC891 {
  string public constant name = "Poketh";
  string public constant symbol = "PKTH";
  uint256 public constant decimals = 0;

  constructor(uint256 _fee) public {
    fee = _fee * 1000000000000; // 0.001 finney
  }

  function setFee(uint256 _fee) onlyOwner public {
    fee = _fee * 1000000000000;
  }
  
  function setDifficulty(uint256 _diffMask) public {
    diffMask = _diffMask;
  }
}
