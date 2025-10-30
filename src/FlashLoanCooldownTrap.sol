// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "lib/drosera-contracts/interfaces/ITrap.sol";

/**
 * @title FlashLoanCooldownTrap (Simulated)
 * @dev This trap simulates monitoring a flash loan cooldown.
 * It is simplified to have no constructor logic for dryrun compatibility.
 */
contract FlashLoanCooldownTrap is ITrap {
    // This is the internal state variable we will read
    uint256 public simulatedLastLoanTimestamp;

    // The cooldown period we are enforcing (5 minutes)
    uint256 public constant COOLDOWN = 300 seconds;

    /**
     * @dev Constructor is empty for drosera dryrun compatibility.
     */
    constructor() {}

    /**
     * @dev Call this ONCE after deploying to set a valid start time.
     * Removed onlyOwner for simplicity.
     */
    function initializeTimestamp() external {
        // We'll allow this to be set multiple times for testing
        simulatedLastLoanTimestamp = block.timestamp - 1 hours;
    }

    /**
     * @dev This function collects data.
     */
    function collect() external view override returns (bytes memory) {
        uint256 lastLoan = simulatedLastLoanTimestamp;
        uint256 currentBlockTime = block.timestamp; // FIX: Was uint264

        // We pass both values to the shouldRespond function
        return abi.encode(lastLoan, currentBlockTime);
    }

    /**
     * @dev This function analyzes data. It MUST be pure.
     */
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        (uint256 lastLoan, uint256 currentBlockTime) =
            abi.decode(
                data[0],
                (uint256, uint256) // FIX: Was uint264
            );

        // Check for the violation:
        if (lastLoan != 0 && currentBlockTime < (lastLoan + COOLDOWN)) {
            // FIX: Removed uint264 casts
            // VIOLATION DETECTED!
            string memory alertMessage = "CRITICAL_ALERT: Flash Loan Cooldown Violated!";
            return (true, abi.encode(alertMessage, lastLoan, currentBlockTime));
        }

        return (false, bytes(""));
    }

    /**
     * @dev This is the helper function to test our trap.
     * Removed onlyOwner for simplicity.
     */
    function simulateLoan() external {
        simulatedLastLoanTimestamp = block.timestamp;
    }
}
