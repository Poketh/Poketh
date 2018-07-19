pragma solidity ^ 0.4.23;

import "./Ownable.sol";

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
    
    struct Node {
        address selfID;
        address prevID;
        address nextID;
    }
    
    //      user    ->         class   ->         ID      -> (ID, prev, next)
    mapping(address => mapping(uint256 => mapping(address => Node))) internal balances;
    
    function addBalance(address _account, uint256 _class, address _ID) onlyOwner public {
        require(_ID != 0x0);
        
        Node memory root    = balances[_account][_class][0x0];
        Node memory head    = balances[_account][_class][root.nextID];
        Node memory insert  = Node(_ID, 0x0, head.selfID);
        
        head.prevID         = insert.selfID;
        root.nextID         = insert.selfID;
        
        balances[_account][_class][insert.selfID]   = insert;
        balances[_account][_class][head.selfID]     = head;
        balances[_account][_class][root.selfID]     = root;
    }
    
    function subBalance(address _account, uint256 _class, address _ID) onlyOwner public {
        require(_ID != 0x0);
        
        Node memory remove  = balances[_account][_class][_ID];
        balances[_account][_class][remove.prevID].nextID = remove.nextID;
        balances[_account][_class][remove.nextID].prevID = remove.prevID;
    }
    
    function getBalanceCount(address _account, uint256 _class) public view returns(uint256) {
        uint256 idx;
        address t;
        t = balances[_account][_class][0x0].nextID;
        
        for(idx = 0; t != 0x0; idx++){
            t = balances[_account][_class][t].nextID;
        }
        
        return idx;
    }
    
    function getBalanceClass(address _account, uint256 _class) public view returns(address[]) {
        address[] memory returnIDs = new address[](getBalanceCount(_account, _class));
        uint256 idx;
        address t;
        t = balances[_account][_class][0x0].nextID;
        
        for(idx = 0; t != 0x0; idx++){
            returnIDs[idx] = t;
            t = balances[_account][_class][t].nextID;
        }
        
        return returnIDs;
    }
    
    function checkValid(address _account, uint256 _class, address _ID) public view returns(bool) {
        bool isValid = false;
        address t;
        t = balances[_account][_class][0x0].nextID;
        
        while(t != 0x0){
            isValid = (t == _ID) || isValid;
            t = balances[_account][_class][t].nextID;
        }
        
        return isValid;
    }
    
    function checkValid(address _account, address _ID) public view returns(bool,uint256) {
        address t;
        
        for(uint256 _class = 0; _class < 152; _class++){
            t = balances[_account][_class][0x0].nextID;
        
            while(t != 0x0){
                if(t == _ID) return (true,_class);
                t = balances[_account][_class][t].nextID;
            }
        }
        
        return (false, 9000);
    }
    
    function setClaimed(address _address) onlyOwner public {
        claimed[_address] = true;
    }
    
    function checkClaimed(address _address) public view returns(bool) {
        return claimed[_address];
    }
}
