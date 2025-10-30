// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {FlashLoanCooldownTrap} from "../src/FlashLoanCooldownTrap.sol";
import {LoanAlertResponse} from "../src/LoanAlertResponse.sol";

/**
 * @dev This script deploys our two contracts.
 * It follows the "no constructor arguments" rule.
 */
contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy the Response Contract first
        LoanAlertResponse responseContract = new LoanAlertResponse();
        console.log(
            "LoanAlertResponse deployed at:",
            address(responseContract)
        );

        // 2. Deploy the Trap Contract
        FlashLoanCooldownTrap trapContract = new FlashLoanCooldownTrap();
        console.log(
            "FlashLoanCooldownTrap deployed at:",
            address(trapContract)
        );

        // 3. Ownership was removed for simplicity.

        vm.stopBroadcast();
    }
}
