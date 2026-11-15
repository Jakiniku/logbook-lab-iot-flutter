import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'blockchain_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const LogbookLabApp());
}

class LogbookLabApp extends StatelessWidget {
  const LogbookLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logbook Lab IoT (Sepolia)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LogbookHomePage(),
    );
  }
}

class LogbookHomePage extends StatefulWidget {
  const LogbookHomePage({super.key});

  @override
  State<LogbookHomePage> createState() => _LogbookHomePageState();
}

class _LogbookHomePageState extends State<LogbookHomePage> {
  late BlockchainService _blockchainService;
  List<PeminjamanItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _blockchainService = BlockchainService();
    _loadData();
  }

  @override
  void dispose() {
    _blockchainService.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _blockchainService.getDaftarPeminjaman();
      setState(() {
        _items = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data blockchain:\n$e';
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(DateTime dt) {
    final d = dt.toLocal();
    final tgl = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final jam = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$tgl $jam';
  }

  void _showTxDialog({
    required String title,
    required String message,
    String? txHash,
    bool isError = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.red : Colors.teal,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (txHash != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Transaction Hash:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  txHash,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: txHash));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction Hash disalin!')),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Salin Hash'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _loadData();
            },
            child: const Text('Tutup & Muat Ulang'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPinjamDialog() async {
    final controller = TextEditingController();

    final namaAlat = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pinjam Alat Lab IoT'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Contoh: Arduino Uno + Sensor HC-SR04',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.of(ctx).pop(text);
              }
            },
            child: const Text('Catat On-Chain'),
          ),
        ],
      ),
    );

    if (namaAlat == null) return;

    _showLoadingOverlay('Mengirim transaksi peminjaman ke Sepolia...');
    try {
      final txHash = await _blockchainService.pinjamAlat(namaAlat);
      if (!mounted) return;
      Navigator.of(context).pop();
      _showTxDialog(
        title: 'Peminjaman Tercatat',
        message: 'Alat "$namaAlat" berhasil dicatat ke blockchain. Tunggu ~15 detik lalu muat ulang jika belum tampil.',
        txHash: txHash,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showTxDialog(
        title: 'Transaksi Gagal',
        message: e.toString(),
        isError: true,
      );
    }
  }

  Future<void> _handleKembalikan(PeminjamanItem item) async {
    _showLoadingOverlay('Mencatat pengembalian alat ke Sepolia...');
    try {
      final txHash = await _blockchainService.kembalikanAlat(item.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      _showTxDialog(
        title: 'Pengembalian Tercatat',
        message: 'Pengembalian "${item.namaAlat}" (ID #${item.id}) berhasil dikirim. Tunggu ~15 detik lalu muat ulang.',
        txHash: txHash,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      _showTxDialog(
        title: 'Transaksi Gagal',
        message: e.toString(),
        isError: true,
      );
    }
  }

  void _showLoadingOverlay(String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logbook Lab IoT (Sepolia)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang Data',
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.teal.shade50,
            child: Text(
              'Wallet Peminjam: ${_blockchainService.walletAddress}',
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_errorMessage!, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: _loadData,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _items.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada riwayat peminjaman alat.\nTekan tombol + untuk mencatat peminjaman.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _items.length,
                              itemBuilder: (ctx, index) {
                                final item = _items[index];
                                final isMine = item.peminjam.toLowerCase() ==
                                    _blockchainService.walletAddress.toLowerCase();

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          item.sudahKembali
                                              ? Icons.check_circle
                                              : Icons.memory,
                                          color: item.sudahKembali
                                              ? Colors.green
                                              : Colors.orange,
                                          size: 30,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.namaAlat,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'ID #${item.id} • Peminjam: ${item.peminjam.substring(0, 6)}...${item.peminjam.substring(item.peminjam.length - 4)}',
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                              Text(
                                                'Waktu Pinjam : ${_formatDateTime(item.waktuPinjam)}',
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                              Text(
                                                item.sudahKembali
                                                    ? 'Waktu Kembali: ${_formatDateTime(item.waktuKembali!)}'
                                                    : 'Status       : Sedang Dipinjam',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: item.sudahKembali
                                                      ? Colors.green.shade700
                                                      : Colors.orange.shade800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!item.sudahKembali && isMine)
                                          OutlinedButton(
                                            onPressed: () => _handleKembalikan(item),
                                            child: const Text('Kembalikan'),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPinjamDialog,
        icon: const Icon(Icons.add),
        label: const Text('Pinjam Alat'),
      ),
    );
  }
}