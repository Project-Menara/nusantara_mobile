import 'package:flutter/material.dart';
import '../store/pickup_choice_page.dart';
import 'product_detail_page.dart';

class StoreProductsPage extends StatelessWidget {
  final String storeName;
  final DeliveryMode mode;

  const StoreProductsPage({
    super.key,
    required this.storeName,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    // Mock product list for demonstration — replace with real data source later
    final products = List<String>.generate(
      8,
      (i) => 'Produk ${i + 1} — $storeName',
    );
    // Demo category types to showcase the badge in ProductDetailPage
    final demoTypes = <String>[
      'Minuman',
      'Snack',
      'Kue',
      'Roti',
      'Susu',
      'Cemilan',
      'Kopi',
      'Teh',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$storeName - ${mode == DeliveryMode.takeAway ? 'Take Away' : 'Ambil di Toko'}',
        ),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final productName = products[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                title: Text(
                  productName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Deskripsi singkat produk.'),
                onTap: () {
                  final type = demoTypes[index % demoTypes.length];
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => ProductDetailPage(
                        storeName: storeName,
                        productName: productName,
                        typeProduct: type,
                      ),
                    ),
                  );
                },
                trailing: ElevatedButton(
                  onPressed: () {
                    final type = demoTypes[index % demoTypes.length];
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => ProductDetailPage(
                          storeName: storeName,
                          productName: productName,
                          typeProduct: type,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Pilih'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
