// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title LoanAlertResponse
 * @dev This is our response contract.
 * It receives and stores the alert from our trap.
 * It has NO constructor arguments.
 */
contract LoanAlertResponse is Ownable {
    // We will store the last alert message here for verification
    string public lastAlert;
    uint256 public lastViolationTime;
    uint256 public lastLoanTime;

    event AlertLogged(string message, uint256 lastLoan, uint256 violationTime);

    constructor() Ownable(msg.sender) {}

    /**
     * @dev This is the function our trap will call.
     * The signature (string,uint256,uint256) MUST MATCH
     * the payload from the trap's shouldRespond() function.
     */
    function logCooldownViolation(string memory message, uint256 lastLoan, uint256 violationTime) external {
        // In a real PoC, you would add an access control modifier
        // to ensure only the Drosera operator can call this.

        lastAlert = message;
        lastLoanTime = lastLoan;
        lastViolationTime = violationTime;

        emit AlertLogged(message, lastLoan, violationTime);
    }
}
