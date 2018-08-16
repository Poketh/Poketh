pragma solidity ^0.4.24;

import "./ERC891.sol";

interface ReducedERC721 {

    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    function approve(address _approved, uint256 _tokenId) external;

    function getApproved(uint256 _tokenId) external view returns (address);

    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}


contract Poketh is ReducedERC721, ERC891 {
    string  public constant name        = "Poketh";
    string  public constant symbol      = "PKTH";
    uint256 public version              = 0;
    
    constructor(address _balancesAddress) public {
        if(_balancesAddress != address(0)){
            pointToBalancesAt(_balancesAddress);
        } else {
            balances = new Balances();
        }
    }

    
    function transferFrom(address _from, address _to, uint256 _tokenId) external {
        transferFrom(_from, _to, address(_tokenId));
    }
    
    function ownerOf(uint256 _tokenId) external view returns (address) {
        balances.ownerOf(_tokenId);
    }
    
    function balanceOf(address _owner) external view returns (uint256) {
        balances.getBalanceCount(_owner);
    }
    
    function approve(address _approved, uint256 _tokenId) external {
        approve(_approved, address(_tokenId));
    }
    
    function allowance(address _owner, address _spender, address _ID) public view returns(bool) {
        return allowed[_owner][_spender][_ID];
    }
    
    function getApproved(uint256 _tokenId) external view returns (address) {
        return reverseAllowed[address(_tokenId)];
    }
    
    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return false;
    }

}
