Markdown


# Drosera PoC: Flash Loan Cooldown Monitor

## 🧠 Overview
This Drosera **Proof of Concept (PoC)** demonstrates a Sergeant-level **trap** designed to monitor for **time-based logic violations** in smart contracts.

It simulates a protocol that enforces a **5-minute (300-second)** cooldown period between flash loans.  
If a new loan is attempted *before* the cooldown expires, the trap automatically triggers and sends an alert to a dedicated **Response Contract**.

This behavior models real-world **re-entrancy** or **price manipulation** exploit patterns.

---

## ⚙️ Technical Details
This PoC follows the **Simulated Data Template** pattern defined in the [Drosera Testnet Guides](https://github.com/Idle0x/Drosera-Unique-Trap).  
All logic is self-contained — no external protocol dependencies are required.

| Component | Description |
|------------|-------------|
| **Monitors** | Internal variable `simulatedLastLoanTimestamp` |
| **Trigger Condition** | `simulateLoan()` called when `block.timestamp < simulatedLastLoanTimestamp + 300` |
| **Response Action** | Trap calls `logCooldownViolation()` on the Response Contract |
| **Pattern Type** | Time-based Simulation PoC |
| **Role** | Sergeant |

---

## 🌐 Deployment Info

| Parameter | Value |
|------------|--------|
| **Network** | Hoodi Testnet |
| **Chain ID** | `560048` |
| **RPC URL** | `https://rpc.hoodi.ethpandaops.io` |
| **Trap Logic Contract** | `0xC9566C30F741B2Be622FF06891198C82bEC5d2aB` |
| **Response Contract** | `0x58287BCC855a888F8a3D0010Db10EA6572C74d96` |
| **Drosera Trap Config** | `0xB9c9620dDDF1EC575CC09F868FfF78AeCC60b056` |
| **Status** | ✅ **LIVE AND MONITORING** |

---

## 🧩 Contract Overview

### Trap Logic
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IResponse {
    function logCooldownViolation(string calldata message) external;
}

contract CooldownTrap {
    uint256 public simulatedLastLoanTimestamp;
    IResponse public response;

    constructor(address _response) {
        response = IResponse(_response);
        simulatedLastLoanTimestamp = 0;
    }

    /// @dev Sets last loan timestamp to one hour ago (used for testing)
    function initializeTimestamp() external {
        simulatedLastLoanTimestamp = block.timestamp - 3600;
    }

    /// @dev Simulates a flash loan and checks cooldown
    function simulateLoan() external {
        if (block.timestamp < simulatedLastLoanTimestamp + 300) {
            response.logCooldownViolation("Cooldown violated: loan before 300s elapsed");
        } else {
            simulatedLastLoanTimestamp = block.timestamp;
        }
    }
}
````

### Response Contract

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Response {
    event CooldownViolation(address indexed trap, uint256 timestamp, string message);

    function logCooldownViolation(string calldata message) external {
        emit CooldownViolation(msg.sender, block.timestamp, message);
    }
}
```

---

## 🧪 Testing the PoC with `cast`

You can test this live on the **Hoodi Testnet** using [Foundry’s `cast`](https://book.getfoundry.sh/reference/cast/).

### Step 1: Initialize the timestamp

Set the last loan timestamp to one hour ago.

```bash
cast send 0xC9566C30F741B2Be622FF06891198C82bEC5d2aB "initializeTimestamp()" \
  --private-key $YOUR_KEY --rpc-url https://rpc.hoodi.ethpandaops.io
```

✅ Expected: transaction succeeds, state updated.

---

### Step 2: First loan — valid (after cooldown)

```bash
cast send 0xC9566C30F741B2Be622FF06891198C82bEC5d2aB "simulateLoan()" \
  --private-key $YOUR_KEY --rpc-url https://rpc.hoodi.ethpandaops.io
```

✅ Expected: loan allowed, no response triggered.

---

### Step 3: Second loan — violation (before cooldown)

Call again immediately:

```bash
cast send 0xC9566C30F741B2Be622FF06891198C82bEC5d2aB "simulateLoan()" \
  --private-key $YOUR_KEY --rpc-url https://rpc.hoodi.ethpandaops.io
```

⚠️ Expected: the trap calls `logCooldownViolation()` on the Response Contract, emitting an alert event.

---

### Step 4: Verify alert via logs

You can confirm the alert by checking recent events on the Response Contract:

```bash
cast logs 0x58287BCC855a888F8a3D0010Db10EA6572C74d96 --rpc-url https://rpc.hoodi.ethpandaops.io
```

Look for:

```
CooldownViolation(trap=0xC9566C30F741B2Be622FF06891198C82bEC5d2aB, ...)
```

---

## 🔍 Optional: Monitor in Real Time (Node Script)

For developers who want continuous off-chain monitoring:

```js
import { ethers } from "ethers";

const RPC = "https://rpc.hoodi.ethpandaops.io";
const provider = new ethers.providers.JsonRpcProvider(RPC);
const responseAddr = "0x58287BCC855a888F8a3D0010Db10EA6572C74d96";

const abi = [
  "event CooldownViolation(address indexed trap, uint256 timestamp, string message)"
];

const contract = new ethers.Contract(responseAddr, abi, provider);

contract.on("CooldownViolation", (trap, timestamp, message) => {
  console.log("🚨 Cooldown Violation Detected!");
  console.log("Trap:", trap);
  console.log("Time:", new Date(timestamp * 1000).toISOString());
  console.log("Message:", message);
});
```

---

## 🧱 Architecture Summary

```text
 ┌──────────────────────────────┐
 │      CooldownTrap.sol        │
 │ ──────────────────────────── │
 │  simulateLoan()              │
 │  └─ checks 300s rule         │
 │  └─ calls logCooldownViolation() -> │
 └──────────────────────────────┘
                 │
                 ▼
 ┌──────────────────────────────┐
 │       Response.sol           │
 │  Emits CooldownViolation()   │
 │  Provides on-chain alerting  │
 └──────────────────────────────┘
```

---

## 🧩 Recommendations

✧ Use `try/catch` to prevent Response failures from reverting the trap.
✧ Add role-based permissions if traps are upgraded frequently.
✧ Integrate with an off-chain alert system (e.g., Discord, Telegram, or webhooks).
✧ Include automated tests (Foundry or Hardhat) for both valid and violation cases.

---

## 📜 License

This project is licensed under the **MIT License**.

---

## 👤 Author & Credits

Developed by **pottkinto** for the **Drosera Testnet**.
Inspired by the [Drosera Unique Trap Guide](https://github.com/Idle0x/Drosera-Unique-Trap).


