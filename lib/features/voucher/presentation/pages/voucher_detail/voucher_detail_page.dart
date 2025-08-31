import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:nusantara_mobile/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:nusantara_mobile/features/point/presentation/bloc/point/point_bloc.dart';
import 'package:nusantara_mobile/features/point/presentation/bloc/point/point_event.dart';
import 'package:nusantara_mobile/features/point/presentation/bloc/point/point_state.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/voucher_entity.dart';
import 'package:nusantara_mobile/features/voucher/presentation/bloc/voucher/voucher_bloc.dart';
import 'package:go_router/go_router.dart';

class VoucherDetailPage extends StatefulWidget {
  final String voucherId;

  const VoucherDetailPage({super.key, required this.voucherId});

  @override
  State<VoucherDetailPage> createState() => _VoucherDetailPageState();
}

class _VoucherDetailPageState extends State<VoucherDetailPage> {
  @override
  Widget build(BuildContext context) {
    print(
      "🎫 VoucherDetailPage: Creating FRESH VoucherBloc for ID: ${widget.voucherId}",
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          key: ValueKey(
            'voucher_detail_${widget.voucherId}_${DateTime.now().millisecondsSinceEpoch}',
          ),
          create: (context) {
            print(
              "🎫 VoucherDetailPage: Attempting to get FRESH VoucherBloc from service locator",
            );
            try {
              final bloc = sl<VoucherBloc>();
              print(
                "🎫 VoucherDetailPage: FRESH VoucherBloc created successfully: ${bloc.runtimeType}",
              );
              print(
                "🎫 VoucherDetailPage: Current bloc state: ${bloc.state.runtimeType}",
              );

              // Trigger get voucher by id event
              print(
                "🎫 VoucherDetailPage: Adding GetVoucherByIdEvent with ID: ${widget.voucherId}",
              );
              bloc.add(GetVoucherByIdEvent(widget.voucherId));
              return bloc;
            } catch (e) {
              print("❌ VoucherDetailPage: Error creating VoucherBloc: $e");
              print("❌ VoucherDetailPage: Error type: ${e.runtimeType}");
              rethrow;
            }
          },
        ),
        BlocProvider(
          create: (context) {
            print("📊 VoucherDetailPage: Creating PointBloc");
            final bloc = sl<PointBloc>();
            bloc.add(const GetCustomerPointEvent());
            return bloc;
          },
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthTokenExpiredState) {
            print(
              "🔐 VoucherDetailPage: Token expired detected, navigating to login",
            );

            // Navigate to login immediately without showing snackbar to avoid context issues
            context.go('/login');
          }
        },
        child: VoucherDetailView(voucherId: widget.voucherId),
      ),
    );
  }
}

class VoucherDetailView extends StatelessWidget {
  final String voucherId;

