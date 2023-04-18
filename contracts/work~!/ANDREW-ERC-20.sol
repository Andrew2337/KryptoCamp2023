// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AndrewToken is ERC20{
    address private Owner;
    uint8 private decimals_;
    constructor(string memory name, string memory symbol, uint8 _decimals) ERC20(name, symbol){
        decimals_ = _decimals;
        Owner = msg.sender;
    }

    modifier onlyOwner() {
        require( msg.sender == Owner ,"This function only owner can use.");
        _;
    }

    function decimals() public view override returns (uint8) {
        return decimals_;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint (to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn (from, amount);
    }
}