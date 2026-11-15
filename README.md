# Logbook Peminjaman Alat Lab IoT (DApp Flutter + Ethereum Sepolia)

Aplikasi terdesentralisasi (DApp) berbasis Flutter yang terhubung dengan Smart Contract Solidity di jaringan **Ethereum Sepolia Testnet** untuk mencatat logbook peminjaman dan pengembalian perangkat keras Laboratorium IoT secara transparan dan permanen (*on-chain*).

## Fitur Utama
1. **Pencatatan Peminjaman On-Chain (`pinjamAlat`):** Mencatat nama alat IoT, alamat wallet peminjam (`msg.sender`), serta stempel waktu peminjaman (`block.timestamp`) langsung ke blockchain.
2. **Pencatatan Pengembalian Alat (`kembalikanAlat`):** Memperbarui status peminjaman dan mencatat waktu pengembalian (`waktuKembali`) yang tervalidasi hanya oleh alamat wallet peminjam asli.
3. **Riwayat & Audit Logbook (`ambilPeminjaman`):** Menampilkan seluruh daftar peminjaman beserta status aktif (*Sedang Dipinjam*) maupun yang sudah dikembalikan.
4. **Transparansi Transaksi:** Menampilkan *Transaction Hash* untuk setiap transaksi tulis sehingga dapat diverifikasi secara publik melalui Sepolia Etherscan.
5. **Refresh Data:** Memuat ulang data terbaru dari smart contract setelah konfirmasi blok.

## Informasi Smart Contract
- **Nama Kontrak:** `LogbookLabIoT` (`contracts/LogbookLabIoT.sol`)
- **Jaringan:** Ethereum Sepolia Testnet (Chain ID: `11155111`)
- **Contract Address:** `<TEMPEL_CONTRACT_ADDRESS_BARU_KAMU_DI_SINI>`
- **Explorer:** `https://sepolia.etherscan.io/address/<TEMPEL_CONTRACT_ADDRESS_BARU_KAMU_DI_SINI>`

## Struktur Proyek
- `contracts/LogbookLabIoT.sol` — Kode sumber Smart Contract Solidity.
- `lib/blockchain_config.dart` — Konfigurasi environment (RPC, Chain ID, Contract Address) dan ABI kontrak.
- `lib/blockchain_service.dart` — Layanan integrasi Web3 (`web3dart`) untuk membaca dan mengirim transaksi ke Sepolia.
- `lib/main.dart` — Antarmuka pengguna (UI) Flutter untuk logbook peminjaman alat.

## Cara Menjalankan Proyek

1. **Clone repositori ini:**
   ```bash
   git clone [https://github.com/Jakiniku/logbook-lab-iot-flutter.git](https://github.com/Jakiniku/logbook-lab-iot-flutter.git)
   cd chain_todo

## Versi Lingkungan & Paket
- **Dart SDK:** `^3.13.0`
- **web3dart:** `^3.0.3`
- **http:** `^1.6.0`
- **flutter_dotenv:** `^6.0.2`
- **wallet:** `^0.0.18`
- **cupertino_icons:** `^1.0.8`

## Sumber Kode & Referensi Adaptasi
- **Kerangka Smart Contract:** Diadaptasi dan dikembangkan dari kerangka `ChainTodo.sol` pada modul *Tugas Proyek: Aplikasi Flutter Terhubung Blockchain* (Mata Kuliah Pemrograman Mobile 2, D4 Teknologi Rekayasa Komputer, Politeknik Negeri Samarinda)[cite: 9, 12].
- **Integrasi Flutter & Web3:** Mengadaptasi pola komunikasi RPC dan pemanggilan fungsi kontrak menggunakan paket `web3dart` dari dokumentasi/video rujukan resmi pengembang Dart & Ethereum (*Build a Blockchain dApp with Flutter and Dart on Ethereum* dan *Build Your First Blockchain Flutter App*)[cite: 10].