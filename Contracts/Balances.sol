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
    mapping(address => mapping(uint256 => uint256)) balances;
    
    constructor() public {
        ownerContract = msg.sender;
    }
    
    function setBalance(address _add, uint256 _x, uint256 _y) onlyOwner public {
        require(msg.sender == ownerContract);
        balances[_add][_x] = _y;
    }
    
    function addBalance(address _add, uint256 _x, uint256 _delta) onlyOwner public {
        require(msg.sender == ownerContract);
        balances[_add][_x] = balances[_add][_x].add(_delta);
    }
    
    function subBalance(address _add, uint256 _x, uint256 _delta) onlyOwner public {
        require(msg.sender == ownerContract);
        balances[_add][_x] = balances[_add][_x].sub(_delta);
    }
    
    function getBalance(address _add, uint256 _x) public view returns(uint256) {
        return balances[_add][_x];
    }
}
