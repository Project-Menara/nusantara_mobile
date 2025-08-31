import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengatur warna latar belakang halaman
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        title: const Text(
          'Favorite',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      // Menggunakan ListView.builder untuk membuat daftar yang efisien
      body: ListView.builder(
        // Menambahkan padding di atas dan bawah daftar
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        // Jumlah item dalam daftar (untuk contoh, kita buat 3)
        itemCount: 3,
        itemBuilder: (context, index) {
          // Setiap item adalah widget kartu kustom
          return const _FavoriteItemCard();
        },
      ),
    );
  }
}

/// Widget kustom untuk setiap kartu di halaman favorit
class _FavoriteItemCard extends StatelessWidget {
  const _FavoriteItemCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberi margin di sekitar kartu
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // Mengatur bentuk kartu dengan sudut membulat
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama toko/brand
            const Text(
              'Bolu Menara Tembung',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Bagian utama: gambar, deskripsi, dan tombol hati
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar produk
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    'assets/images/bolu_menara.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                // Deskripsi produk8
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Double Cheese',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bolu stim Double Cheese Regular Pack (600 gr)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Tombol Hati (Favorite)
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () {
                    // TODO: Tambahkan logika untuk batal menyukai
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Bagian bawah: harga dan tombol "Lihat Produk"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Harga
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harga',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Rp.46.000',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                // Tombol Lihat Produk
                OutlinedButton(
                  onPressed: () {
                    // TODO: Tambahkan logika untuk navigasi ke halaman detail produk
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: BorderSide(color: Colors.orange.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Lihat Produk'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
