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
        
        Node memory head    = balances[_account][_class][0x0];
        Node memory insert  = Node(_ID, 0x0, head.selfID);
        head.prevID         = insert.selfID;
        
        balances[_account][_class][0x0] = insert;
        
        if(insert.nextID != 0x0)
            balances[_account][_class][insert.nextID] = head;
    }
    function subBalance(address _account, uint256 _class, address _ID) onlyOwner public {
        require(msg.sender == ownerContract && _ID != 0x0);
        
        Node memory remove  = balances[_account][_class][_ID];
        balances[_account][_class][remove.prevID].nextID = remove.nextID;
        balances[_account][_class][remove.nextID].prevID = remove.prevID;
    }
    function getBalance(address _account, uint256 _class) public view returns(address[]) {
        address[] memory returnIDs = new address[](100);
        uint256 idx = 0;
        Node memory t;
        t = balances[_account][_class][0x0];
        
        while(t.selfID != 0x0){
            returnIDs[idx++] = t.selfID;
            t = balances[_account][_class][t.nextID];
        }
        
        return returnIDs;
    }
}
