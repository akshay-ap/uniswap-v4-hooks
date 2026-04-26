## Points Hook

A Uniswap v4 hook that awards points to liquidity providers after each swap.

## Prerequisites

[Foundry](https://book.getfoundry.sh/) must be installed.

## Environment Variables

Copy `.env` and fill in the values:

```shell
$ cp .env.example .env
```

| Variable | Description |
|---|---|
| `PRIVATE_KEY` | Deployer private key (with `0x` prefix) |
| `RPC_URL` | RPC endpoint (e.g. Alchemy or Infura URL) |
| `ETHERSCAN_API_KEY` | Etherscan API key for contract verification |
| `POOL_MANAGER` | Address of the Uniswap v4 PoolManager on the target network |

Load the vars before running any commands:

```shell
$ source .env
```

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test --match-path "test/PointsHook.t.sol" -vv
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/DeployPointsHook.s.sol:DeployPointsHook \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $ETHERSCAN_API_KEY
```

### Deploy with Fork

```shell
$ forge script script/DeployPointsHook.s.sol:DeployPointsHook \
    --fork-url $RPC_URL \
    --fork-block-number $BLOCK_NUMBER \
    --private-key $PRIVATE_KEY \
    --broadcast
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

### Deployments

| Network | Address |
|---|---|
| Sepolia | [0x81c0405ed9d01efcccecd08dfee19c5df09ac040](https://sepolia.etherscan.io/address/0x81c0405ed9d01efcccecd08dfee19c5df09ac040#code) |