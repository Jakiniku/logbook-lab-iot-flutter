import 'package:http/http.dart';
import 'package:wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';
import 'blockchain_config.dart';

class PeminjamanItem {
  final int id;
  final String namaAlat;
  final String peminjam;
  final DateTime waktuPinjam;
  final DateTime? waktuKembali;

  PeminjamanItem({
    required this.id,
    required this.namaAlat,
    required this.peminjam,
    required this.waktuPinjam,
    this.waktuKembali,
  });

  bool get sudahKembali => waktuKembali != null;
}

class BlockchainService {
  late Web3Client _client;
  late DeployedContract _contract;
  late EthPrivateKey _credentials;
  late EthereumAddress _ownAddress;

  late ContractFunction _pinjamAlatFunc;
  late ContractFunction _kembalikanAlatFunc;
  late ContractFunction _jumlahPeminjamanFunc;
  late ContractFunction _ambilPeminjamanFunc;

  String get walletAddress => _ownAddress.with0x;

  BlockchainService() {
    _client = Web3Client(BlockchainConfig.rpcUrl, Client());
    _credentials = EthPrivateKey.fromHex(BlockchainConfig.privateKey);
    _ownAddress = _credentials.address;

    final abi = ContractAbi.fromJson(
      BlockchainConfig.contractAbi,
      BlockchainConfig.contractName,
    );
    final contractAddr = EthereumAddress.fromHex(BlockchainConfig.contractAddress);
    _contract = DeployedContract(abi, contractAddr);

    _pinjamAlatFunc = _contract.function('pinjamAlat');
    _kembalikanAlatFunc = _contract.function('kembalikanAlat');
    _jumlahPeminjamanFunc = _contract.function('jumlahPeminjaman');
    _ambilPeminjamanFunc = _contract.function('ambilPeminjaman');
  }

  Future<List<PeminjamanItem>> getDaftarPeminjaman() async {
    final totalResult = await _client.call(
      contract: _contract,
      function: _jumlahPeminjamanFunc,
      params: [],
    );

    final int total = (totalResult.first as BigInt).toInt();
    List<PeminjamanItem> list = [];

    for (int i = 0; i < total; i++) {
      final itemResult = await _client.call(
        contract: _contract,
        function: _ambilPeminjamanFunc,
        params: [BigInt.from(i)],
      );

      final String namaAlat = itemResult[0] as String;
      final EthereumAddress peminjamAddr = itemResult[1] as EthereumAddress;
      final BigInt tsPinjam = itemResult[2] as BigInt;
      final BigInt tsKembali = itemResult[3] as BigInt;

      list.add(
        PeminjamanItem(
          id: i,
          namaAlat: namaAlat,
          peminjam: peminjamAddr.with0x,
          waktuPinjam: DateTime.fromMillisecondsSinceEpoch(tsPinjam.toInt() * 1000),
          waktuKembali: tsKembali > BigInt.zero
              ? DateTime.fromMillisecondsSinceEpoch(tsKembali.toInt() * 1000)
              : null,
        ),
      );
    }

    return list.reversed.toList();
  }

  Future<String> pinjamAlat(String namaAlat) async {
    final txHash = await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _pinjamAlatFunc,
        parameters: [namaAlat],
      ),
      chainId: BlockchainConfig.chainId,
    );
    return txHash;
  }

  Future<String> kembalikanAlat(int id) async {
    final txHash = await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _kembalikanAlatFunc,
        parameters: [BigInt.from(id)],
      ),
      chainId: BlockchainConfig.chainId,
    );
    return txHash;
  }

  void dispose() {
    _client.dispose();
  }
}