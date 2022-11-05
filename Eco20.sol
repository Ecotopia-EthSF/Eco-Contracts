// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Eco20 is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(_name, _symbol) {}

    function mint(address to, uint256 value) public virtual {
        _mint(to, value);
    }
}
