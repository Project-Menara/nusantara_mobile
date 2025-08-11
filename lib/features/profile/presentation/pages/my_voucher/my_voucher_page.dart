import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

// BARU: Model sederhana untuk data voucher
class Voucher {
  final String code;
  final String description;
  final String expiryDate;
  final String type; // e.g., 'DISCOUNT'

  Voucher({
    required this.code,
    required this.description,
    required this.expiryDate,
    required this.type,
  });
}

// DIUBAH: Menjadi StatefulWidget
class MyVoucherPage extends StatefulWidget {
  const MyVoucherPage({super.key});

  @override
  State<MyVoucherPage> createState() => _MyVoucherPageState();
}

class _MyVoucherPageState extends State<MyVoucherPage> {
  // BARU: Controller untuk text field pencarian
  final TextEditingController _searchController = TextEditingController();

  // BARU: Daftar dummy untuk semua voucher
  final List<Voucher> _allVouchers = [
    Voucher(
      code: 'FINFIRST25',
      description: 'Flat \$25 off*',
      expiryDate: '31 Dec 2025',
      type: 'DISCOUNT',
    ),
    Voucher(
      code: 'TRAVELHOLIC',
      description: '15% off for all flights',
      expiryDate: '15 Sep 2025',
      type: 'DISCOUNT',
    ),
    Voucher(
      code: 'FOODIE50',
      description: '50% off on first order',
      expiryDate: '31 Aug 2025',
      type: 'CASHBACK',
    ),
    Voucher(
      code: 'NUSANTARA17',
      description: 'Special Independence Day Promo',
      expiryDate: '20 Aug 2025',
      type: 'SPECIAL',
    ),
    Voucher(
      code: 'NEWUSER',
      description: 'Free shipping for new user',
      expiryDate: '01 Jan 2026',
      type: 'FREE',
    ),
  ];

  // BARU: Daftar voucher yang akan ditampilkan (hasil filter)
  List<Voucher> _filteredVouchers = [];

  @override
  void initState() {
    super.initState();
    // Awalnya, tampilkan semua voucher
    _filteredVouchers = _allVouchers;
    // Tambahkan listener untuk mendeteksi perubahan pada search bar
    _searchController.addListener(_filterVouchers);
  }

  @override
  void dispose() {
    // Hapus controller untuk mencegah memory leak
    _searchController.dispose();
    super.dispose();
  }

  // BARU: Logika untuk memfilter voucher
  void _filterVouchers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVouchers = _allVouchers.where((voucher) {
        final voucherCode = voucher.code.toLowerCase();
        final voucherDesc = voucher.description.toLowerCase();
        return voucherCode.contains(query) || voucherDesc.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: Colors.red,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          centerTitle: true,
          // BARU: Tombol kembali
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Voucher Saya',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          // Expanded memastikan ListView mengisi sisa ruang yang tersedia
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              // DIUBAH: Gunakan panjang daftar yang telah difilter
              itemCount: _filteredVouchers.length,
              itemBuilder: (context, index) {
                // DIUBAH: Kirim data voucher ke widget kartu
                return _VoucherCard(voucher: _filteredVouchers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk membangun search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: TextField(
        // DIUBAH: Hubungkan dengan controller
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search Voucher',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon: IconButton(
            icon: Icon(Icons.close_rounded, color: Colors.grey[500]),
            onPressed: () {
              // DIUBAH: Logika untuk membersihkan teks
              _searchController.clear();
            },
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

/// Widget kustom untuk kartu voucher
class _VoucherCard extends StatelessWidget {
  // DIUBAH: Menerima data voucher
  final Voucher voucher;
  const _VoucherCard({required this.voucher});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_buildDiscountTag(), _buildVoucherInfo()],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountTag() {
    return Container(
      color: Colors.orange,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Center(
        child: RotatedBox(
          quarterTurns: -1,
          // DIUBAH: Teks dari data voucher
          child: Text(
            voucher.type,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoucherInfo() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // DIUBAH: Teks dari data voucher
                Text(
                  voucher.code,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // DIUBAH: Teks dari data voucher
                Text(
                  voucher.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const Spacer(),
                // DIUBAH: Teks dari data voucher
                Text(
                  'Valid until: ${voucher.expiryDate}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Transform.rotate(
                angle: -math.pi / 12,
                child: const Icon(Icons.sell, color: Colors.orange, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
