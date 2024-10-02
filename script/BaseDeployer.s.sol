// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
/* solhint-disable max-states-count */

contract BaseDeployer is Script {
    bytes32 internal counterSalt;

    uint256 internal deployerPrivateKey;

    address internal ownerAddress;

    enum Chains {
        ArbitrumSepolia,
        BaseSepolia
    }

    enum Cycle {
        Dev,
        Test,
        Prod
    }

    /// @dev Mapping of chain enum to rpc url
    mapping(Chains chains => string rpcUrls) public forks;

    /// @dev environment variable setup for deployment
    /// @param cycle deployment cycle (dev, test, prod)
    modifier setEnvDeploy(Cycle cycle) {
        if (cycle == Cycle.Dev) {
            deployerPrivateKey = vm.envUint("LOCAL_DEPLOYER_KEY");
            ownerAddress = vm.envAddress("LOCAL_OWNER_ADDRESS");
        } else if (cycle == Cycle.Test) {
            deployerPrivateKey = vm.envUint("TEST_DEPLOYER_KEY");
            ownerAddress = vm.envAddress("TEST_OWNER_ADDRESS");
        } else {
            deployerPrivateKey = vm.envUint("DEPLOYER_KEY");
            ownerAddress = vm.envAddress("OWNER_ADDRESS");
        }

        _;
    }

    /// @param pk private key to broadcast transaction
    modifier broadcast(uint256 pk) {
        vm.startBroadcast(pk);

        _;

        vm.stopBroadcast();
    }

    constructor() {
        // Testnet

        forks[Chains.ArbitrumSepolia] = "https://arb-sepolia.g.alchemy.com/v2/xnlSKnxCN-p1DO4ZJSOlohxxxnPYPwpT";
        forks[Chains.BaseSepolia] = "https://base-sepolia.g.alchemy.com/v2/xnlSKnxCN-p1DO4ZJSOlohxxxnPYPwpT";
    }

    function createFork(Chains chain) public {
        vm.createFork(forks[chain]);
    }

    function createSelectFork(Chains chain) public {
        vm.createSelectFork(forks[chain]);
    }
}
