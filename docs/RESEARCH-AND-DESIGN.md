# Agent Mint Guard — Riset Teknis & Desain Final
Hackathon: Binance Wallet × BNB Chain Agent ID Hackathon (60.000 USDC)
Deadline submission: 9 Des 2026 08:00 UTC = 15:00 WIB
Status per 26 Nov 2026 ~19:00 WIB: kontrak LOKAL selesai + teruji. BELUM deploy (menunggu persetujuan eksplisit Richard).

## 1. Riset integrasi Agent ID (sumber resmi Binance)

Sumber: pengumuman resmi Binance "Agent ID Hackathon" (binance.com/en/support/announcement/detail/95f5dbe0ea674a48a739b59e046648bf), bagian Developer Resources:

- **Kontrak Agent ID (BNB Chain mainnet): `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F`**
  - Nama kontrak: SPACE ID Agent ID, simbol AI, standar **ERC-721, non-transferable**.
  - Satu user hanya bisa klaim **satu** Agent ID, bentuknya `name.ai`.
  - **Cara cek pemegang (dokumentasi resmi Binance persis): panggil `balanceOf(address)`; nilai > 0 = memegang Agent ID.**
  - Klaim hanya bisa di dalam Binance App: Wallet > banner homepage > Agent ID.
- Pola pemakaian yang dicontohkan Binance sendiri: **access control, payments, identity**.
- Agentic Wallet: wallet MPC keyless yang dioperasikan agent via CLI `baw` (@binance/agentic-wallet); Developer Mode di App diperlukan untuk `contract-call` / `sign-message` eksternal.
- ERC-8004 (standar identitas agent terpisah, BUKAN syarat hackathon ini): Identity Registry BSC mainnet `0x8004A169FB4a3325136EB29fA0ceB6D2e539a432`. Draf GOAT lama menyebut ERC-8004 karena GOAT memintanya; untuk hackathon INI gerbang yang benar adalah kontrak Agent ID SPACE ID di atas. Desain kami memakai gerbang resmi hackathon, dan ERC-8004 dicatat sebagai adapter masa depan, bukan klaim saat ini.

**Verifikasi live yang kami lakukan 26 Nov 2026:**
- `eth_call balanceOf(0xc73442B89bfAd5d330Cc849D82859F4f1f5691AA)` ke kontrak Agent ID resmi via BSC public RPC → **1**. Wallet BAW Richard ("henz.ai") benar-benar memegang Agent ID on-chain.
- `eth_gasPrice` BSC mainnet → `0x2faf080` = **0,05 gwei**.
- `baw wallet status` → **UNCONNECTED** (sesi kedaluwarsa sejak 15 Nov, sesuai catatan; re-pair = langkah Richard di App, nanti).

## 2. Lanskap kompetitor (jujur — supaya tidak duplikat)

Proyek lain di hackathon yang sama sudah terlihat publik:
- **AgentID Guard** — registry atestasi audit kontrak oleh pemegang Agent ID (verdict GO/CAUTION/BLOCK + report hash). Tumpang tindih sebagian dengan fungsi `anchorVerdict` kami.
- **AgentProof** — registry reputasi agent, gate `balanceOf > 0`.
- **OneVoice** — polling 1 Agent ID = 1 suara.
- **Agent Roll Call** — check-in harian; sudah mengklaim 50 Agent ID unik / 118 check-in (melewati ambang Innovation 30).

**Diferensiasi Agent Mint Guard:** tidak ada kompetitor di atas yang menegakkan *kebijakan keamanan eksekusi milik agent itu sendiri* on-chain. Inti kami bukan atestasi/reputasi/polling, melainkan:
1. **Policy registry** — cap nilai per-tx, cap harian, larangan approval/permit, mode allowlist wajib — ditulis on-chain oleh pemegang Agent ID.
2. **Guard penegak (`guardCheckAndRecord`)** — dipanggil SEBELUM agent mengeksekusi mint/transfer; revert bila melanggar kebijakan sendiri, dan mencatat spend harian supaya cap-nya nyata, bukan sekadar saran. Ini pola dari operasi nyata Richard: 134 mint gratis dieksekusi Nov 2026 dengan gerbang 0 value / 0 approval / gas-capped — gerbang yang selama ini hanya hidup off-chain, sekarang jadi kontrak publik yang bisa diverifikasi siapa pun.
3. `anchorVerdict` dipertahankan sebagai fitur pendukung (hasil audit kontrak yang memicu keputusan guard), bukan produk utama.

## 3. Arsitektur v1 (scope ±10 hari — realistis)

Satu kontrak, tanpa dependensi, tanpa owner/admin, tanpa custody dana:

`src/AgentMintGuard.sol` (Solidity 0.8.24, optimizer 200 runs, runtime 5.117 byte)
- `IAgentId.balanceOf` — satu-satunya dependensi eksternal (alamat registry immutable di constructor).
- `setPolicy(maxPerTxWei, maxPerDayWei, forbidApprovals, requireAllowlist)` — gate: Agent ID holder saja.
- `setAllowlist(target, allowed)` / `deactivatePolicy()`
- `checkAction(target, value, requiresApproval)` — view, mengembalikan (allowed, reason 0–5).
- `guardCheckAndRecord(target, value, requiresApproval)` — penegak; revert dengan error spesifik per pelanggaran; mencatat `spentOnDay`.
- `anchorVerdict(target, verdict, score, reportHash)` — atestasi audit.
- Counter publik: `totalUniqueAgentIdInteractors`, `totalGuardChecks`, `totalPoliciesSet`, `attestationCount()` — metrik Pioneer/Innovation transparan on-chain.

Di luar scope v1 (sengaja dipotong): eksekusi mint atas nama user (custody/approval = risiko), resolusi nama .ai on-chain (registry tidak mengekspos resolver nama yang terdokumentasi resmi untuk kontrak pihak ketiga; frontend memakai SDK SPACE ID off-chain bila perlu), ERC-8004 adapter, x402.

## 4. Bukti uji lokal

- `forge test`: **14/14 PASS** (13 uji perilaku + 1 uji ukur deploy). Mencakup: non-holder ditolak di semua fungsi tulis, kebijakan free-only memblok nilai > 0 dan approval, cap per-tx + harian, allowlist, penonaktifan, skor invalid, penghitungan interaktor unik tanpa dobel.
- Tidak ada deploy, tidak ada transaksi mainnet, tidak ada belanja pada tahap ini.
