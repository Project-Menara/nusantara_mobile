import 'package:flutter/material.dart';
import 'store_products_page.dart';

enum DeliveryMode { takeAway, pickupInStore }

class PickupChoicePage extends StatefulWidget {
  final String storeName;

  const PickupChoicePage({super.key, required this.storeName});

  @override
  State<PickupChoicePage> createState() => _PickupChoicePageState();
}

class _PickupChoicePageState extends State<PickupChoicePage> {
  DeliveryMode? _selected;

  void _openProducts(DeliveryMode mode) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            StoreProductsPage(storeName: widget.storeName, mode: mode),
      ),
    );
  }

  Widget _buildOptionCard({
    required DeliveryMode mode,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _selected == mode;
    return GestureDetector(
      onTap: () => setState(() => _selected = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? Colors.orange[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.orange : Colors.grey.shade200,
            width: selected ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: selected ? Colors.orange : Colors.grey[100],
              child: Icon(icon, color: selected ? Colors.white : Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: selected
                                ? Colors.orange[800]
                                : Colors.black87,
                          ),
                        ),
                      ),
                      if (selected)
                        Icon(
                          Icons.check_circle,
                          color: Colors.orange,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.storeName),
        backgroundColor: Colors.orange,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Metode Pengambilan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih metode yang paling nyaman untukmu. Kamu bisa pilih pengantaran atau mengambil langsung di toko.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    _buildOptionCard(
                      mode: DeliveryMode.takeAway,
                      icon: Icons.delivery_dining,
                      title: 'Diantar ke Alamat (Take Away)',
                      subtitle: 'Kurir akan mengantarkan pesanan ke alamatmu.',
                    ),
                    _buildOptionCard(
                      mode: DeliveryMode.pickupInStore,
                      icon: Icons.storefront,
                      title: 'Ambil di Toko',
                      subtitle: 'Pesanan akan siap diambil di kasir toko.',
                    ),
                    const SizedBox(height: 12),
                    // small note
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Jam operasional dan ketersediaan bisa berubah. Estimasi waktu dan biaya akan dihitung di langkah selanjutnya.',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            // sticky CTA
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selected == null
                          ? null
                          : () => _openProducts(_selected!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _selected == null ? 'Pilih Metode' : 'Lanjutkan',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
