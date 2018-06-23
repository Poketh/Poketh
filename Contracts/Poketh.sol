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

contract EIP20Interface {
    uint256 public totalSupply;

    function balanceOf(address _add) public view returns(uint256[152]);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns(uint256[152]);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract EIP20 is EIP20Interface {

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping(address => mapping(uint256 => uint256)) balances;
    mapping (address => mapping (address => mapping(uint256 => uint256))) public allowed;

    string public name;                   
    uint8 public decimals;                
    string public symbol;                 

    constructor(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
    ) public {
        totalSupply = _initialAmount;                        
        name = _tokenName;                                   
        decimals = _decimalUnits;                            
        symbol = _tokenSymbol;                               
    }
     
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender][_value] >= 1);
        balances[msg.sender][_value] -= 1;
        balances[_to][_value] += 1;
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender][_value];
        require(balances[_from][_value] >= 1 && allowance >= 1);
        balances[_to][_value] += 1;
        balances[_from][_value] -= 1;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender][_value] -= 1;
        }
        emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(address _add) public view returns(uint256[152]) {
        uint256[152] memory collection;
        collection[0] = uint256(-1);

        for (uint256 i = 1; i <= 151; i++) {
            collection[i] = balances[_add][i];
        }

        return collection;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender][_value] = 1;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(address _owner, address _spender) public view returns(uint256[152]) {
        uint256[152] memory collection;
        collection[0] = uint256(-1);

        for (uint256 i = 1; i <= 151; i++) {
            collection[i] = allowed[_owner][_spender][i];
        }

        return collection;
    }
}



contract ERC891 is Ownable, EIP20 {
    
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
  uint8[151] rewardItemMapping;


  modifier canMine {
    require(!miningFinished);
    _;
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
        
        dataSelector    <- address 160 bits
        data            <- address masked to bitpool bits
        bitCount        <- store the 1 bit count in data

        
        Apply the diff mask by cheking the single case 
        2^(diffMask)-1 AND the first bits of the address
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

}



contract Poketh is ERC891 {

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

  function setFee(uint256 _fee) onlyOwner public {
    fee = _fee * 1000000000000;
  }
  
  function setDifficulty(uint256 _diffMask) public {
    diffMask = _diffMask;
  }
}
