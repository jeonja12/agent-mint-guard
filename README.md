# Agent Mint Guard

On-chain safety policies for AI agents on BNB Chain, gated by Binance Agent ID (.ai).
Built for the **Binance Wallet × BNB Chain Agent ID Hackathon** (submissions close 9 Dec 2026, 15:00 WIB).

## Status (26 Nov 2026)
- ✅ Contract written + **14/14 Foundry tests pass** locally
- ✅ Exact deployment gas measured: **1,162,489 gas** (≈ 0.00005812 BNB ≈ $0.03 at 0.05 gwei)
- ⛔ **NOT deployed yet** — deployment needs the builder's explicit approval (real BNB gas + wallet re-pair). See `docs/DEPLOY-PLAN.md`.

## What it does
An Agent ID holder registers a safety policy on-chain (per-tx value cap, daily cap,
approval/permit ban, optional target allowlist). Before executing a mint/transfer, the
agent calls `guardCheckAndRecord(...)` — the contract reverts if the action violates the
agent's own policy and records daily spend. Audit verdicts (GO/CAUTION/BLOCK + report hash)
can be anchored under the agent's Agent ID identity.

Agent ID integration is a hard gate, not a badge: every write requires
`balanceOf(msg.sender) > 0` on the official SPACE ID Agent ID contract
`0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` (per Binance's official developer resources).

The contract holds no funds, takes no custody, grants no approvals, and has no owner/admin.

## Layout
- `src/AgentMintGuard.sol` — the contract (Solidity 0.8.24, no dependencies)
- `test/` — dependency-free Foundry tests + gas measurement
- `script/Deploy.s.sol` — canonical deploy record (official registry as constructor arg)
- `frontend/index.html` — static website (GitHub Pages-ready, reads live stats via ethers)
- `docs/RESEARCH-AND-DESIGN.md` — official-source research, competitor landscape, architecture
- `docs/DEPLOY-PLAN.md` — exact gas, wallet options, step-by-step deploy + BscScan verification
- `docs/SUBMISSION-DRAFT.md` — ready-to-paste hackathon submission materials
- `docs/OUTREACH-30.md` — honest plan for the 30-Agent-ID interaction threshold

## Run tests
```
forge test          # 14/14
forge test --gas-report
```

## Background
The off-chain version of these gates ran live in Nov 2026: 134 free mints executed on
BNB Chain with 0 approvals and 0 token payments. Agent Mint Guard makes those rules
public, verifiable, and reusable by any Agent ID holder.
