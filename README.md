# EIP Author NFT

An ERC1155 NFT collection for rewarding authors of EIPs included in Ethereum network upgrades. Each `tokenId` represents a specific Network Upgrade and claimable by verifying the author's GitHub username cited in the EIP considered for inclusion.

### Deployed on

| Network | Address |
| ------- | ------- |
| Base Mainnet | [0xD5763b8044dc4998737A8D506e612B3BF2821cf9](https://basescan.org/token/0xd5763b8044dc4998737a8d506e612b3bf2821cf9) |


### Claimable for
All authors of EIPs included in the following Network Upgrades:
- **Pectra**: Check you eligibility and claim on [ethcatherders.com](https://www.ethcatherders.com/upgrades/pectra)

## Usage

The smart contracts are built and tested with [Foundry](https://book.getfoundry.sh/).

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
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
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
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
