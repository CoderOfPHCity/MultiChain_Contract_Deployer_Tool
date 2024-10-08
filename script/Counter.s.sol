// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

import {BaseDeployer} from "./BaseDeployer.s.sol";

/* solhint-disable no-console*/
import {console2} from "forge-std/console2.sol";

contract DeployCounter is BaseDeployer {
    address private create2addrCounter;

    modifier computeCreate2(bytes32 saltCounter) {
        create2addrCounter = vm.computeCreate2Address(saltCounter, hashInitCode(type(Counter).creationCode));

        _;
    }

    function deployCounterTestnet(uint256 _counterSalt) public setEnvDeploy(Cycle.Test) {
        Chains[] memory deployForks = new Chains[](2);

        counterSalt = bytes32(_counterSalt);

        deployForks[0] = Chains.kaia;
        deployForks[1] = Chains.kairos;

        createDeployMultichain(deployForks);
    }

    /// @dev Deploy contracts to selected chains.
    /// @param _counterSalt The salt for the counter contract.
    function deployCounterSelectedChains(uint256 _counterSalt, Chains[] calldata deployForks, Cycle cycle)
        external
        setEnvDeploy(cycle)
    {
        counterSalt = bytes32(_counterSalt);

        createDeployMultichain(deployForks);
    }

    function createDeployMultichain(Chains[] memory deployForks) private computeCreate2(counterSalt) {
        console2.log("Counter create2 address:", create2addrCounter, "\n");

        for (uint256 i; i < deployForks.length;) {
            string memory chainName = getChainName(deployForks[i]);

            // Log the chain name
            console2.log("Deploying Counter to chain:", chainName, "\n");

            createSelectFork(deployForks[i]);

            chainDeployCounter();

            unchecked {
                ++i;
            }
        }
    }

    function chainDeployCounter() private broadcast(deployerPrivateKey) {
        Counter counter = new Counter{salt: counterSalt}();

        require(create2addrCounter == address(counter), "Address mismatch Counter");

        console2.log("Counter address:", address(counter), "\n");
    }   

    function getChainName(Chains chain) internal pure returns (string memory) {
        if (chain == Chains.kaia) {
            return "Kaia chain";
        } else if (chain == Chains.kairos) {
            return "Kairos chain";
        } else {
            return "Unknown Chain";
        }
    }
}

//forge script DeployCounter -s "deployCounterTestnet(uint256)" 5  --force --multi
// forge verify-contract --chain base-sepolia 0x897d083Af8D10039d48D292b1FC4baf52eE5264D src/Counter.sol:Counter
