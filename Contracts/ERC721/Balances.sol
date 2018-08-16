pragma solidity ^ 0.4.24;

import "../Support/Ownable.sol";

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

contract Balances is Ownable {
    using SafeMath
    for uint256;
    
    mapping(address => bool) internal claimed;
    mapping(address => address) internal ownedBy;
    
    struct Node {
        address selfID;
        address prevID;
        address nextID;
        uint256 class;
    }
    
    //      user    ->         ID      -> (ID, prev, next)
    mapping(address => mapping(address => Node)) internal balances;
    
    function addBalance(address _account, uint256 _class, address _ID) onlyOwner public {
        require(_ID != 0x0);
        ownedBy[_ID] = _account;
        
        Node memory root    = balances[_account][0x0];
        Node memory head    = balances[_account][root.nextID];
        Node memory insert  = Node(_ID, 0x0, head.selfID, _class);
        
        head.prevID         = insert.selfID;
        root.nextID         = insert.selfID;
        
        balances[_account][insert.selfID]   = insert;
        balances[_account][head.selfID]     = head;
        balances[_account][root.selfID]     = root;
    }
    
    function subBalance(address _account, address _ID) onlyOwner public {
        require(_ID != 0x0);
        
        Node memory remove  = balances[_account][_ID];
        balances[_account][remove.prevID].nextID = remove.nextID;
        balances[_account][remove.nextID].prevID = remove.prevID;
    }
    
    function getBalanceCount(address _account) public view returns(uint256) {
        uint256 idx;
        address t;
        t = balances[_account][0x0].nextID;
        
        for(idx = 0; t != 0x0; idx++){
            t = balances[_account][t].nextID;
        }
        
        return idx;
    }
    
    function getBalanceCount(address _account, uint256 class) public view returns(uint256) {
        uint256 count = 0;
        address t;
        t = balances[_account][0x0].nextID;
        
        for(uint256 idx = 0; t != 0x0; idx++){
            if(balances[_account][t].class == class) count++;
            t = balances[_account][t].nextID;
        }
        
        return count;
    }
    
    function checkValid(address _account, address _ID) public view returns(bool,uint256) {
        address t;
        
        t = balances[_account][0x0].nextID;
        
        while(t != 0x0){
            if(t == _ID) return (true,balances[_account][t].class);
            t = balances[_account][t].nextID;
        }
        
        return (false, 9000);
    }
    
    function setClaimed(address _address) onlyOwner public {
        claimed[_address] = true;
    }
    
    function checkClaimed(address _address) public view returns(bool) {
        return claimed[_address];
    }
    
    function ownerOf(uint256 _tokenId) external view returns (address){
        return ownedBy[address(_tokenId)];
    }
}
