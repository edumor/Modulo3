// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0

pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts@5.3.0/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts@5.3.0/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts@5.3.0/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts@5.3.0/utils/ReentrancyGuard.sol";

/**
 * @title TokenA
 * @dev Mintable and burnable ERC20 token with max supply for ETH-KIPU Modulo 3.
 */
contract TokenA is ERC20, ERC20Burnable, Ownable, ReentrancyGuard {
    uint256 public constant maxSupply = 1_000_000 * 1e18;

    constructor(address initialOwner)
        ERC20("TokenA", "TKA")
        Ownable(initialOwner)
    {}

    function mint(address to, uint256 amount) public onlyOwner nonReentrant {
        require(to != address(0), "zero addr");
        require(amount > 0, "zero amt");
        require(totalSupply() + amount <= maxSupply, "max supply");
        _mint(to, amount);
    }
}