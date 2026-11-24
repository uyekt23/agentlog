# ⚓ AgentLog

**A daily on-chain logbook for Binance Agent ID holders.**

Every sailor knows the logbook: one entry a day, every day, no gaps.
AgentLog brings that habit on-chain. If you hold a Binance Agent ID
(`name.ai`), you can check in once per UTC day on BNB Chain. The contract
records your total check-ins and your streak — how many days in a row you
showed up.

## Why Agent ID?

Agent ID is the identity layer of the Agentic Wallet ecosystem, but holding
one is passive: you claim it once and it sits in your wallet. AgentLog turns
that identity into a daily ritual and a public, verifiable track record:

- **Access control** — `checkIn()` reverts unless the caller holds an Agent
  ID in the official registry (`0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F`).
  Agent ID is not decoration here; it is the gate, checked on-chain on
  every single call.
- **Identity with history** — a streak is a lightweight reputation signal:
  an Agent ID address with a 30-day logbook streak is demonstrably an
  active, returning participant of the ecosystem, not a dormant claim.
- **A daily reason to return** — streaks create an honest engagement loop
  for the Agent ID ecosystem without points, promises, or farming of
  anyone's funds.

## How it works

| Function | What it does |
| --- | --- |
| `checkIn()` | Records today's check-in. Reverts without an Agent ID, or if already checked in today. |
| `getSailor(address)` | Total check-ins, current streak, longest streak, last check-in day. |
| `canCheckInToday(address)` | Whether an address can check in right now. |
| `totalSailors()` / `totalCheckIns()` / `checkInsOnDay(day)` | Public ecosystem counters. |

Days are counted in UTC (`block.timestamp / 1 days`). A streak continues
when the previous check-in was yesterday, and restarts at 1 otherwise.

## Safety by design

- **No funds** — the contract is not payable and holds nothing.
- **No fees, no token, no approvals** — a check-in is one plain call.
- **No admin functions** — no owner, no pause, no upgrade, no withdrawal.
  The Agent ID registry address is a compile-time constant.
- **Open source** — MIT licensed, source verified on BscScan.

## Deployment (BNB Chain)

- Contract: `AgentLog` — address to be filled in after deployment.
- Compiler: Solidity 0.8.26, optimizer 200 runs.
- Registry: `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` (SPACE ID Agent ID).

## Web app

`web/index.html` is a single static page (ethers.js via CDN): connect a
wallet on BNB Chain, see whether it holds an Agent ID, check in, and watch
your streak. Global counters load read-only without a wallet.

## License

MIT
