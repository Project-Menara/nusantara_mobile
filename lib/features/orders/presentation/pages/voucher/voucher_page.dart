// GUNAKAN KODE INI
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:math' as math;

// --- PERUBAHAN: Kembali menjadi StatefulWidget ---
class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  // --- PERUBAHAN: State untuk mengelola status loading ---
  bool _isLoading = true;

  // --- PERUBAHAN: Panggil data saat halaman pertama kali dibuka ---
  @override
  void initState() {
    super.initState();
    _fetchVouchers();
  }

  // --- PERUBAHAN: Fungsi untuk simulasi fetch data dari API ---
  Future<void> _fetchVouchers() async {
    // Set loading ke true saat memulai fetch
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // Simulasi penundaan jaringan selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    // Set loading ke false setelah data "diterima"
    // Pengecekan 'mounted' penting untuk menghindari error jika user
    // meninggalkan halaman sebelum Future selesai.
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- PERUBAHAN: Bungkus seluruh konten dengan RefreshIndicator & Skeletonizer ---
    return RefreshIndicator(
      onRefresh: _fetchVouchers,
      child: Skeletonizer(
        enabled: _isLoading,
        child: Builder(
          builder: (context) {
            const int rewardCount = 4; // keep same number of sample rewards
            const int totalItems =
                4 +
                rewardCount; // header, spacer70, sectionHeader, rewards..., bottom spacer

            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: totalItems,
              itemBuilder: (context, index) {
                if (index == 0) return _buildHeaderAndPointsCardStack();
                if (index == 1) return const SizedBox(height: 70);
                if (index == 2) {
                  return _buildSectionHeader(
                    title: 'Tukarkan point Kamu',
                    onSeeAllTapped:
                        () {}, // intentionally empty; keep UI hook without logging
                  );
                }

                if (index >= 3 && index < 3 + rewardCount) {
                  final rewardIndex = index - 3;
                  final hasEnough = rewardIndex == (rewardCount - 1);
                  return _buildRewardCard(hasEnoughPoints: hasEnough);
                }

                // bottom spacer
                return const SizedBox(height: 20);
              },
            );
          },
        ),
      ),
    );
  }

  // Semua method helper ada di dalam State class ini

  Widget _buildSectionHeader({
    required String title,
    VoidCallback? onSeeAllTapped,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 12, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (onSeeAllTapped != null)
            TextButton(
              onPressed: onSeeAllTapped,
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderAndPointsCardStack() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 220,
          decoration: const BoxDecoration(
            color: Color(0xFFE51E25),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
          ),
          child: const Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Text(
                'Voucher',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 110,
          left: 20,
          right: 20,
          child: _buildPointsSummaryCard(),
        ),
      ],
    );
  }

  Widget _buildPointsSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.monetization_on, color: Colors.orange, size: 40),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total point Kamu',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '3.000 Point',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Point Kamu akan hangus pada 30/08/2025',
                      style: TextStyle(
                        color: Color(0xFFE51E25),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Riwayat >',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          InkWell(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Lihat keuntungan point'),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard({required bool hasEnoughPoints}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _buildDiscountBanner(),
              _buildRewardDetails(hasEnoughPoints),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountBanner() {
    return Container(
      width: 60,
      color: Colors.orange.shade600,
      child: Center(
        child: Transform.rotate(
          angle: -math.pi / 2,
          child: const Text(
            'DISCOUNT',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardDetails(bool hasEnoughPoints) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flat Rp 25.000 off*',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Text(
              'FINFIRST25',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            const Text(
              'Valid until: 31 Dec 2025',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Spacer(),
            const Divider(height: 16),
            Row(
              children: [
                Icon(Icons.sell_outlined, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                const Text(
                  '5000 pts',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: hasEnoughPoints ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasEnoughPoints
                        ? Colors.orange
                        : Colors.grey[300],
                    foregroundColor: hasEnoughPoints
                        ? Colors.white
                        : Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Redeem'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
