# Provably Random Raffle Contract

A provably random smart contract lottery using Chainlink VRF and Automation.

## About

This project implements a verifiably random raffle/lottery system on the blockchain with the following features:

- Users can enter the raffle by paying for a ticket 
- After X time period, the raffle automatically draws a winner
- Uses Chainlink VRF (Verifiable Random Function) for provably random winner selection
- Uses Chainlink Automation for automatic execution
- Built using the Foundry framework

## Getting Started

### Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [foundry](https://getfoundry.sh/)

### Installation

```sh
forge install
```

### Build

```sh
forge build
```

### Test

```sh
forge test
```

### Deploy

```sh
forge script script/DeployRaffle.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key>
```

## Usage

1. Deploy contract
2. Fund contract with LINK
3. Users can enter raffle with `enterRaffle()`
4. Wait for Chainlink Automation to call `performUpkeep()`

## Testing

```sh
forge test
```

For unit tests:
```sh
forge test --match-test test*
```

For integration tests:
```sh
forge test --match-test testFork*
```

For gas reports:
```sh
forge snapshot
```

## Security

This project is provided as is. Use at your own risk.

## License

This project is licensed under MIT.