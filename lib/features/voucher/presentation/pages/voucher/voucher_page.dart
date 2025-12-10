// Salin dan ganti isi file voucher_page.dart dengan kode ini

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:nusantara_mobile/features/point/domain/entities/point_entity.dart';
import 'package:nusantara_mobile/features/point/presentation/bloc/point/point_bloc.dart';
import 'package:nusantara_mobile/features/point/presentation/bloc/point/point_event.dart';
import 'package:nusantara_mobile/features/point/presentation/bloc/point/point_state.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/voucher_entity.dart';
import 'package:nusantara_mobile/features/voucher/presentation/bloc/voucher/voucher_bloc.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';
import 'package:go_router/go_router.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  @override
  void initState() {
    super.initState();
    // Logika ini sekarang aman karena Provider sudah ada di atas widget ini
    final voucherBloc = context.read<VoucherBloc>();
    final pointBloc = context.read<PointBloc>();

    if (voucherBloc.state is! VoucherAllLoaded) {
      // debug: 🚀 VoucherPage: Data voucher belum ada. Memuat data...
      voucherBloc.add(GetAllVoucherEvent());
    } else {
      // debug: ✅ VoucherPage: Data voucher sudah ada. Tidak perlu memuat ulang.
    }

    if (pointBloc.state is! PointLoaded &&
        pointBloc.state is! PointDataLoaded) {
      // debug: 🚀 VoucherPage: Data poin belum ada. Memuat data...
      pointBloc.add(const GetCustomerPointEvent());
    } else {
      // debug: ✅ VoucherPage: Data poin sudah ada. Tidak perlu memuat ulang.
    }
  }

  @override
  Widget build(BuildContext context) {
    // MultiBlocProvider sudah tidak diperlukan lagi di sini.
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthTokenExpiredState) {
          // debug: 🔐 VoucherPage: Token expired detected, navigating to login
          showAppFlashbar(
            context,
            title: 'Sesi Berakhir',
            message: authState.message,
            isSuccess: false,
          );
          context.go(InitialRoutes.loginScreen);
        }
      },
      child: const VoucherView(),
    );
  }
}

// ======================================================================
// KELAS VoucherView DAN SEMUA WIDGET HELPER DI BAWAHNYA TIDAK PERLU DIUBAH
// ======================================================================

class VoucherView extends StatelessWidget {
  const VoucherView({super.key});

