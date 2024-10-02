// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // Import IERC20 interface
import "./ChainFiVault.sol";
//import "./ChainFiVaultAggregator.sol";
//import "./ChainFiEcosystemDao.sol";
//import "./ChainFiIdentification.sol";
//import "wormhole-solidity-sdk/WormholeRelayerSDK.sol"; // Import Wormhole Relayer

contract ChainFiVaultFactory {
   // EcosystemDAO public ecosystemDao;
   // ChainFiVaultAggregator public aggregator;
  //  ChainFiIdentification public chainFiIdentification;
   // WormholeRelayer public wormholeRelayer; // Wormhole Relayer instance
    IERC20 public token;  // ERC20 token to be used for airdrop
    uint256 public airdropAmount = 5000 * 10 ** 18;  // Airdrop amount, assuming token has 18 decimals
    address public initialOwner;
    mapping(address => address) public userVaults;  // Mapping to store user's vault on the base chain
    mapping(address => mapping(uint16 => bool)) public isDeployedOnChain; // Mapping to track deployment on chains

    struct ChainInfo {
        uint16 officialChainId;  // Your current chain ID
        uint16 wormholeChainId;  // Wormhole specific chain ID
        string apiUrl;
    }

    ChainInfo[] public supportedChains;
     bytes32 salt = keccak256("ChainFiVaultDeploymentSalt");
      address public chainFiVaultImplementation;

    event VaultCreated(address indexed vaultAddress, address indexed user);
    event VaultDeployedOnChain(address indexed vaultAddress, address indexed user, uint16 chainId);
    event AirdropSent(address indexed vaultAddress, uint256 amount);

    modifier onlyInitialOwner() {
        require(msg.sender == initialOwner, "Only the initial owner can perform this action");
        _;    
    }

    modifier onlyDAO() {
        require(
            ecosystemDao.hasRole(ecosystemDao.ADMIN_ROLE(), msg.sender) || msg.sender == address(ecosystemDao),
            "Only the DAO can perform this action"
        );
        _;    
    }

    constructor(address _ecosystemDao, address _initialOwner, address _chainFiIdentification, address _wormholeRelayer, IERC20 _token) {
       // ecosystemDao = EcosystemDAO(payable(_ecosystemDao));
        initialOwner = _initialOwner;
        //chainFiIdentification = ChainFiIdentification(_chainFiIdentification);
       // wormholeRelayer = WormholeRelayer(_wormholeRelayer);
        token = _token; // Initialize the ERC20 token

        // Initialize with the provided testnet APIs, official chain IDs, and Wormhole chain IDs
        supportedChains.push(ChainInfo(11155111, 2, "https://eth-sepolia.g.alchemy.com/v2/5Lh_PH3z8kDRIdVWmcaST3PWKDsT8f-5")); // Ethereum Sepolia
        supportedChains.push(ChainInfo(11155420, 3, "https://opt-sepolia.g.alchemy.com/v2/5Lh_PH3z8kDRIdVWmcaST3PWKDsT8f-5")); // Optimism Sepolia
        supportedChains.push(ChainInfo(421614, 4, "https://arb-sepolia.g.alchemy.com/v2/5Lh_PH3z8kDRIdVWmcaST3PWKDsT8f-5")); // Arbitrum Sepolia
        supportedChains.push(ChainInfo(84532, 5, "https://base-sepolia.g.alchemy.com/v2/5Lh_PH3z8kDRIdVWmcaST3PWKDsT8f-5")); // Base Sepolia
        deployImplementation();
    }

    function setEcosystemDao(address _ecosystemDao) external onlyInitialOwner {
        ecosystemDao = EcosystemDAO(payable(_ecosystemDao));
    }

    function setAggregator(address _aggregator) external onlyInitialOwner {
        aggregator = ChainFiVaultAggregator(_aggregator);
    }

    function setChainFiIdentification(address _chainFiIdentification) external onlyInitialOwner {
        chainFiIdentification = ChainFiIdentification(_chainFiIdentification);
    }

    function setWormholeRelayer(address _wormholeRelayer) external onlyInitialOwner {
        wormholeRelayer = WormholeRelayer(_wormholeRelayer);
    }

    function setTokenAddress(IERC20 _token) external onlyInitialOwner {
        token = _token;  // Update the token address if needed
    }

    // Add a new supported chain
    function addSupportedChain(uint16 officialChainId, uint16 wormholeChainId, string memory apiUrl) external onlyDAO {
        supportedChains.push(ChainInfo(officialChainId, wormholeChainId, apiUrl));
    }

    // Remove a supported chain
    function removeSupportedChain(uint16 officialChainId) external onlyDAO {
        for (uint i = 0; i < supportedChains.length; i++) {
            if (supportedChains[i].officialChainId == officialChainId) {
                supportedChains[i] = supportedChains[supportedChains.length - 1];
                supportedChains.pop();
                break;
            }
        }
    }

    // Get the list of supported chains
    function getSupportedChains() external view returns (ChainInfo[] memory) {
        return supportedChains;
    }

        function deployImplementation() public {
        require(msg.sender == initialOwner, "Only the initial owner can deploy the implementation");
        chainFiVaultImplementation = address(new ChainFiVault{salt: salt}());
        emit ImplementationDeployed(chainFiVaultImplementation);
    }

    function createOrAddChainsToVault( uint16[] memory selectedChains) external payable returns (address) {
        require(selectedChains.length > 0, "At least one chain must be selected");
      //  require(chainFiIdentification.isUserVerified(msg.sender), "User is not verified");

        address vaultAddress;

        if (userVaults[msg.sender] == address(0)) {
            // Deploy on Base if the vault does not exist
            vaultAddress = _deployOnBase( msg.sender);
            _airdropTokens(vaultAddress);  // Airdrop tokens when creating a vault
        } else {
            vaultAddress = userVaults[msg.sender];
        }

        // Deploy on other selected chains using Wormhole Relayer
        for (uint i = 0; i < selectedChains.length; i++) {
            require(_isSupportedChain(selectedChains[i]), "Selected chain is not supported");

            if (!isDeployedOnChain[vaultAddress][selectedChains[i]]) {
                _deployOnChain(selectedChains[i], chainFiVaultImplementation, msg.sender, vaultAddress);
            }
        }

        return vaultAddress;
    }

    function _deployOnBase(address user) internal returns (address) {
      //  bytes32 salt = _generateSalt(user);
        address baseVault = Clones.cloneDeterministic(chainFiVaultImplementation, salt);
        ChainFiVault(baseVault).initialize(user);

        userVaults[user] = baseVault;
        isDeployedOnChain[baseVault][11155111] = true;  // Assuming Base chain ID is 11155111
      //  aggregator.addVaultForUser(user, baseVault);

        emit VaultCreated(baseVault, user);

        return baseVault;
    }

    function _deployOnChain(uint16 officialChainId, address user, address vaultAddress) internal {
        uint16 wormholeChainId = _getWormholeChainId(officialChainId);
        // Using Wormhole Relayer to deploy the vault on the specific chain
        wormholeRelayer.relayContract(wormholeChainId, chainFiVaultImplementation, abi.encodeWithSignature("initialize(address)", user));

        // Mark the chain as deployed
        isDeployedOnChain[vaultAddress][officialChainId] = true;

        emit VaultDeployedOnChain(vaultAddress, user, officialChainId);
    }

    // New function to handle the token airdrop
    function _airdropTokens(address vaultAddress) internal {
        require(token.balanceOf(address(this)) >= airdropAmount, "Not enough tokens for airdrop");
        token.transfer(vaultAddress, airdropAmount);
        emit AirdropSent(vaultAddress, airdropAmount);
    }

    function _isSupportedChain(uint16 officialChainId) internal view returns (bool) {
        for (uint i = 0; i < supportedChains.length; i++) {
            if (supportedChains[i].officialChainId == officialChainId) {
                return true;
            }
        }
        return false;
    }

    function _getWormholeChainId(uint16 officialChainId) internal view returns (uint16) {
        for (uint i = 0; i < supportedChains.length; i++) {
            if (supportedChains[i].officialChainId == officialChainId) {
                return supportedChains[i].wormholeChainId;
            }
        }
        revert("Chain ID not supported");
    }

    function getVaultByUser(address user) external view returns (address) {
        address baseVault = userVaults[user];
        if (baseVault == address(0)) {
            return address(0);
        }

        // Check if the vault is deployed on all supported chains
        for (uint i = 0; i < supportedChains.length; i++) {
            uint16 officialChainId = supportedChains[i].officialChainId;
            if (!isDeployedOnChain[baseVault][officialChainId]) {
                bytes memory response = wormholeRelayer.queryContract(supportedChains[i].wormholeChainId, baseVault, abi.encodeWithSignature("isDeployed()"));
                if (abi.decode(response, (bool))) {
                    isDeployedOnChain[baseVault][officialChainId] = true;
                }
            }
        }

        return baseVault;
    }

    function predictVaultAddress(address implementation, bytes32 salt) external view returns (address) {
        return Clones.predictDeterministicAddress(implementation, salt, address(this));
    }

    function _generateSalt(address user) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(user));
    }
}