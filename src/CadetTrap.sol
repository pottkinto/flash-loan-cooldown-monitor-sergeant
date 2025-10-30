// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// FIX: Import the INTERFACE 'ITrap', not the contract 'Trap'
import {ITrap} from "lib/drosera-contracts/interfaces/ITrap.sol";

interface IMockResponse {
    function isActive() external view returns (bool);
}

// FIX: Inherit from the INTERFACE 'ITrap'
contract CadetTrap is ITrap {
    address public constant RESPONSE_CONTRACT = 0x25E2CeF36020A736CF8a4D2cAdD2EBE3940F4608;
    string constant DISCORD_NAME = "esther_onchain"; // Your Discord username

    // FIX: Add 'override' keyword
    function collect() external view override returns (bytes memory) {
        bool active = IMockResponse(RESPONSE_CONTRACT).isActive();
        return abi.encode(active, DISCORD_NAME);
    }

    // FIX: Add 'override' keyword
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        (bool active, string memory name) = abi.decode(data[0], (bool, string));
        if (!active || bytes(name).length == 0) {
            return (false, bytes(""));
        }

        return (true, abi.encode(name));
    }
}
