# Draf Materi Submission — Binance Agent ID Hackathon
Isi ke form "Submit Project" Binance selama periode submission (tutup 9 Des 2026 15:00 WIB).
Kolom bertanda [SETELAH DEPLOY] diisi sesudah kontrak live & terverifikasi.

## Project name
Agent Mint Guard

## Tagline (EN)
On-chain safety policies for AI agents: your agent's spending caps, approval bans and allowlists — enforced by a BNB Chain contract, gated by your Binance Agent ID.

## Website
[SETELAH DEPLOY] GitHub Pages dari repo publik (frontend/index.html di repo ini adalah sumbernya).

## Contract address(es) — BNB Chain
[SETELAH DEPLOY] AgentMintGuard: 0x… (BscScan: verified, open-source, Solidity 0.8.24)
Agent ID registry yang dipakai (resmi, bukan milik kami): 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F

## Agent ID usage description (EN — siap tempel)

Agent Mint Guard actively uses Binance Agent ID as its identity and access-control layer:

1. **Access control (on-chain, every write):** Every state-changing function — setting a safety policy, updating an allowlist, running a guard check, anchoring an audit verdict — requires `balanceOf(msg.sender) > 0` on the official SPACE ID Agent ID contract (0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F, ERC-721, non-transferable). Anonymous wallets cannot use the protocol at all.
2. **Identity:** Policies and attestations are keyed by the Agent ID holder's address. Because an Agent ID is non-transferable and limited to one per user, one operator = one verifiable policy identity.
3. **Payments safety (the use case):** Before an agent executes a mint or transfer, it calls `guardCheckAndRecord(target, value, requiresApproval)`. The contract reverts if the action violates the operator's own on-chain policy — per-transaction value cap, daily value cap, a ban on token approvals/permits, or a mandatory target allowlist. The canonical free-mint policy (0 value, 0 approvals) is exactly how the builder's own agent executed 134 free mints on BNB Chain in November 2026; Agent Mint Guard turns those off-chain rules into a public, verifiable contract any agent can adopt.
4. **Accountability:** Guard checks and contract-audit verdicts (GO / CAUTION / BLOCK + report hash) are anchored on-chain under the agent's Agent ID identity, and the contract publicly counts unique interacting Agent ID addresses.

The contract holds no funds, takes no custody, grants no approvals, and has no owner or admin.

## Deskripsi proyek (ID, untuk X / komunitas)

Agent Mint Guard memindahkan aturan keamanan agent AI ke on-chain BNB Chain. Pemegang Agent ID (.ai) mendaftarkan kebijakannya — batas belanja per transaksi & per hari, larangan approval, daftar kontrak yang diizinkan — lalu agent wajib melewati kontrak penjaga sebelum mengeksekusi mint/transfer apa pun. Langgar aturan = transaksi revert. Semua tercatat publik dan terikat pada identitas Agent ID yang tidak bisa dipindahtangankan.

## Kategori yang dituju
- **Innovation Award (utama):** dinilai juri (feasibility, practicality, innovation, completion) + syarat minimal 30 alamat Agent ID berinteraksi. Produk kami menyelesaikan masalah nyata dari operasi agent yang benar-benar berjalan.
- Pioneer Award tidak ditargetkan secara khusus (itu peringkat volume aktivitas; metrik kami tetap tercatat on-chain dan akan terlihat apa adanya).

## Traction yang JUJUR (boleh dipakai juri)
- Gerbang keamanan versi off-chain dari proyek ini sudah dipakai live: 134 mint gratis dieksekusi di BNB Chain (Nov 2026), 0 approval, 0 pembayaran token.
- Kontrak: 14/14 test Foundry lulus; biaya deploy terukur 1.162.489 gas (≈ $0,03 pada gas 0,05 gwei).
- [SETELAH DEPLOY] Jumlah interaktor Agent ID unik: angka dari `totalUniqueAgentIdInteractors` — tulis apa adanya, jangan dibulatkan ke atas.

## Yang masih kurang sebelum submit (checklist)
- [ ] Persetujuan deploy dari Richard + jalur deploy (BAW re-pair / Rabby).
- [ ] Kontrak live di BSC mainnet + verifikasi BscScan.
- [ ] Repo GitHub publik + website GitHub Pages live.
- [ ] Interaksi pertama oleh henz.ai tercatat.
- [ ] ≥30 interaktor Agent ID unik (lihat OUTREACH-30.md) — untuk kelayakan Innovation.
- [ ] Postingan X Richard tentang proyek (sekaligus ikut Community Campaign $2.000).
