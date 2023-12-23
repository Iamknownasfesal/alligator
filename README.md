# Alligator: The Ultimate Dex Aggregator Library


## What is Alligator?

Alligator is designed as a comprehensive solution for traders and liquidity providers within the Sui ecosystem. The DEX Aggregator Module for Alligator aims to enhance the trading experience by aggregating liquidity from various decentralized exchanges (DEXs) on the Sui network. This approach ensures users have access to the best possible trading rates and reduces slippage, thereby maximizing efficiency and user satisfaction.

Check out what is a DEX Aggreator and what is Alligator from our presentation in [GitHub](https://github.com/Iamknownasfesal/alligator/blob/prod/alligator-presentation.pdf)
## Goals

- Provide a comprehensive solution for traders and liquidity providers within the Sui ecosystem.
- Enhance the trading experience by aggregating liquidity from various decentralized exchanges (DEXs) on the Sui network.
- Ensure users have access to the best possible trading rates and reduce slippage, thereby maximizing efficiency and user satisfaction.

## How does it work?

Using Programmable Transaction Blocks in Sui, Alligator will be able to aggregate liquidity from various DEXs on the Sui network. This will be done by using a pathfinding algorithm to find the best possible trading rates and reduce slippage.

Contract is only used for splitting amounts & sending back to receiver.

Backend is not included since time was a bit less, but in the following weeks we want to make the backend and frontend.

## How to test it?

1. Download enviroment: [Sui](https://docs.sui.io/guides/developer/getting-started)
2. Use `sui move test` command to run tests, or check out tests folder for test suits.
