const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SimpleSwap", function () {
    let SimpleSwap;
    let simpleSwap;
    let tokenA;
    let tokenB;
    let owner;
    let addr1;
    let addr2;

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();

        const Token = await ethers.getContractFactory("ERC20Mock");
        tokenA = await Token.deploy("Token A", "TKNA", ethers.utils.parseEther("10000"));
        tokenB = await Token.deploy("Token B", "TKNB", ethers.utils.parseEther("10000"));

        SimpleSwap = await ethers.getContractFactory("SimpleSwap");
        simpleSwap = await SimpleSwap.deploy();
    });

    describe("Add Liquidity", function () {
        it("should add liquidity correctly", async function () {
            await tokenA.connect(owner).approve(simpleSwap.address, ethers.utils.parseEther("1000"));
            await tokenB.connect(owner).approve(simpleSwap.address, ethers.utils.parseEther("1000"));

            await simpleSwap.addLiquidity(
                tokenA.address,
                tokenB.address,
                ethers.utils.parseEther("1000"),
                ethers.utils.parseEther("1000"),
                0,
                0,
                owner.address,
                Math.floor(Date.now() / 1000) + 60
            );

            const balance = await simpleSwap.balanceOf(owner.address);
            expect(balance).to.be.gt(0);
        });
    });

    describe("Remove Liquidity", function () {
        it("should remove liquidity correctly", async function () {
            await tokenA.connect(owner).approve(simpleSwap.address, ethers.utils.parseEther("1000"));
            await tokenB.connect(owner).approve(simpleSwap.address, ethers.utils.parseEther("1000"));

            await simpleSwap.addLiquidity(
                tokenA.address,
                tokenB.address,
                ethers.utils.parseEther("1000"),
                ethers.utils.parseEther("1000"),
                0,
                0,
                owner.address,
                Math.floor(Date.now() / 1000) + 60
            );

            const liquidity = await simpleSwap.balanceOf(owner.address);
            await simpleSwap.removeLiquidity(
                tokenA.address,
                tokenB.address,
                liquidity,
                0,
                0,
                owner.address,
                Math.floor(Date.now() / 1000) + 60
            );

            const balanceA = await tokenA.balanceOf(owner.address);
            const balanceB = await tokenB.balanceOf(owner.address);
            expect(balanceA).to.be.gt(0);
            expect(balanceB).to.be.gt(0);
        });
    });

    describe("Swap Tokens", function () {
        it("should swap tokens correctly", async function () {
            await tokenA.connect(owner).approve(simpleSwap.address, ethers.utils.parseEther("1000"));
            await tokenB.connect(owner).approve(simpleSwap.address, ethers.utils.parseEther("1000"));

            await simpleSwap.addLiquidity(
                tokenA.address,
                tokenB.address,
                ethers.utils.parseEther("1000"),
                ethers.utils.parseEther("1000"),
                0,
                0,
                owner.address,
                Math.floor(Date.now() / 1000) + 60
            );

            await simpleSwap.swapExactTokensForTokens(
                ethers.utils.parseEther("100"),
                0,
                [tokenA.address, tokenB.address],
                owner.address,
                Math.floor(Date.now() / 1000) + 60
            );

            const balanceB = await tokenB.balanceOf(owner.address);
            expect(balanceB).to.be.gt(0);
        });
    });

    describe("Get Price", function () {
        it("should return the correct price", async function () {
            await tokenA.connect(owner).approve(simpleSwap.address, ethers.utils.parseEther("1000"));
            await tokenB.connect(owner).approve(simpleSwap.address, ethers.utils.parseEther("1000"));

            await simpleSwap.addLiquidity(
                tokenA.address,
                tokenB.address,
                ethers.utils.parseEther("1000"),
                ethers.utils.parseEther("1000"),
                0,
                0,
                owner.address,
                Math.floor(Date.now() / 1000) + 60
            );

            const price = await simpleSwap.getPrice(tokenA.address, tokenB.address);
            expect(price).to.be.gt(0);
        });
    });

    describe("Get Amount Out", function () {
        it("should calculate the correct amount out", async function () {
            const amountOut = await simpleSwap.getAmountOut(
                ethers.utils.parseEther("100"),
                ethers.utils.parseEther("1000"),
                ethers.utils.parseEther("1000")
            );
            expect(amountOut).to.be.gt(0);
        });
    });
});