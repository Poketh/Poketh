pragma solidity ^ 0.4.24;

import "./ECRecovery.sol";
import "./Balances.sol";
import "./Ownable.sol";
import "./Pausable.sol";


contract BasicERC {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event Mine(address indexed _to, uint256 _amount, address _ID);

    uint256 constant private MAX_UINT256 = 2 ** 256 - 1;
    
    Balances public balances;
    mapping(address => mapping(address => mapping(address => bool))) public allowed;
    mapping(address => address) public reverseAllowed;
    
    function approve(address _spender, address _ID) public {
        allowed[msg.sender][_spender][_ID]  = true;
        reverseAllowed[_ID]                 = _spender;
    }
}

contract ERC891 is Ownable, BasicERC, Pausable {
    uint256 constant private MAX_UINT256 = 2 ** 256 - 1;

    using ECRecovery
    for bytes32;

    // Settings
    uint256 diffMask = 3;

    // Collection Database
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
        uint256 rewardClass = checkFind(msg.sender);
        require(!balances.checkClaimed(msg.sender));

        require(rewardClass != 9000);

        balances.setClaimed(msg.sender);
        balances.addBalance(msg.sender, rewardClass, msg.sender);

        emit Mine(msg.sender, rewardClass, msg.sender);
    }
    
     /* -----------------------------------------------------
        claimWithSignature(bytes) 
        
        - Recovers the signer of the data
        - Checks the reward of the signer
        - Adds the reward to msg.sender
        - The claimed value should be in the mapping 
        i.e. not error 9000
    ----------------------------------------------------- */   
    
    function claimWithSignature(bytes _sig) whenNotPaused public {
        bytes32 hash = bytes32(keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            keccak256(abi.encodePacked(msg.sender))
        )));
        
        address minedAddress = hash.recover(_sig);
        uint256 rewardClass = checkFind(minedAddress);
        
        require(!balances.checkClaimed(minedAddress));

        require(rewardClass != 9000);

        balances.setClaimed(minedAddress);
        balances.addBalance(msg.sender, rewardClass, minedAddress);

        emit Mine(msg.sender, rewardClass, minedAddress);
    }

    /* -----------------------------------------------------
          claimFor(address) 
          
          - Delegated version of claim()
    ----------------------------------------------------- */

    function claimFor(address _address) whenNotPaused public {
        uint256 rewardClass = checkFind(_address);
        require(!balances.checkClaimed(_address));

        require(rewardClass != 9000);

        balances.setClaimed(_address);
        
        balances.addBalance(_address, rewardClass, _address);

        emit Mine(_address, rewardClass, _address);
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
            (API friendly)

        - Sends the item with ID from value.
        - Doesn't allow sending to 0x0.
        - If the address has an item, it attempts to claim.
        - Checks for the class if not specified.
    ----------------------------------------------------- */
    
    function transfer(address _to, address _ID) whenNotPaused public returns(bool) {
        require(_to != address(0));
        bool isValid;
        uint256 class;

        if (!balances.checkClaimed(msg.sender) && checkFind(msg.sender) != 9000) claim();
        (isValid, class) = balances.checkValid(msg.sender, _ID);
        require(isValid);

        balances.subBalance(msg.sender, _ID);
        balances.addBalance(_to, class, _ID);
        
        emit Transfer(msg.sender, _to, uint256(_ID));
        return true;
    }
    
    /* -----------------------------------------------------
        transferFrom(address,address,address) returns (bool)
            (API friendly)
            
        - Sends the item with ID from value.
        - Doesn't allow sending to 0x0.
        - Adds an exception for the special trade address.
    ----------------------------------------------------- */
    
    function transferFrom(address _from, address _to, address _ID) whenNotPaused public {
        bool allowance = allowed[_from][_to][_ID];
        bool isValid;
        uint256 class;
        (isValid, class) = balances.checkValid(msg.sender, _ID);

        require(isValid && allowance);
        
        allowed[_from][_to][_ID] = false;
        reverseAllowed[_ID]      = address(0);

        balances.subBalance(_from, _ID);
        balances.addBalance(_to, class, _ID);
        
        emit Transfer(_from, _to, uint256(_ID));
    }

    /* -----------------------------------------------------
        mint(bytes)

        - Claim via eth signed messages.
    ----------------------------------------------------- */

    function mint(bytes _sig) whenNotPaused public {
        bytes32 hash = bytes32(keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            keccak256(abi.encodePacked(msg.sender))
        )));
        address minedAddress = hash.recover(_sig);
        uint256 reward = checkFind(minedAddress);

        claimFor(minedAddress);

        balances.addBalance(msg.sender, reward, minedAddress);
    }
    
    /* -----------------------------------------------------
        balanceOf(address) returns (uint256[152])
        
        - Take the balance of the address, counting over the
            classes.
        - The collection runs from class 1 to 151.
    ----------------------------------------------------- */

    function classBalanceOf(address _add) whenNotPaused view public returns(uint256[152]) {
        uint256[152] memory collection;
        collection[0] = uint256(-1);

        for (uint256 i = 1; i <= 151; i++) {
            collection[i] = balances.getBalanceCount(_add, i);
        }

        return collection;
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
        - Future improvement: autoset diffMask
    ----------------------------------------------------- */
    
    function setDifficulty(uint256 _diffMask) onlyOwner public {
        diffMask = _diffMask;
    }
    
    /* -----------------------------------------------------
        pointToBalancesAt(address)
        
        - Point to a different storage contract for
            balances. Used for upgrading logic.
    ----------------------------------------------------- */
    
    function pointToBalancesAt(address _balancesAddress) onlyOwner public {
        balances = Balances(_balancesAddress);
    }
    
    /* -----------------------------------------------------
        upgradeTo(address)
        
        - Transfer ownership of balances to the upgraded contract.
    ----------------------------------------------------- */
    
    function upgradeTo(address _upgrade) onlyOwner public {
        pause();
        balances.transferOwnership(_upgrade);
    }

}
