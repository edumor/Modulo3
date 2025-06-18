# SimpleSwap

SimpleSwap is a decentralized exchange protocol that allows users to add and remove liquidity, swap tokens, and retrieve token prices without relying on external protocols like Uniswap. This project implements a smart contract that replicates core functionalities of a decentralized exchange.

## Features

- **Add Liquidity**: Users can add liquidity to a token pair by depositing two different ERC-20 tokens.
- **Remove Liquidity**: Users can withdraw their liquidity from the pool, receiving the underlying tokens back.
- **Token Swapping**: Users can swap one token for another at a specified rate.
- **Price Retrieval**: Users can obtain the price of one token in terms of another.
- **Amount Calculation**: Users can calculate how many tokens they will receive when swapping.

## Project Structure

```
SimpleSwap
├── contracts
│   └── SimpleSwap.sol        # Smart contract implementation
├── scripts
│   └── deploy.js             # Deployment script for the contract
├── test
│   └── SimpleSwap.test.js    # Test cases for the contract
├── package.json               # NPM configuration file
├── hardhat.config.js          # Hardhat configuration settings
└── README.md                  # Project documentation
```

## Installation

To get started with the SimpleSwap project, follow these steps:

1. Clone the repository:
   ```
   git clone <repository-url>
   cd SimpleSwap
   ```

2. Install the dependencies:
   ```
   npm install
   ```

## Deployment

To deploy the SimpleSwap contract, run the following command:

```
npx hardhat run scripts/deploy.js --network <network-name>
```

Replace `<network-name>` with the desired blockchain network (e.g., sepolia).

## Testing

To run the test cases for the SimpleSwap contract, use the following command:

```
npx hardhat test
```

## Usage

After deploying the contract, you can interact with it using the provided functions:

- `addLiquidity`: Add liquidity to the pool.
- `removeLiquidity`: Remove liquidity from the pool.
- `swapExactTokensForTokens`: Swap one token for another.
- `getPrice`: Get the price of a token in terms of another.
- `getAmountOut`: Calculate the amount of tokens received in a swap.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.