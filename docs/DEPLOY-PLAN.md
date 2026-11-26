# Rencana Deploy — BERHENTI DI SINI, menunggu persetujuan eksplisit Richard

## Angka gas PERSIS (diukur, bukan ditebak)

Diukur 26 Nov 2026 dengan dua cara yang hasilnya identik:
1. `forge test --gas-report` → Deployment Cost **1.162.489 gas**, deployment size 5.359 byte (initcode 5.327 / runtime 5.117).
2. Deploy beneran ke Anvil lokal (cast send --create, bytecode + argumen konstruktor yang sama persis) → receipt **gasUsed = 1.162.489**, tx lokal `0x4f4e5873facd58222f6129dec8991d0314471fbbf99c0d5ac563537ca6d0fd3a`.

Gas BSC bersifat deterministik untuk bytecode yang sama → gasUsed di mainnet akan sama (1.162.489), yang berubah hanya harga gas.

## Biaya pada harga live 26 Nov 2026

- Gas price BSC mainnet (RPC resmi, `eth_gasPrice`): **0,05 gwei**
- Biaya deploy = 1.162.489 × 0,05 gwei = **0,00005812 BNB**
- BNB ≈ $551,62 (CoinGecko, 26 Nov) → **≈ $0,03 (tiga sen)**
- Cadangan aman bila gas price naik 20× (1 gwei): 0,00116 BNB (≈ $0,64). Rekomendasi saldo deployer ≥ 0,002 BNB supaya verifikasi + interaksi awal (setPolicy + guard check pertama oleh henz) ikut tercover.
- Biaya per interaksi user sesudahnya (dari gas report, pada 0,05 gwei): setPolicy ≈ 90–140 ribu gas ≈ 0,000007 BNB (≈ $0,004); guardCheckAndRecord ≈ 60–110 ribu gas. Praktis gratis bagi 30+ interaktor.

## Dari wallet mana deploy? (keputusan untuk Richard)

Opsi A — **BAW Agentic Wallet (0xc73442B8…91AA, henz.ai)**: nilai plusnya besar untuk juri — proyek dideploy OLEH Agent ID holder itu sendiri, dan interaksi pertama (setPolicy free-only) langsung tercatat dari alamat Agent ID. Syarat: Richard re-pair BAW di Binance App (sesi mati sejak 15 Nov) + aktifkan Developer Mode (untuk contract-call). Deploy via `baw contract-call` tidak mendukung pembuatan kontrak kosong secara langsung di semua versi — jalur praktisnya: deploy lewat Foundry dengan key deployer terpisah TIDAK tersedia untuk BAW (keyless MPC). Bila jalur BAW contract-call untuk CREATE gagal, fallback ke Opsi B dan BAW tetap dipakai untuk interaksi pertama.
Opsi B — **Rabby 0x2Cd7eDC4…0e45** (wallet kerja Richard): deploy standar Foundry, Richard tanda tangan di Rabby. Kontrak tidak punya owner, jadi alamat deployer tidak memberi kuasa apa pun sesudah deploy — aman secara desain.

Rekomendasi Everest: coba A dulu (narasi + bukti Agent ID paling kuat), fallback B tanpa drama. Keduanya butuh persetujuan Richard per langkah tanda tangan.

## Langkah deploy (sesudah "deploy, jalan" dari Richard)

1. Richard re-pair BAW (App) — ATAU siapkan Rabby dengan ≥0,002 BNB di BSC.
2. `forge create` / jalur BAW dengan konstruktor = `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F`.
3. Verifikasi source di BscScan (forge verify-contract, compiler 0.8.24, optimizer 200) → status open-source terverifikasi = syarat wajib hackathon.
4. Interaksi pertama dari henz.ai: `setPolicy(0, 0, true, false)` (free-only) + satu `guardCheckAndRecord` uji + satu `anchorVerdict` untuk kontrak contoh yang sudah diaudit.
5. Publikasikan repo GitHub (source + test + README) dan website statis (frontend/index.html via GitHub Pages).
6. Isi form submission Binance: nama, website, alamat kontrak, deskripsi pemakaian Agent ID (draf siap di SUBMISSION-DRAFT.md).
7. Kampanye 30 interaksi (OUTREACH-30.md) — dimulai HANYA sesudah kontrak live.

## Yang TIDAK akan dilakukan tanpa persetujuan terpisah
Deploy itu sendiri, re-pair, tanda tangan apa pun, posting X apa pun, dan belanja gas dalam jumlah berapa pun di luar angka di atas.
