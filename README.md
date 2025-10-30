# Drosera PoC: Flash Loan Cooldown Monitor

## Overview
This Drosera trap is a Proof of Concept (PoC) for the Sergeant role. It is designed to monitor a smart contract for time-based logic violations.

Specifically, it simulates a protocol that enforces a 5-minute (300-second) cooldown period on flash loans. This trap will detect and alert if a new loan is taken *before* the cooldown has expired, a common pattern in re-entrancy and price manipulation attacks.

## Technical Details
This PoC follows the **Simulated Data Template** pattern required by the Drosera testnet guides. The logic is self-contained and verifiable without external dApps.

* **Monitors:** An internal `simulatedLastLoanTimestamp` variable within the trap contract itself.
* **Triggers:** The trap triggers if the `simulateLoan()` function is called, and the `block.timestamp` is less than `simulatedLastLoanTimestamp + 300 seconds`.
* **Response:** The trap calls the `logCooldownViolation()` function on the Response Contract, sending an alert message.

## Deployment
* **Network:** Hoodi Testnet (Chain ID: 560048)
* **RPC URL:** `https://rpc.hoodi.ethpandaops.io`

### Contract Addresses
* **Trap Logic Contract:** `0xC9566C30F741B2Be622FF06891198C82bEC5d2aB`
* **Response Contract:** `0x58287BCC855a888F8a3D0010Db10EA6572C74d96`
* **Drosera Trap Config:** `0xB9c9620dDDF1EC575CC09F868FfF78AeCC60b056`

### Status: ✅ LIVE AND MONITORING

---

## How to Test This PoC

You can manually trigger and verify this trap's logic using `cast`.

**1. Initialize the Timestamp:**
This sets the "last loan" time to one hour ago.
```bash
cast send 0xC9566C30F741B2Be622FF06891198C82bEC5d2aB "initializeTimestamp()" --private-key $YOUR_KEY --rpc-url [https://rpc.hoodi.ethpandaops.io](https://rpc.hoodi.ethpandaops.io)
