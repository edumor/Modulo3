const hre = require("hardhat");

async function main() {
    // Get the contract factory for SimpleSwap
    const SimpleSwap = await hre.ethers.getContractFactory("SimpleSwap");

    // Deploy the contract
    const simpleSwap = await SimpleSwap.deploy();

    // Wait for the deployment to be completed
    await simpleSwap.deployed();

    console.log("SimpleSwap deployed to:", simpleSwap.address);
}

// Execute the deployment script
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });