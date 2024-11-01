// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
/* solhint-disable max-states-count */

/**
 * @title BaseDeployer
 * @dev Base contract for deployment scripts
 */
contract BaseDeployer is Script {
    bytes32 internal counterSalt;

    address internal deployerAddress;

    address internal ownerAddress;

    /// @dev Enumeration of supported chains
    enum Chains {
        kairos,
        kaia
    }

    /// @dev Enumeration of deployment cycles
    enum Cycle {
        Test
    }

    /// @dev Mapping of chain enum to RPC URL
    mapping(Chains => string) public forks;

    /**
     * @dev Sets the environment for deployment based on the given cycle
     * @param cycle The deployment cycle
     */
    modifier setEnvDeploy(Cycle cycle) {
        if (cycle == Cycle.Test) {
            deployerAddress = vm.envAddress("TEST_DEPLOYER_KEY");
            ownerAddress = vm.envAddress("TEST_OWNER_ADDRESS");
        }

        _;
    }

    /**
     * @dev Broadcasts a transaction with the given deployer address
     * @param deployerAddress The address to broadcast the transaction from
     */
    modifier broadcast(address deployerAddress) {
        vm.startBroadcast(deployerAddress);

        _;

        vm.stopBroadcast();
    }

    /**
     * @dev Constructor sets up the RPC URLs for the supported chains
     */
    constructor() {
        forks[Chains.kaia] = "https://public-en.node.kaia.io";
        forks[Chains.kairos] = "https://public-en.kairos.node.kaia.io";
    }

    /**
     * @dev Creates a fork of the given chain
     * @param chain The chain to fork
     */
    function createFork(Chains chain) public {
        vm.createFork(forks[chain]);
    }

    /**
     * @dev Creates and selects a fork of the given chain
     * @param chain The chain to fork and select
     */
    function createSelectFork(Chains chain) public {
        vm.createSelectFork(forks[chain]);
    }
}