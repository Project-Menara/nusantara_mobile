import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final String storeName;
  final String productName;
  final String? typeProduct; // optional category/type badge

  const ProductDetailPage({
    super.key,
    required this.storeName,
    required this.productName,
    this.typeProduct,
  });

  @override
  Widget build(BuildContext context) {
    // Debug print: verify passed typeProduct
    debugPrint(
      '[Store/ProductDetailPage] Build: productName=$productName, typeProduct=${typeProduct ?? '(null)'}',
    );
    return Scaffold(
      appBar: AppBar(title: Text(productName), backgroundColor: Colors.orange),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Container(
                width: double.infinity,
                height: 180,
                alignment: Alignment.center,
                child: const Icon(Icons.image, size: 72, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              productName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if ((typeProduct ?? '').isNotEmpty)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      typeProduct!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            if ((typeProduct ?? '').isNotEmpty) const SizedBox(height: 8),
            Text(
              'Toko: $storeName',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Text(
              'Deskripsi produk',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                  'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
                  'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                  style: TextStyle(height: 1.6),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Produk ditambahkan ke keranjang'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Tambah ke Keranjang'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
