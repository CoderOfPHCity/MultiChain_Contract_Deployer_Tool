// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract Counter {
    uint256 public number;
    address public owner;

    /* ========== ERRORS ========== */
    error NotOwner();

    /* ========== MODIFIERS ========== */

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /* ========== FUNCTIONS ========== */

    function initialize(address _owner) public {
        owner = _owner;
    }

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }
}
