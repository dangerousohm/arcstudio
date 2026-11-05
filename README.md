# MyCounter on Arc Testnet

A small Solidity project built with Arc Studio to explore contract ownership, state changes, events, and testing. MyCounter stores a public counter that only its current owner can increment.

## How it works

- The counter starts at `0`. Anyone can read it with `number()`.
- The constructor accepts an `initialOwner` and uses OpenZeppelin `Ownable`.
- Only the current owner can call `increment()`. Each successful call adds `1` and emits `Incremented(newValue)`.
- The owner can transfer ownership. Renouncing ownership permanently disables owner-only operations, including incrementing.

## Arc Testnet deployment

The repository deployment metadata records this address:

`0x65f516e881b53b743896e6c7273e05a89a641dff`

[View the contract on Arc Testnet Explorer](https://explorer.testnet.arc.io/address/0x65f516e881b53b743896e6c7273e05a89a641dff?tab=contract)

Read `owner()` on the deployed contract to check its current owner; ownership can change after deployment.

## Repository guide

| Path | Purpose |
| --- | --- |
| `contracts/MyCounter.sol` | Counter contract and owner-only increment operation |
| `contracts/test/MyCounter.t.sol` | Foundry unit and fuzz tests |
| `contracts/contract-metadata/MyCounter.json` | Deployment details and ABI |
| `foundry.toml` | Solidity compiler and Foundry configuration |
| `remappings.txt` | Import mappings for forge-std and OpenZeppelin |
| `src/` | Arc Studio application source |

## Build and test

Install Bun and Foundry first. Refer to `.bun-version` and `.foundry-version` for the project tool versions. From the repository root:

```bash
git clone https://github.com/dangerousohm/arcstudio.git
cd arcstudio
bun install --frozen-lockfile
forge build
forge test --match-contract MyCounterTest -vv
```

Bun installs OpenZeppelin, which Foundry resolves through `remappings.txt`. Foundry uses Solidity `0.8.28` in the checked-in configuration. Local unit tests do not require a wallet or private key.

The test source covers initialization, owner-only increments, event emission, rejected unauthorized calls, ownership transfer, renunciation, and fuzzed callers/increment counts. This README describes the tests present in the repository; it does not claim a fresh test run or independent security audit.

## Scope

This is a testnet learning project. MyCounter does not implement token transfers, payments, or escrow. Keep private keys, tokens, and `.env` files out of commits.
