pragma solidity ^ 0.4.23;

import "./ECRecovery.sol";
import "./Balances.sol";
import "./Ownable.sol";
import "./Pausable.sol";


contract ERC20Basic {
    function transfer(address to, uint256 value) public returns(bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success);
    function approve(address _spender, uint256 _value) public returns(bool success);
    function allowance(address _owner, address _spender) public view returns(uint256[152]);

    event Transfer(address indexed from, address indexed to, address ID);
    event Approval(address indexed _owner, address indexed _spender, address ID);
}

contract BasicToken is ERC20Basic {
    
    uint256 constant private MAX_UINT256 = 2 ** 256 - 1;
    
    Balances balances;
    mapping(address => mapping(address => mapping(address => bool))) public allowed;

    uint256 totalSupply_;

    function totalSupply() public view returns(uint256) {
        return totalSupply_;
    }
    function approve(address _spender, address _ID) public returns(bool success) {
        allowed[msg.sender][_spender][_ID] = true;
        emit Approval(msg.sender, _spender, _ID); //solhint-disable-line indent, no-unused-vars
        return true;
    }
    function allowance(address _owner, address _spender, address _ID) public view returns(bool) {
        return allowed[_owner][_spender][_ID];
    }
}

contract ERC891 is Ownable, ERC20Basic, BasicToken, Pausable {
    uint256 constant private MAX_UINT256 = 2 ** 256 - 1;

    using ECRecovery
    for bytes32;

    // Events 
    event Mine(address indexed to, uint256 amount);


    // Settings
    uint256 diffMask            = 3;
    address public tradeTracker = 0x0;


    // Collection Database
    mapping(address => bool) claimed;
    mapping(address => bool) feepaid;
    mapping(uint8 => uint8) lookup;
    mapping(uint8 => uint8) acc;


    // Item mapping from codes to IDs
    uint8[151] private rewardItemMapping;

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

    function claim() whenNotPaused public {
        uint256 reward = checkFind(msg.sender);
        require(!claimed[msg.sender]);

        require(reward != 9000);

        claimed[msg.sender] = true;
        balances.addBalance(msg.sender, reward, 1);

        emit Mine(msg.sender, reward);
    }

    /* -----------------------------------------------------
          claimFor(address) 
          
          - Delegated version of claim()
    ----------------------------------------------------- */

    function claimFor(address _address) whenNotPaused public {
        uint256 reward = checkFind(_address);
        require(!claimed[_address]);

        require(reward != 9000);

        claimed[_address] = true;
        
        balances.addBalance(_address, reward, 1);

        emit Mine(_address, reward);
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
        uint8 bitCount = 0;

        bytes8 dataSelector = bytes8(_add);
        bytes8 data         = bytes8(_add) & ((1 << 52) - 1);

        while (data != 0) {
            bitCount = bitCount + uint8(data & 1);
            data = data >> 1;
        }

        uint64 code = uint64(dataSelector >> 58);

        if (uint256(_add) >> (136) & ((uint256(1) << diffMask) - 1) != 0) return 9000;
        return lookup[bitCount] > 0 ? rewardItemMapping[code % lookup[bitCount] + acc[bitCount]] : 9000;
    }

    /* -----------------------------------------------------
        transfer(address,address) returns (bool)

        - Sends the item with ID from value.
        - Doesn't allow sending to 0x0.
        - If the address has an item, it attempts to claim.
    ----------------------------------------------------- */

    function transfer(address _to, uint256 _class, address _ID) whenNotPaused public returns(bool) {
        require(_to != address(0));

        if (!claimed[msg.sender] && checkFind(msg.sender) != 9000) claim();
        require(balances.checkValid(msg.sender, _class, _ID));

        balances.subBalance(msg.sender, _class, _ID);
        balances.addBalance(_to, _class, _ID);
        
        emit Transfer(msg.sender, _to, _ID);
        return true;
    }
    
    /* -----------------------------------------------------
        transferFrom(address,address,address) returns (bool)

        - Sends the item with ID from value.
        - Doesn't allow sending to 0x0.
        - Adds an exception for the special trade address.
    ----------------------------------------------------- */
    
    function transferFrom(address _from, address _to, uint256 _class, address _ID) whenNotPaused public returns(bool success) {
        bool allowance = allowed[_from][_to][_ID];
        require(balances.checkValid(_from, _class, _ID) && allowance);
        
        allowed[_from][_to][_ID] = false;

        balances.subBalance(_from, _class, _ID);
        balances.addBalance(_to, _class, _ID);
        
        emit Transfer(_from, _to, _ID); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    /* -----------------------------------------------------
        fallback
            (API friendly)
        
        - Pays the fee to the owner and returns the
        excess to the sender.
    ----------------------------------------------------- */

    function() payable whenNotPaused public {
        bytes32 hash = bytes32(keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            keccak256(abi.encodePacked(msg.sender))
        )));
        address minedAddress = hash.recover(msg.data);
        uint256 reward = checkFind(minedAddress);

        claimFor(minedAddress);

        allowed[minedAddress][msg.sender][minedAddress] = true;
        transferFrom(minedAddress, msg.sender, reward);
    }

    /* -----------------------------------------------------
        balanceOf(address) returns (uint256[151])
        
        - Take the balance of the address, store into a 
        memory type and return the collection.
        - The collection runs from class 1 to 151.
    ----------------------------------------------------- */

    function balanceOf(address _add) whenNotPaused view public returns(uint256[152]) {
        uint256[152] memory collection;
        collection[0] = uint256(-1);

        for (uint256 i = 1; i <= 151; i++) {
            collection[i] = balances.getBalanceCount(_add, i);
        }

        return collection;
    }
    
    /* -----------------------------------------------------
        balanceOfClass(address) returns (address[])
        
        - Get the IDs by class
    ----------------------------------------------------- */

    function balanceOfClass(address _add, uint256 _class) whenNotPaused view public returns(address[]) {
        return balances.getBalanceClass(_add, _class);
    }

    /* -----------------------------------------------------
        itemMapping(address) returns (uint256[151])
        
        - Get the mapping for the rarity tiers.
        - The mapping runs from 0 to 150.
    ----------------------------------------------------- */

    function itemMapping() view public returns(uint256[151]) {
        uint256[151] memory collection;

        for (uint256 i = 0; i < 151; i++) {
            collection[i] = rewardItemMapping[i];
        }

        return collection;
    }
    
    /* -----------------------------------------------------
        setDifficulty(uint256)
        
        - Set the mining difficulty bit count.
    ----------------------------------------------------- */
    
    function setDifficulty(uint256 _diffMask) onlyOwner public {
        diffMask = _diffMask;
    }
    
    /* -----------------------------------------------------
        pointToBalancesAt(address)
        
        - Point to a different storage contract for
            balances.
    ----------------------------------------------------- */
    
    function pointToBalancesAt(address _balancesAddress) onlyOwner public {
        balances = Balances(_balancesAddress);
    }
}


contract Poketh is ERC891 {
    string  public constant name        = "Poketh";
    string  public constant symbol      = "PKTH";
    uint256 public constant decimals    = 0;
    uint256 public version              = 0;
    
    constructor(address _balancesAddress) public {
        if(_balancesAddress != address(0)){
            pointToBalancesAt(_balancesAddress);
        } else {
            balances = new Balances();
        }
    }
    
    function upgradeTo(address _upgrade) onlyOwner public {
        pause();
        balances.transferOwnership(_upgrade);
    }
}
