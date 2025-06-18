// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SimpleSwap {
    using SafeMath for uint256;

    struct Pool {
        uint256 reserveA;
        uint256 reserveB;
        uint256 totalLiquidity;
    }

    mapping(address => mapping(address => Pool)) public pools;
    mapping(address => mapping(address => mapping(address => uint256))) public liquidityTokens;

    event LiquidityAdded(address indexed tokenA, address indexed tokenB, uint amountA, uint amountB, uint liquidity);
    event LiquidityRemoved(address indexed tokenA, address indexed tokenB, uint amountA, uint amountB);
    event TokensSwapped(address indexed tokenIn, address indexed tokenOut, uint amountIn, uint amountOut);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity) {
        require(deadline >= block.timestamp, "Transaction expired");

        IERC20(tokenA).transferFrom(msg.sender, address(this), amountADesired);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountBDesired);

        Pool storage pool = pools[tokenA][tokenB];

        if (pool.totalLiquidity == 0) {
            liquidity = amountADesired.add(amountBDesired);
        } else {
            amountA = (amountADesired.mul(pool.totalLiquidity)).div(pool.reserveA);
            amountB = (amountBDesired.mul(pool.totalLiquidity)).div(pool.reserveB);
            require(amountA >= amountAMin, "Insufficient A amount");
            require(amountB >= amountBMin, "Insufficient B amount");
            liquidity = SafeMath.min(amountA, amountB);
        }

        pool.reserveA = pool.reserveA.add(amountA);
        pool.reserveB = pool.reserveB.add(amountB);
        pool.totalLiquidity = pool.totalLiquidity.add(liquidity);

        liquidityTokens[tokenA][tokenB][to] = liquidityTokens[tokenA][tokenB][to].add(liquidity);

        emit LiquidityAdded(tokenA, tokenB, amountA, amountB, liquidity);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB) {
        require(deadline >= block.timestamp, "Transaction expired");

        Pool storage pool = pools[tokenA][tokenB];
        require(liquidityTokens[tokenA][tokenB][msg.sender] >= liquidity, "Insufficient liquidity");

        amountA = (liquidity.mul(pool.reserveA)).div(pool.totalLiquidity);
        amountB = (liquidity.mul(pool.reserveB)).div(pool.totalLiquidity);
        require(amountA >= amountAMin, "Insufficient A amount");
        require(amountB >= amountBMin, "Insufficient B amount");

        pool.reserveA = pool.reserveA.sub(amountA);
        pool.reserveB = pool.reserveB.sub(amountB);
        pool.totalLiquidity = pool.totalLiquidity.sub(liquidity);

        liquidityTokens[tokenA][tokenB][msg.sender] = liquidityTokens[tokenA][tokenB][msg.sender].sub(liquidity);

        IERC20(tokenA).transfer(to, amountA);
        IERC20(tokenB).transfer(to, amountB);

        emit LiquidityRemoved(tokenA, tokenB, amountA, amountB);
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        require(deadline >= block.timestamp, "Transaction expired");

        amounts = new uint[](path.length);
        amounts[0] = amountIn;

        for (uint i = 0; i < path.length - 1; i++) {
            address tokenA = path[i];
            address tokenB = path[i + 1];

            Pool storage pool = pools[tokenA][tokenB];
            uint amountOut = getAmountOut(amounts[i], pool.reserveA, pool.reserveB);
            require(amountOut >= amountOutMin, "Insufficient output amount");

            IERC20(tokenA).transferFrom(msg.sender, address(this), amounts[i]);
            IERC20(tokenB).transfer(to, amountOut);

            amounts[i + 1] = amountOut;
            emit TokensSwapped(tokenA, tokenB, amounts[i], amountOut);
        }
    }

    function getPrice(address tokenA, address tokenB) external view returns (uint price) {
        Pool storage pool = pools[tokenA][tokenB];
        require(pool.reserveB > 0, "No liquidity");
        price = pool.reserveA.mul(1e18).div(pool.reserveB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut) {
        require(amountIn > 0, "Invalid amount");
        require(reserveIn > 0 && reserveOut > 0, "Insufficient liquidity");

        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }
}