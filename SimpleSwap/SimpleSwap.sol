// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title SimpleSwap
 * @notice A simple AMM contract for swapping and providing liquidity for ERC20 pairs.
 */
contract SimpleSwap {
    // Mapping to store reserves for each token pair
    mapping(address => mapping(address => uint256)) public reserveA;
    mapping(address => mapping(address => uint256)) public reserveB;
    // Mapping to store liquidity tokens for each user and pair
    mapping(address => mapping(address => mapping(address => uint256))) public liquidity;
    // Mapping to store total liquidity for each pair
    mapping(address => mapping(address => uint256)) public totalLiquidity;

    event LiquidityAdded(address indexed provider, address indexed tokenA, address indexed tokenB, uint amountA, uint amountB, uint liquidityMinted);

    /**
     * @notice Add liquidity to a token pair pool
     * @param tokenA Address of token A
     * @param tokenB Address of token B
     * @param amountADesired Amount of token A user wants to add
     * @param amountBDesired Amount of token B user wants to add
     * @param amountAMin Minimum amount of token A to add (slippage protection)
     * @param amountBMin Minimum amount of token B to add (slippage protection)
     * @param to Address to receive liquidity tokens
     * @param deadline Transaction must be executed before this timestamp
     * @return amountA Actual amount of token A added
     * @return amountB Actual amount of token B added
     * @return liquidityMinted Amount of liquidity tokens minted
     */
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidityMinted) {
        require(block.timestamp <= deadline, "Transaction expired");
        require(tokenA != tokenB, "Tokens must be different");

        // Get current reserves
        uint reserve0 = reserveA[tokenA][tokenB];
        uint reserve1 = reserveB[tokenA][tokenB];

        // If pool is empty, use desired amounts
        if (reserve0 == 0 && reserve1 == 0) {
            amountA = amountADesired;
            amountB = amountBDesired;
        } else {
            // Calculate optimal amounts to keep the ratio
            uint amountBOptimal = (amountADesired * reserve1) / reserve0;
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "Insufficient B amount");
                amountA = amountADesired;
                amountB = amountBOptimal;
            } else {
                uint amountAOptimal = (amountBDesired * reserve0) / reserve1;
                require(amountAOptimal >= amountAMin, "Insufficient A amount");
                amountA = amountAOptimal;
                amountB = amountBDesired;
            }
        }

        // Transfer tokens from user to contract
        require(IERC20(tokenA).transferFrom(msg.sender, address(this), amountA), "Transfer A failed");
        require(IERC20(tokenB).transferFrom(msg.sender, address(this), amountB), "Transfer B failed");

        // Mint liquidity tokens (simple proportional model)
        if (totalLiquidity[tokenA][tokenB] == 0) {
            liquidityMinted = sqrt(amountA * amountB);
        } else {
            liquidityMinted = min(
                (amountA * totalLiquidity[tokenA][tokenB]) / reserve0,
                (amountB * totalLiquidity[tokenA][tokenB]) / reserve1
            );
        }
        require(liquidityMinted > 0, "Insufficient liquidity minted");

        // Update reserves and liquidity
        reserveA[tokenA][tokenB] += amountA;
        reserveB[tokenA][tokenB] += amountB;
        liquidity[to][tokenA][tokenB] += liquidityMinted;
        totalLiquidity[tokenA][tokenB] += liquidityMinted;

        emit LiquidityAdded(to, tokenA, tokenB, amountA, amountB, liquidityMinted);
    }

    // Helper functions
    function min(uint x, uint y) private pure returns (uint) {
        return x < y ? x : y;
    }

    function sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    // ...implement the rest of the required functions here...
}