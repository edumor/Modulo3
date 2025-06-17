module.exports = {
  solidity: "0.8.0",
  networks: {
    hardhat: {},
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/YOUR_INFURA_PROJECT_ID",
      accounts: ["YOUR_WALLET_PRIVATE_KEY"]
    }
  }
};