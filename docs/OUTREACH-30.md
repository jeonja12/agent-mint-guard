# Rencana JUJUR Mencapai 30 Interaksi Agent ID (syarat Innovation)

Fakta keras dulu: ambang 30 alamat Agent ID unik tidak bisa dibuat oleh kami sendiri.
Kami punya tepat SATU Agent ID (henz.ai). Sybil / membuat-banyak-wallet / membeli interaksi
akan melanggar semangat aturan (satu Agent ID per orang, non-transferable) dan berisiko
diskualifikasi — TIDAK akan dilakukan, dan angka tidak akan dikarang.
Yang bisa kami lakukan: membuat interaksi itu semudah dan semenarik mungkin bagi
pemegang Agent ID lain, lalu menjangkau komunitas tempat mereka berkumpul.

## Mengapa orang mau berinteraksi (nilai nyata, bukan "tolong klik")
- Satu transaksi `setPolicy(0,0,true,false)` (± $0,004 gas) memberi pemegang Agent ID
  sebuah **kebijakan keamanan on-chain miliknya sendiri** yang bisa dirujuk agent-nya —
  ini berguna beneran bagi operator agent mana pun, bukan check-in kosong.
- Halaman website menyediakan preset 1-klik "Free-mint only" + generator perintah `baw contract-call`
  siap tempel untuk agent mereka (pola yang sudah terbukti dipakai proyek lain di hackathon ini).
- Leaderboard publik di website membaca `totalUniqueAgentIdInteractors` + daftar event PolicySet dari chain — transparan, tanpa klaim palsu.

## Kanal jangkauan (semua organik)
1. **X oleh Richard sendiri (@riza1202)** — agen tidak bisa posting ke X. Siapkan 3 draf postingan (di SUBMISSION-DRAFT + draf X terpisah saat launch): pengumuman launch, thread cara kerja + tangkapan layar BscScan, dan update angka interaktor apa adanya. Postingan tentang proyek peserta juga ikut Community Campaign 2.000 USDC.
2. **Komunitas hackathon** — proyek-proyek Agent ID lain saling berinteraksi (pola Agent Roll Call: mereka aktif merekrut di The Colony / forum agent). Kami akan: (a) berinteraksi balik dengan dApp peserta lain memakai henz (setelah deploy, atas persetujuan), (b) memposting Agent Mint Guard di forum yang sama dengan walkthrough 1 menit.
3. **SPACE ID / BNB Chain community calls & grup Telegram/Discord builder** — satu postingan teknis (kontrak + cara integrasi untuk agent lain), bukan spam berulang.
4. **Integrasi untuk agent lain** — README repo berisi potongan kode "panggil guard sebelum mint" (Solidity + baw CLI) supaya builder lain punya alasan teknis mengadopsi, bukan sekadar membantu kami.

## Target & tenggat internal
- Kontrak live target: ≤ 30 Nov 2026 (memberi 9 hari jangkauan sebelum 9 Des 15:00 WIB).
- Hitung harian dari chain (`totalUniqueAgentIdInteractors`), laporkan ke Richard apa adanya tiap milestone: 1 (henz), 5, 10, 20, 30.
- Bila pada 6 Des angka masih < 30: tetap submit (Pioneer tidak mensyaratkan 30; Innovation gugur syaratnya, tetapi submission tetap sah dan karya tetap dinilai di jalur yang tersedia) dan laporkan itu terus terang — jangan membeli/mengarang interaksi di hari terakhir.

## Peran Richard (minimum, tidak bisa digantikan agen)
- Re-pair BAW + persetujuan deploy (satu sesi, ±10 menit).
- Memposting draf X yang disiapkan (3 postingan selama periode).
- Opsional: membalas komentar di postingannya sendiri untuk menaikkan jangkauan organik.
