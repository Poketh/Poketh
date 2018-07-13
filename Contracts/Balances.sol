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
    
    address public ownerContract;
    
    struct Node {
        address selfID;
        address prevID;
        address nextID;
    }
    
    //      user    ->         class   ->         ID      -> (ID, prev, next)
    mapping(address => mapping(uint256 => mapping(address => Node))) balances;
    
    constructor() public {
        ownerContract = msg.sender;
    }
    function addBalance(address _account, uint256 _class, address _ID) onlyOwner public {
        require(msg.sender == ownerContract && _ID != 0x0);
        
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
        require(msg.sender == ownerContract && _ID != 0x0);
        
        Node memory remove  = balances[_account][_class][_ID];
        balances[_account][_class][remove.prevID].nextID = remove.nextID;
        balances[_account][_class][remove.nextID].prevID = remove.prevID;
    }
    function getBalance(address _account, uint256 _class, uint256 _amount) public view returns(address[]) {
        address[] memory returnIDs = new address[](_amount);
        uint256 idx = 0;
        address t;
        t = balances[_account][_class][0x0].nextID;
        
        while(t != 0x0){
            returnIDs[idx++] = t;
            t = balances[_account][_class][t].nextID;
        }
        
        return returnIDs;
    }
}
