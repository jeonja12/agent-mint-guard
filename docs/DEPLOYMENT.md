# Deployment Record — Agent Mint Guard (BNB Chain mainnet)

Deployed 26 Nov 2026, path A (Binance Agentic Wallet "henz"), approved by Richard
("Deploy, jalan — jalur A", 26 Nov 20:54 WIB; top-up confirmed 21:26 WIB).

## Contract
- **Address: `0x521dc2568015cAc76e6f773A231f88d69ea5537b`**
- BscScan: https://bscscan.com/address/0x521dc2568015cAc76e6f773A231f88d69ea5537b
- Runtime size: 5,117 bytes (matches local build exactly)
- `agentIdRegistry()` = `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` (official SPACE ID Agent ID)
- `isAgentIdHolder(0xc73442B8…91AA)` = true (henz.ai)

## How it was deployed (transparent)
BAW `contract-call` cannot send a bare CREATE transaction (a preview to the zero
address parses as a plain call, not a creation — that preview was NOT executed).
Deployment therefore used the canonical **Arachnid CREATE2 proxy**
`0x4e59b44847b379578588920cA78FbF26c0B4956C` (on BSC since 2019), called from the
BAW henz wallet via `baw contract-call` (Developer Mode on, preview clean:
simulation OK, no risks, no authority changes):
- Salt: `0xc73442b89bfad5d330cc849d82859f4f1f5691aa4167656e7447756172643031`
  (BAW address + "AgentGuard01")
- **Deploy tx: `0xc6e488552be32e6c07c114208fb3305a82347d67606c94e0fac26eb6c6284aed`**
- Block: 135,862,587 · Status: success · Gas used: **1,165,153**
  (local direct-CREATE measurement was 1,162,489; +2,664 is the proxy overhead)
- Cost at 0.05 gwei ≈ 0.0000583 BNB (estimate; BscScan shows the actual deploy tx fee as
  0.000104623513121094 BNB — effective gas price ≈ 0.09 gwei)
- **BscScan labels the sender "henz.ai"** on the deploy tx page (screenshot from Richard,
  26 Nov 22:27 WIB) — public proof the deployment came from the Agent ID wallet.

## Verification
- **Sourcify: exact_match (creation + runtime), matchId 60003997, verified 2026-11-26T14:30:33Z**
  https://sourcify.dev/#/lookup/0x521dc2568015cAc76e6f773A231f88d69ea5537b
- **BscScan: "Source Code Verified — Exact Match"** on the Contract tab (green check),
  contract name AgentMintGuard, compiler v0.8.24+commit.e11b9ed9, optimizer 200 runs,
  cancun — confirmed via Richard's own screenshot, 26 Nov 22:33 WIB. BscScan also labels
  the deployer "henz.ai" and decoded the first setPolicy call. ALL technical submission
  requirements are now met.

## First interactions — all from henz.ai (BAW 0xc73442B8…91AA)
1. `setPolicy(0, 0, true, false)` — free-only policy
   tx `0x50a9ef5c00244466d7d4f7845cd3c168d7b0b84bfa988a5b9a79a1ba467cbd79`
   On-chain read-back: active=true, caps 0/0, forbidApprovals=true.
2. `guardCheckAndRecord(registry, 0, false)` — first guard check
   tx `0xe0cc29cf4bc799f6da98d243ccf960c51e8772e6a64837a6351ca1523e4d28d5`
3. `anchorVerdict(registry, GO, 90, 0xd0ac6588…7125a)` — first attestation
   tx `0x1b6a79f1d9de1631d82aa3e5fa8698428670abb77838856893ee5d1564567aaf`
   Read-back: attestation 0 = agent henz, target registry, verdict GO, score 90.

Counters after first interactions: unique Agent ID interactors **1**,
guard checks **1**, policies set **1**, attestations **1**.

## Wallet state
- BAW BNB before deploy: 0.002630136712954295 BNB (after Richard's 0.0016 BNB top-up)
- BAW BNB after all 4 transactions: **0.002498044806836665 BNB**
- **Total wallet spend for deploy + 3 interactions: 0.00013209190611763 BNB** (balance delta;
  receipts: deploy 1,165,153 gas, setPolicy 145,884, guard check 68,668 — an earlier
  in-chat estimate of ~0.0000721 BNB was based on an intermediate balance read and is superseded)
- Developer Mode: ON (expires 2026-12-03) · BAW session: CONNECTED (until 2026-11-28 21:07 WIB inactive-signout)
