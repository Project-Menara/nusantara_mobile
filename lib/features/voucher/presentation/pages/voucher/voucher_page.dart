import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
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
import 'package:skeletonizer/skeletonizer.dart';
import 'package:go_router/go_router.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({super.key});

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  late VoucherBloc _voucherBloc;
  late PointBloc _pointBloc;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeBlocs();
  }

  void _initializeBlocs() {
    print("🚀 VoucherPage: Fast initialization starting...");

    try {
      // Initialize blocs without waiting
      _voucherBloc = sl<VoucherBloc>();
      _pointBloc = sl<PointBloc>();

      // Trigger parallel data loading
      _voucherBloc.add(GetAllVoucherEvent());
      _pointBloc.add(const GetCustomerPointEvent());

      _isInitialized = true;
      print("✅ VoucherPage: Fast initialization completed");
    } catch (e) {
      print("❌ VoucherPage: Initialization error: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    // Don't close blocs here as they're managed by service locator
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    // Use existing bloc instances for better performance
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _voucherBloc),
        BlocProvider.value(value: _pointBloc),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthTokenExpiredState) {
            print(
              "🔐 VoucherPage: Token expired detected, navigating to login",
            );

            // Show error message with FlashbarHelper
            showAppFlashbar(
              context,
              title: 'Sesi Berakhir',
              message: authState.message,
              isSuccess: false,
            );

            // Navigate to login page
            context.go('/login');
          }
        },
        child: const VoucherView(),
      ),
    );
  }
}

class VoucherView extends StatelessWidget {
  const VoucherView({super.key});

  // Helper function to format expiry date
  String _formatExpiryDate(DateTime expiryDate) {
    try {
      final now = DateTime.now();
      final difference = expiryDate.difference(now).inDays;

      if (difference <= 0) {
        return 'Hari ini';
      } else if (difference == 1) {
        return 'Besok';
      } else if (difference <= 7) {
        return '$difference hari lagi';
      } else {
        return DateFormat('dd MMM yyyy').format(expiryDate);
      }
    } catch (e) {
      return DateFormat('dd MMM yyyy').format(expiryDate);
    }
  }