  const VoucherDetailView({super.key, required this.voucherId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detail Voucher',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<VoucherBloc, VoucherState>(
        builder: (context, state) {
          print("🎫 VoucherDetailView: Current state: ${state.runtimeType}");

          if (state is VoucherByIdLoading) {
            print("⏳ VoucherDetailView: Loading state detected");
            return _buildLoadingState();
          } else if (state is VoucherByIdLoaded) {
            print(
              "✅ VoucherDetailView: Loaded state detected: ${state.voucher.code}",
            );
            return _buildLoadedState(context, state.voucher);
          } else if (state is VoucherByIdError) {
            print(
              "❌ VoucherDetailView: Error state detected: ${state.message}",
            );
            return _buildErrorState(context, state.message);
          } else {
            print("🔄 VoucherDetailView: Initial state detected");
            return _buildLoadingState();
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat detail voucher...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.orange, size: 64),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat detail voucher',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<VoucherBloc>().add(GetVoucherByIdEvent(voucherId));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, VoucherEntity voucher) {
    return BlocBuilder<PointBloc, PointState>(
      builder: (context, pointState) {
        int userPoints = 0;

        if (pointState is PointLoaded) {
          userPoints = pointState.point.totalPoints;
          print("📊 VoucherDetailPage: Points loaded: $userPoints");
        } else if (pointState is PointLoading) {
          print("📊 VoucherDetailPage: Points loading...");
        } else if (pointState is PointError) {
          print("❌ VoucherDetailPage: Points error: ${pointState.message}");
        }

        final hasEnoughPoints = userPoints >= voucher.pointCost;

        return RefreshIndicator(
          onRefresh: () async {
            context.read<VoucherBloc>().add(GetVoucherByIdEvent(voucherId));
            context.read<PointBloc>().add(const GetCustomerPointEvent());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Voucher Card
                _buildVoucherCard(voucher, hasEnoughPoints),

                const SizedBox(height: 24),

                // Voucher Details
                _buildVoucherDetails(voucher),

                const SizedBox(height: 24),

                // Terms and Conditions
                _buildTermsAndConditions(voucher),

                const SizedBox(height: 24),

                // Action Button
                _buildActionButton(
                  context,
                  voucher,
                  hasEnoughPoints,
                  userPoints,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVoucherCard(VoucherEntity voucher, bool hasEnoughPoints) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    voucher.code,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${voucher.pointCost} Points',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              voucher.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Discount Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _getDiscountText(voucher),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherDetails(VoucherEntity voucher) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Voucher',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            _buildDetailRow(
              'Minimum Pembelian',
              'Rp ${NumberFormat('#,###', 'id').format(voucher.minimumSpend)}',
              Icons.shopping_cart,
            ),

            const Divider(height: 24),

            _buildDetailRow(
              'Periode Berlaku',
              '${DateFormat('dd MMM yyyy', 'id').format(voucher.startDate)} - ${DateFormat('dd MMM yyyy', 'id').format(voucher.endDate)}',
              Icons.calendar_today,
            ),

            const Divider(height: 24),

            _buildDetailRow(
              'Kuota Tersedia',
              '${voucher.quota} voucher',
              Icons.confirmation_number,
            ),

            const Divider(height: 24),

            _buildDetailRow(
              'Biaya Tukar',
              '${voucher.pointCost} poin',
              Icons.stars,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.orange),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions(VoucherEntity voucher) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Syarat & Ketentuan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            _buildTermItem(
              'Voucher hanya berlaku untuk pembelian minimum Rp ${NumberFormat('#,###', 'id').format(voucher.minimumSpend)}',
            ),
            _buildTermItem(
              'Voucher berlaku dari tanggal ${DateFormat('dd MMM yyyy', 'id').format(voucher.startDate)} sampai ${DateFormat('dd MMM yyyy', 'id').format(voucher.endDate)}',
            ),
            _buildTermItem(
              'Voucher tidak dapat digabungkan dengan promo lainnya',
            ),
            _buildTermItem(
              'Voucher yang sudah ditukar tidak dapat dikembalikan',
            ),
            _buildTermItem(
              'Kuota voucher terbatas, berlaku selama persediaan masih ada',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    VoucherEntity voucher,
    bool hasEnoughPoints,
    int userPoints,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton(
        onPressed: (hasEnoughPoints && !voucher.isClaimed)
            ? () => _showRedeemDialog(context, voucher, userPoints)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: (hasEnoughPoints && !voucher.isClaimed)
              ? Colors.orange
              : Colors.grey.shade400,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: (hasEnoughPoints && !voucher.isClaimed) ? 6 : 0,
        ),
        child: Text(
          voucher.isClaimed
              ? 'Sudah Diredem'
              : hasEnoughPoints
              ? 'Redeem Discount (${voucher.pointCost} Poin)'
              : 'Poin Tidak Mencukupi (${userPoints}/${voucher.pointCost})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showRedeemDialog(
    BuildContext context,
    VoucherEntity voucher,
    int userPoints,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Konfirmasi Penukaran',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin menukar voucher "${voucher.code}"?',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Poin Anda saat ini: $userPoints',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Biaya voucher: ${voucher.pointCost}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Divider(height: 16),
                    Text(
                      'Sisa poin setelah penukaran: ${userPoints - voucher.pointCost}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _redeemVoucher(context, voucher);
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
  }

  void _redeemVoucher(BuildContext context, VoucherEntity voucher) {
    // TODO: Implement voucher redemption logic
    // This would typically involve calling a RedeemVoucherUseCase
    showAppFlashbar(
      context,
      title: 'Discount Berhasil Diredem!',
      message:
          'Discount "${voucher.code}" berhasil diredem dan dapat digunakan.',
      isSuccess: true,
    );
  }

  String _getDiscountText(VoucherEntity voucher) {
    if (voucher.discountType == 'amount') {
      return 'Diskon Rp ${NumberFormat('#,###', 'id').format(voucher.discountAmount)}';
    } else {
      return 'Diskon ${voucher.discountPercent}%';
    }
  }
}