  Future<void> _onRefresh(BuildContext context) async {
    context.read<VoucherBloc>().add(GetAllVoucherEvent());
    context.read<PointBloc>().add(const GetCustomerPointEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<PointBloc, PointState>(
        builder: (context, pointState) {
          int userPoints = 0;
          PointEntity? pointEntity;

          if (pointState is PointLoaded || pointState is PointDataLoaded) {
            final point = pointState is PointLoaded
                ? pointState.point
                : (pointState as PointDataLoaded).point;
            userPoints = point.totalPoints;
            pointEntity = point;
          }

          return MultiBlocListener(
            listeners: [
              BlocListener<VoucherBloc, VoucherState>(
                listener: (context, state) {
                  if (state is VoucherClaimSuccess) {
                    showAppFlashbar(
                      context,
                      title: 'Discount Berhasil Diredem!',
                      message:
                          'Discount ${state.claimedVoucher.voucher.code} telah berhasil diredem.',
                      isSuccess: true,
                    );
                    _onRefresh(context);
                  } else if (state is VoucherClaimError) {
                    showAppFlashbar(
                      context,
                      title: 'Gagal Redeem Discount',
                      message: state.message,
                      isSuccess: false,
                    );
                  }
                },
              ),
            ],
            child: BlocBuilder<VoucherBloc, VoucherState>(
              builder: (context, state) {
                final bool hasData = state is VoucherAllLoaded;
                final bool hasError = state is VoucherAllError;

                return RefreshIndicator(
                  onRefresh: () => _onRefresh(context),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildHeaderAndPointsCardStack(
                          userPoints: userPoints,
                          pointEntity: pointEntity,
                          context: context,
                        ),
                      ),
                      // debug: 🚀 VoucherPage: Data voucher belum ada. Memuat data...
                      SliverToBoxAdapter(
                        child: _buildSectionHeader(
                          title: 'Redeem Point untuk Discount',
                        ),
                      ),
                      if (hasData) ...[
                        _buildVoucherList(state.vouchers, userPoints),
                      ] else if (hasError) ...[
                        SliverToBoxAdapter(
                          child: _buildErrorDisplay(
                            (state as dynamic).message as String,
                            context,
                          ),
                        ),
                      ] else ...[
                        _buildOptimizedSkeleton(),
                      ],
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ... (Sisa kode widget helper seperti _buildVoucherList, _buildRewardCard, dll, tetap sama)
  // Anda bisa salin dari kode sebelumnya jika perlu.
  // Pastikan semua widget helper ada di dalam kelas VoucherView ini.
  // _formatExpiryDate removed (unused helper)

  Widget _buildHeaderAndPointsCardStack({
    required int userPoints,
    PointEntity? pointEntity,
    required BuildContext context,
  }) {
    return SizedBox(
      height: 195,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 120.0,
            decoration: const BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: const Center(
              child: Text(
                'Reward',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 85,
            left: 20,
            right: 20,
            child: _buildPointsSummaryCard(
              userPoints: userPoints,
              pointEntity: pointEntity,
              context: context,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsSummaryCard({
    required int userPoints,
    PointEntity? pointEntity,
    required BuildContext context,
  }) {
    final pointFormatter = NumberFormat.decimalPattern('id_ID');
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
      child: Row(
        children: [
          Image.asset('assets/images/hand_coin.png', width: 40, height: 40),
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
            onPressed: () => context.push(InitialRoutes.pointHistory),
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
    );
  }

  Widget _buildSectionHeader({required String title}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 12, 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildVoucherList(List<VoucherEntity> vouchers, int userPoints) {
    if (vouchers.isEmpty) {
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
      delegate: SliverChildBuilderDelegate((context, index) {
        final voucher = vouchers[index];
        final hasEnoughPoints = userPoints >= voucher.pointCost;
        return _buildRewardCard(
          context: context,
          voucher: voucher,
          hasEnoughPoints: hasEnoughPoints,
        );
      }, childCount: vouchers.length),
    );
  }

  Widget _buildRewardCard({
    required BuildContext context,
    required VoucherEntity voucher,
    required bool hasEnoughPoints,
  }) {
    return GestureDetector(
      onTap: () =>
          context.push('${InitialRoutes.vouchers}/detail/${voucher.id}'),
      child: Container(
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
                _buildRewardDetails(voucher, hasEnoughPoints, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountBanner() {
    return Container(
      width: 100,
      color: Colors.orange.shade600,
      child: const Center(
        child: RotatedBox(
          quarterTurns: 3,
          child: Text(
            'DISCOUNT',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardDetails(
    VoucherEntity voucher,
    bool hasEnoughPoints,
    BuildContext context,
  ) {
    final pointFormatter = NumberFormat.decimalPattern('id_ID');
    final dateFormatter = DateFormat('d MMM yyyy', 'id_ID');
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
                Expanded(
                  child: Text(
                    '${pointFormatter.format(voucher.pointCost)} pts',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: (hasEnoughPoints && !voucher.isClaimed)
                      ? () => _showClaimConfirmationDialog(context, voucher)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (hasEnoughPoints && !voucher.isClaimed)
                        ? Colors.orange
                        : Colors.grey[300],
                    foregroundColor: (hasEnoughPoints && !voucher.isClaimed)
                        ? Colors.white
                        : Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    voucher.isClaimed ? 'Claimed' : 'Redeem',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _claimVoucher(BuildContext context, VoucherEntity voucher) {
    context.read<VoucherBloc>().add(ClaimVoucherEvent(voucher.id));
  }

  Future<void> _showClaimConfirmationDialog(
    BuildContext context,
    VoucherEntity voucher,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Konfirmasi Redeem'),
          content: Text(
            'Anda akan menukar ${voucher.pointCost} poin untuk voucher ini. Lanjutkan?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ya, Redeem'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      _claimVoucher(context, voucher);
    }
  }

  Widget _buildErrorDisplay(String message, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.orange, size: 50),
          const SizedBox(height: 16),
          const Text(
            'Gagal memuat data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildOptimizedSkeleton() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(width: 80, height: 80, color: Colors.grey[200]),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, color: Colors.grey[200]),
                    const SizedBox(height: 8),
                    Container(height: 14, width: 100, color: Colors.grey[200]),
                  ],
                ),
              ),
            ],
          ),
        ),
        childCount: 4,
      ),
    );
  }
}
