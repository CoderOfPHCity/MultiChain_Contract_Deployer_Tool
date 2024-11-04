# Foundry-Kaia Multichain Deployment
This repository provides an example of a multichain Solidity deployment script pattern using the Foundry development framework.

The primary goal of this project is to demonstrate a reliable and efficient way to deploy Smart Contracts to multiple blockchain networks using a single deployment script. The key features of this approach include:

## Multichain Deployment:

The DeployCounter contract can deploy the Counter contract to multiple chains (e.g., Kaia and Kairos) using a single script.

- CREATE2 Address Preservation: The script uses the `COMPUTECREATE2ADDRESS` opcode to ensure that the deployed contract address is consistent across different chains, enabling seamless integration with other applications.

- Environment-specific Configuration: The deployment script can be configured for different deployment environments (e.g., testnet, mainnet) using the setEnvDeploy modifier and environment variables.

- Logging and Reporting: The script utilizes the console2 library to provide detailed logging of the deployment process, including the computed `CREATE2` address and the deployed contract addresses for each chain.

## Prerequisites
Before running the deployment script, ensure that you have the following setup:

- `Foundry Installation:` Make sure you have Foundry installed and configured on your development machine. Refer to the Foundry documentation for installation instructions.

## Running Tests
To build and run the tests for this project, execute the following command:
```
forge test -vvvv
```
This will run the test suite and provide detailed output.

## Examples

### Deploy to testnets 

- __deployCounterTestnet(uint256 \_counterSalt)__

```bash
forge script DeployCounter -s "deployCounterTestnet(uint256)" 1  --force --multi 
```
add __--broadcast --verify__ to broadcast to network and verify contracts.
This will deploy the Counter contract to both the Kaia and Kairos testnets using the provided salt value of 1.


### Manually deploy
You can also manually deploy the Counter contract to specific networks. Here are the example commands for testnet and mainnet deployments:
Testnet
```
forge create --rpc-url https://public-en.kairos.node.kaia.io --SIGNER  src/Counter.sol:Counter --constructor-args 5
```

Mainnet
```
forge create --rpc-url https://public-en.node.kaia.io --SIGNER src/Counter.sol:Counter --constructor-args 5
```

## License
This project is licensed under the MIT License.

[MIT](https://choosealicense.com/licenses/mit/)

