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