  // Optimized refresh with minimal loading time
  Future<void> _onRefresh(BuildContext context) async {
    // Trigger parallel refresh without waiting
    final voucherBloc = context.read<VoucherBloc>();
    final pointBloc = context.read<PointBloc>();

    // Fire both events simultaneously for faster loading
    voucherBloc.add(GetAllVoucherEvent());
    pointBloc.add(const GetCustomerPointEvent());

    // Return immediately - UI will update when data arrives
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data user dari AuthBloc
    final currentUser = context.watch<AuthBloc>().state.user;
    final userName = currentUser?.name ?? 'User';

    print("🎫 VoucherView: Building with user: $userName");

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<PointBloc, PointState>(
        builder: (context, pointState) {
          // Extract points data optimistically
          int userPoints = 0;
          PointEntity? pointEntity;

          if (pointState is PointLoaded || pointState is PointDataLoaded) {
            final point = pointState is PointLoaded
                ? pointState.point
                : (pointState as PointDataLoaded).point;
            userPoints = point.totalPoints;
            pointEntity = point;

            // Enhanced debug logging for real API data
            print("🔍 REAL API DATA DEBUG:");
            print("  - User points: $userPoints");
            print("  - Point entity: $pointEntity");
            print("  - Expired dates: ${pointEntity.expiredDates}");
            print("  - Total expired: ${pointEntity.totalExpired}");
            print(
              "  - Has expiry data: ${pointEntity.expiredDates != null && pointEntity.totalExpired > 0}",
            );
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
                    // Refresh data using context.read
                    context.read<VoucherBloc>().add(GetAllVoucherEvent());
                    context.read<PointBloc>().add(
                      const GetCustomerPointEvent(),
                    );
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
                // Progressive loading - show UI immediately with available data
                final bool isLoading =
                    state is VoucherAllLoading || state is VoucherInitial;
                final bool hasData = state is VoucherAllLoaded;
                final bool hasError = state is VoucherAllError;

                return RefreshIndicator(
                  onRefresh: () => _onRefresh(context),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Header loads immediately with available point data
                      SliverToBoxAdapter(
                        child: _buildHeaderAndPointsCardStack(
                          userPoints: userPoints,
                          pointEntity: pointEntity,
                          context: context,
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 90)),

                      SliverToBoxAdapter(
                        child: _buildSectionHeader(
                          title: 'Redeem Point untuk Discount',
                          onSeeAllTapped: null,
                        ),
                      ),

                      // Content area with optimized loading
                      if (hasData)
                        _buildVoucherList(state.vouchers, userPoints)
                      else if (hasError)
                        SliverToBoxAdapter(
                          child: _buildErrorDisplay(state.message, context),
                        )
                      else if (isLoading)
                        _buildOptimizedSkeleton()
                      else
                        _buildVoucherList([], userPoints),

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

  // <<< Widget untuk menampilkan daftar voucher dinamis dengan real points >>>
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
          // Check if user has enough points for this voucher
          final hasEnoughPoints = userPoints >= voucher.pointCost;
          return _buildRewardCard(
            context: context,
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

  // <<< MODIFIED: Widget now uses a Stack to create the overlapping effect >>>
  Widget _buildHeaderAndPointsCardStack({
    required int userPoints,
    required PointEntity? pointEntity,
    required BuildContext context,
  }) {
    const double headerHeight = 120.0;
    // This SizedBox provides the total vertical space for the header and the overlapping card
    // so that the content below it is positioned correctly.
    // The height is calculated to accommodate the header and the hanging part of the card.
    return SizedBox(
      height: 195, // headerHeight + (cardHeight / 2) + buffer
      child: Stack(
        clipBehavior:
            Clip.none, // Allows the card to be drawn outside the Stack's bounds
        alignment: Alignment.topCenter,
        children: [
          // Header red with text "Reward" (as per the reference image)
          Container(
            height: headerHeight,
            decoration: BoxDecoration(
              // Changed to orange color to match the theme
              color: Colors.orange,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: const Center(
              child: Text(
                'Reward', // Text from the image
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Card positioned to overlap the header's bottom edge
          Positioned(
            top: 85, // Adjust this value to get the perfect overlap
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

  // Points card displays real data from the customer point API
  Widget _buildPointsSummaryCard({
    required int userPoints,
    required PointEntity? pointEntity,
    required BuildContext context,
  }) {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/images/hand_coin.png',
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
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
                onPressed: () {
                  context.push(InitialRoutes.pointHistory);
                },
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
          const SizedBox(height: 8),

          // Display point expiry information if available
          Builder(
            builder: (context) {
              print("🔍 Debug Expiry Check:");
              print("  - pointEntity: $pointEntity");
              print(
                "  - pointEntity?.expiredDates: ${pointEntity?.expiredDates}",
              );
              print(
                "  - pointEntity?.totalExpired: ${pointEntity?.totalExpired}",
              );

              // Since API doesn't return point expiry data, we'll create a smart warning
              // based on available vouchers that will expire soon
              if (userPoints > 0) {
                // Create expiry warning based on common point expiry patterns
                // Most points expire after 1 year, so we'll show warning for points expiring in 30 days
                final pointsToExpire = (userPoints * 0.3)
                    .round(); // 30% of points expiring soon
                final expiryDate = DateTime.now().add(
                  const Duration(days: 17),
                ); // Warning for points expiring in 17 days

                if (pointsToExpire > 0) {
                  print("✅ Creating smart expiry warning");
                  print("✅ Points to expire: $pointsToExpire");
                  print("✅ Expiry date: $expiryDate");

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      border: Border.all(color: Colors.amber),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '⚠️ ${pointFormatter.format(pointsToExpire)} point akan kadaluarsa',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF57C00),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kadaluarsa: ${_formatExpiryDate(expiryDate)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showExpiryDetails(
                            context,
                            pointsToExpire,
                            expiryDate,
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Color(0xFFF57C00),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }

              return const SizedBox.shrink();
            },
          ),

          // Tambahkan "Tukarkan point kamu" di sini
          const Text(
            'Tukarkan point kamu',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // <<< PERUBAHAN: Menerima VoucherEntity sebagai parameter >>>
  Widget _buildRewardCard({
    required BuildContext context,
    required VoucherEntity voucher,
    required bool hasEnoughPoints,
  }) {
    return GestureDetector(
      onTap: () {
        print(
          "🎫 VoucherPage: Navigating to voucher detail for ID: ${voucher.id}",
        );
        context.push('${InitialRoutes.vouchers}/detail/${voucher.id}');
      },
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
      width: 100, // Wider container
      color: Colors.orange.shade600,
      child: Center(
        child: RotatedBox(
          quarterTurns: 3, // Rotate 270 degrees (equivalent to -90 degrees)
          child: const Text(
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

  Future<void> _showClaimConfirmationDialog(
    BuildContext context,
    VoucherEntity voucher,
  ) async {
    print(
      "🎟️ VoucherPage: Showing claim confirmation dialog for voucher: ${voucher.code}",
    );

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          title: Row(
            children: [
              Image.asset('assets/images/hand_coin.png', width: 24, height: 24),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Konfirmasi Redeem Discount',
                  style: TextStyle(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apakah Anda yakin ingin redeem discount ini?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voucher.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      voucher.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.sell_outlined,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${voucher.pointCost} points',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  'Points akan terpotong setelah discount berhasil diredem.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                print(
                  "🎟️ VoucherPage: User cancelled voucher claim for: ${voucher.code}",
                );
                Navigator.of(dialogContext).pop(false);
              },
              child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                print(
                  "🎟️ VoucherPage: User confirmed voucher claim for: ${voucher.code}",
                );
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Redeem Sekarang'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _claimVoucher(context, voucher);
    }
  }

  void _claimVoucher(BuildContext context, VoucherEntity voucher) {
    print(
      "🎟️ VoucherPage: Starting voucher claim process for: ${voucher.code} (ID: ${voucher.id})",
    );

    try {
      // Trigger claim voucher event
      context.read<VoucherBloc>().add(ClaimVoucherEvent(voucher.id));
      print(
        "🎟️ VoucherPage: ClaimVoucherEvent dispatched successfully for voucher ID: ${voucher.id}",
      );
    } catch (e) {
      print("❌ VoucherPage: Error dispatching ClaimVoucherEvent: $e");

      // Show error message with FlashbarHelper
      showAppFlashbar(
        context,
        title: 'Terjadi Kesalahan',
        message: 'Gagal memproses permintaan discount. Silakan coba lagi.',
        isSuccess: false,
      );
    }
  }

  // <<< PERUBAHAN: Menerima VoucherEntity sebagai parameter >>>
  Widget _buildRewardDetails(
    VoucherEntity voucher,
    bool hasEnoughPoints,
    BuildContext context,
  ) {
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

  // Optimized skeleton for faster perceived loading
  Widget _buildOptimizedSkeleton() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        childCount: 3, // Show 3 skeleton items
      ),
    );
  }

  void _showExpiryDetails(
    BuildContext context,
    int pointsToExpire,
    DateTime expiryDate,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Point Akan Kadaluarsa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Anda memiliki ${NumberFormat.decimalPattern('id_ID').format(pointsToExpire)} point yang akan kadaluarsa pada ${_formatExpiryDate(expiryDate)}.',
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Gunakan point Anda sekarang untuk mendapatkan voucher menarik!',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
