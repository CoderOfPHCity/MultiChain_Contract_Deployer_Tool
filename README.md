
# Foundry Multichain 

This repo provides an example of a multichain Solidity Deployment script pattern.

- It uses COMPUTECREATE2ADDRESS to deploy contract  to multiple chains using a single Solidity script. 

- COMPUTECREATE2ADDRESS is used to preserve proxy addresses across multiple chains.


__Before running anything, make sure your .env variables are set. You can use .env-example as a template__


## Running Tests

To build & run tests, run the following command

```bash
  forge test -vvvv 
```


## Examples

### Deploy to testnets 

- __deployCounterTestnet(uint256 \_counterSalt)__

```bash
forge script DeployCounter -s "deployCounterTestnet(uint256)" 1  --force --multi 
```
- add __--broadcast --verify__ to broadcast to network and verify contracts


## License

[MIT](https://choosealicense.com/licenses/mit/)

