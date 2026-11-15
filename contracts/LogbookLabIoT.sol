// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LogbookLabIoT {
    struct Peminjaman {
        string namaAlat;
        address peminjam;
        uint256 waktuPinjam;
        uint256 waktuKembali; // 0 jika masih dipinjam
    }

    Peminjaman[] private daftarPeminjaman;

    function pinjamAlat(string memory namaAlat) public {
        daftarPeminjaman.push(Peminjaman({
            namaAlat: namaAlat,
            peminjam: msg.sender,
            waktuPinjam: block.timestamp,
            waktuKembali: 0
        }));
    }

    function kembalikanAlat(uint256 id) public {
        require(id < daftarPeminjaman.length, "ID tidak ditemukan");
        require(daftarPeminjaman[id].peminjam == msg.sender, "Bukan peminjam alat ini");
        require(daftarPeminjaman[id].waktuKembali == 0, "Alat sudah dikembalikan");

        daftarPeminjaman[id].waktuKembali = block.timestamp;
    }

    function jumlahPeminjaman() public view returns (uint256) {
        return daftarPeminjaman.length;
    }

    function ambilPeminjaman(uint256 id) public view returns (
        string memory,
        address,
        uint256,
        uint256
    ) {
        require(id < daftarPeminjaman.length, "ID tidak ditemukan");
        Peminjaman memory p = daftarPeminjaman[id];
        return (p.namaAlat, p.peminjam, p.waktuPinjam, p.waktuKembali);
    }
}