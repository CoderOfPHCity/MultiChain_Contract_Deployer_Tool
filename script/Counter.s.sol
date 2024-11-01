

// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

import {BaseDeployer} from "./BaseDeployer.s.sol";

/* solhint-disable no-console*/
import {console2} from "forge-std/console2.sol";

/**
 * @title DeployCounter
 * @dev Deployment script for the Counter contract
 */
contract DeployCounter is BaseDeployer {
    address private create2addrCounter;

    /**
     * @dev Computes the CREATE2 address for the Counter contract
     * @param saltCounter The salt to use for the CREATE2 address
     */
    modifier computeCreate2(bytes32 saltCounter) {
        create2addrCounter = vm.computeCreate2Address(saltCounter, hashInitCode(type(Counter).creationCode));

        _;
    }

    /**
     * @dev Deploys the Counter contract to the test environment
     * @param _counterSalt The salt to use for the Counter contract
     */
    function deployCounterTestnet(uint256 _counterSalt) public setEnvDeploy(Cycle.Test) {
        Chains[] memory deployForks = new Chains[](2);

        counterSalt = bytes32(_counterSalt);

        deployForks[0] = Chains.kaia;
        deployForks[1] = Chains.kairos;

        createDeployMultichain(deployForks);
    }

    /**
     * @dev Deploys the Counter contract to the selected chains
     * @param _counterSalt The salt to use for the Counter contract
     * @param deployForks The chains to deploy the Counter contract to
     * @param cycle The deployment cycle
     */
    function deployCounterSelectedChains(uint256 _counterSalt, Chains[] calldata deployForks, Cycle cycle)
        external
        setEnvDeploy(cycle)
    {
        counterSalt = bytes32(_counterSalt);

        createDeployMultichain(deployForks);
    }

    /**
     * @dev Deploys the Counter contract to the selected chains
     * @param deployForks The chains to deploy the Counter contract to
     */
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

    /**
     * @dev Deploys the Counter contract to the current chain
     */
    function chainDeployCounter() private broadcast(deployerAddress) {
        Counter counter = new Counter{salt: counterSalt}();

        require(create2addrCounter == address(counter), "Address mismatch Counter");

        console2.log("Counter address:", address(counter), "\n");
    }

    /**
     * @dev Gets the name of the chain based on the Chains enum
     * @param chain The chain to get the name for
     * @return The name of the chain
     */
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