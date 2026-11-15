import 'package:flutter_dotenv/flutter_dotenv.dart';

class BlockchainConfig {
  static String get rpcUrl => dotenv.env['RPC_URL'] ?? '';
  static String get contractAddress => dotenv.env['CONTRACT_ADDRESS'] ?? '';
  static int get chainId => int.tryParse(dotenv.env['CHAIN_ID'] ?? '11155111') ?? 11155111;
  static String get privateKey => dotenv.env['PRIVATE_KEY'] ?? '';

  static const String contractName = 'LogbookLabIoT';

  static const String contractAbi = '''
  [
    {
      "inputs": [
        {
          "internalType": "string",
          "name": "namaAlat",
          "type": "string"
        }
      ],
      "name": "pinjamAlat",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "id",
          "type": "uint256"
        }
      ],
      "name": "kembalikanAlat",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "jumlahPeminjaman",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "id",
          "type": "uint256"
        }
      ],
      "name": "ambilPeminjaman",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        },
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    }
  ]
  ''';
}