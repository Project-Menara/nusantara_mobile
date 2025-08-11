import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/voucher_entity.dart';
import 'package:nusantara_mobile/features/voucher/presentation/bloc/voucher/voucher_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:math' as math;

class VoucherPage extends StatelessWidget {
  const VoucherPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sediakan VoucherBloc untuk halaman ini
    return BlocProvider(
      create: (context) => sl<VoucherBloc>()..add(GetAllVoucherEvent()),
      child: const VoucherView(),
    );
  }
}

class VoucherView extends StatelessWidget {
  const VoucherView({super.key});

  // <<< BARU: Fungsi untuk memicu refresh >>>
  Future<void> _onRefresh(BuildContext context) async {
    context.read<VoucherBloc>().add(GetAllVoucherEvent());
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data user dari AuthBloc untuk mendapatkan poin
    final currentUser = context.watch<AuthBloc>().state.user;
    final userPoints =
        currentUser?.points ?? 0; // Ganti 'points' dengan nama field yang benar

    return Scaffold(
      // Kita tidak perlu Scaffold di sini karena sudah ada di parent (misal: HomePage)
      // Namun jika ini halaman mandiri, Scaffold diperlukan. Anggap ini halaman mandiri.
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<VoucherBloc, VoucherState>(
        builder: (context, state) {
          // Tentukan status loading berdasarkan state dari BLoC
          final bool isLoading =
              state is VoucherAllLoading || state is VoucherInitial;

          return RefreshIndicator(
            onRefresh: () => _onRefresh(context),
            child: Skeletonizer(
              enabled: isLoading,
              child: CustomScrollView(
                // Gunakan CustomScrollView untuk performa lebih baik
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeaderAndPointsCardStack(
                      userPoints: userPoints,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 70)),
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      title: 'Tukarkan point Kamu',
                      onSeeAllTapped: () {},
                    ),
                  ),

                  // Tampilkan konten berdasarkan state
                  if (state is VoucherAllLoaded)
                    _buildVoucherList(state.vouchers, userPoints)
                  else if (state is VoucherAllError)
                    SliverToBoxAdapter(
                      child: _buildErrorDisplay(state.message, context),
                    )
                  else // (isLoading)
                    // Skeletonizer akan otomatis menangani list ini
                    _buildVoucherList([], 0),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // <<< BARU: Widget untuk menampilkan daftar voucher dinamis >>>
  Widget _buildVoucherList(List<VoucherEntity> vouchers, int userPoints) {
    if (vouchers.isEmpty) {
      // Jika data kosong (setelah loading selesai), tampilkan pesan
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48.0),
            child: Text("Belum ada voucher tersedia."),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final voucher = vouchers[index];
          final hasEnoughPoints = userPoints >= voucher.pointCost;
          return _buildRewardCard(
            voucher: voucher,
            hasEnoughPoints: hasEnoughPoints,
          );
        },
        childCount: vouchers.isEmpty
            ? 4
            : vouchers.length, // Tampilkan 4 skeleton item saat loading
      ),
    );
  }

  // <<< BARU: Widget untuk menampilkan pesan error >>>
  Widget _buildErrorDisplay(String message, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _onRefresh(context),
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // ... sisa widget helper disesuaikan agar menerima data dinamis ...

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

  Widget _buildHeaderAndPointsCardStack({required int userPoints}) {
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
          child: _buildPointsSummaryCard(userPoints: userPoints),
        ),
      ],
    );
  }

  Widget _buildPointsSummaryCard({required int userPoints}) {
    // Format angka poin dengan fallback
    late final NumberFormat pointFormatter;
    try {
      pointFormatter = NumberFormat.decimalPattern('id_ID');
    } catch (e) {
      // Fallback ke locale default jika id_ID tidak tersedia
      pointFormatter = NumberFormat.decimalPattern();
    }

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total point Kamu',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pointFormatter.format(userPoints)} Point',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }

  // <<< PERUBAHAN: Menerima VoucherEntity sebagai parameter >>>
  Widget _buildRewardCard({
    required VoucherEntity voucher,
    required bool hasEnoughPoints,
  }) {
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
              _buildRewardDetails(voucher, hasEnoughPoints),
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
            'VOUCHER',
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

  // <<< PERUBAHAN: Menerima VoucherEntity sebagai parameter >>>
  Widget _buildRewardDetails(VoucherEntity voucher, bool hasEnoughPoints) {
    // Format angka poin dengan fallback
    late final NumberFormat pointFormatter;
    try {
      pointFormatter = NumberFormat.decimalPattern('id_ID');
    } catch (e) {
      // Fallback ke locale default jika id_ID tidak tersedia
      pointFormatter = NumberFormat.decimalPattern();
    }

    // Gunakan try-catch untuk fallback jika locale belum diinisialisasi
    late final DateFormat dateFormatter;
    try {
      dateFormatter = DateFormat('d MMM yyyy', 'id_ID');
    } catch (e) {
      // Fallback ke locale default jika id_ID tidak tersedia
      dateFormatter = DateFormat('d MMM yyyy');
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              voucher.description,
              style: const TextStyle(color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              voucher.code,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              'Berlaku hingga: ${dateFormatter.format(voucher.endDate)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Spacer(),
            const Divider(height: 16),
            Row(
              children: [
                Icon(Icons.sell_outlined, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  '${pointFormatter.format(voucher.pointCost)} pts',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
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
                  child: const Text('Tukar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
