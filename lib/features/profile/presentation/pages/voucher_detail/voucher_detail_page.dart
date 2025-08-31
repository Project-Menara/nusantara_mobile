import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nusantara_mobile/core/helper/flashbar_helper.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/claimed_voucher_entity.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/voucher_entity.dart';

class VoucherDetailPage extends StatelessWidget {
  final ClaimedVoucherEntity claimedVoucher;

  const VoucherDetailPage({super.key, required this.claimedVoucher});

  @override
  Widget build(BuildContext context) {
    final voucher = claimedVoucher.voucher;
    final voucherDetail = claimedVoucher.voucherDetail;
    final dateFormatter = DateFormat('dd MMMM yyyy');
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Voucher Card Header
            _buildVoucherCard(
              voucher,
              voucherDetail,
              dateFormatter,
              currencyFormatter,
            ),

            const SizedBox(height: 20),

            // Voucher Details Section
            _buildDetailsSection(
              voucher,
              voucherDetail,
              dateFormatter,
              currencyFormatter,
            ),

            const SizedBox(height: 20),

            // Terms & Conditions
            _buildTermsSection(voucherDetail),

            const SizedBox(height: 20),

            // Usage Information
            _buildUsageSection(claimedVoucher, dateFormatter),

            const SizedBox(height: 30),

            // Action Buttons
            _buildActionButtons(context, claimedVoucher),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherCard(
    VoucherEntity voucher,
    VoucherDetailEntity voucherDetail,
    DateFormat dateFormatter,
    NumberFormat currencyFormatter,
  ) {
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
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildStatusBadge(voucher.endDate),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              voucher.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.local_offer,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getDiscountText(voucherDetail),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;

    Color badgeColor;
    String badgeText;

    if (difference < 0) {
      badgeColor = Colors.grey[700]!;
      badgeText = 'Expired';
    } else if (difference <= 7) {
      badgeColor = Colors.red[700]!;
      badgeText = 'Segera Berakhir';
    } else {
      badgeColor = Colors.green[700]!;
      badgeText = 'Aktif';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        badgeText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailsSection(
    VoucherEntity voucher,
    VoucherDetailEntity voucherDetail,
    DateFormat dateFormatter,
    NumberFormat currencyFormatter,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
              'Jenis Discount',
              voucherDetail.discountType == 'percent'
                  ? 'Persentase'
                  : 'Nominal',
              Icons.percent,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              'Nilai Discount',
              _getDiscountText(voucherDetail),
              Icons.local_offer,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              'Minimum Pembelian',
              currencyFormatter.format(voucherDetail.minPurchaseAmount),
              Icons.shopping_cart,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              'Berlaku Dari',
              dateFormatter.format(voucherDetail.validFrom),
              Icons.calendar_today,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              'Berlaku Sampai',
              dateFormatter.format(voucherDetail.validUntil),
              Icons.schedule,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.orange),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
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

  Widget _buildTermsSection(VoucherDetailEntity voucherDetail) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Syarat & Ketentuan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTermItem(
              'Voucher hanya berlaku untuk pembelian dengan minimum amount yang tertera',
            ),
            _buildTermItem(
              'Voucher tidak dapat diuangkan dan tidak dapat dikembalikan',
            ),
            _buildTermItem(
              'Voucher hanya berlaku dalam periode yang telah ditentukan',
            ),
            _buildTermItem(
              'Voucher tidak dapat digabungkan dengan promo lainnya',
            ),
            _buildTermItem('Voucher hanya dapat digunakan satu kali'),
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
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageSection(
    ClaimedVoucherEntity claimedVoucher,
    DateFormat dateFormatter,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Informasi Penggunaan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildUsageRow(
              'Tanggal Diklaim',
              dateFormatter.format(claimedVoucher.claimedAt),
              Icons.add_circle_outline,
            ),
            const Divider(height: 24),
            _buildUsageRow(
              'Status Penggunaan',
              claimedVoucher.isUsed ? 'Sudah Digunakan' : 'Belum Digunakan',
              claimedVoucher.isUsed ? Icons.check_circle : Icons.pending,
            ),
            if (claimedVoucher.isUsed && claimedVoucher.redeemedAt != null) ...[
              const Divider(height: 24),
              _buildUsageRow(
                'Tanggal Digunakan',
                dateFormatter.format(claimedVoucher.redeemedAt!),
                Icons.check_circle,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsageRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
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

  Widget _buildActionButtons(
    BuildContext context,
    ClaimedVoucherEntity claimedVoucher,
  ) {
    final isExpired = claimedVoucher.voucher.endDate.isBefore(DateTime.now());

    return Column(
      children: [
        // Copy Code Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: claimedVoucher.voucher.code),
              );
              showAppFlashbar(
                context,
                title: 'Berhasil!',
                message: 'Kode voucher telah disalin ke clipboard',
                isSuccess: true,
              );
            },
            icon: const Icon(Icons.copy, color: Colors.white),
            label: const Text(
              'Salin Kode Voucher',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Use Voucher Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: (claimedVoucher.isUsed || isExpired)
                ? null
                : () {
                    // TODO: Implement voucher usage functionality
                    showAppFlashbar(
                      context,
                      title: 'Info',
                      message: 'Fitur penggunaan voucher akan segera tersedia',
                      isSuccess: true,
                    );
                  },
            icon: Icon(
              claimedVoucher.isUsed
                  ? Icons.check_circle
                  : isExpired
                  ? Icons.timer_off
                  : Icons.shopping_cart,
              color: (claimedVoucher.isUsed || isExpired)
                  ? Colors.grey[600]
                  : Colors.white,
            ),
            label: Text(
              claimedVoucher.isUsed
                  ? 'Voucher Sudah Digunakan'
                  : isExpired
                  ? 'Voucher Sudah Expired'
                  : 'Gunakan Voucher',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: (claimedVoucher.isUsed || isExpired)
                    ? Colors.grey[600]
                    : Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: (claimedVoucher.isUsed || isExpired)
                  ? Colors.grey[300]
                  : Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getDiscountText(VoucherDetailEntity voucherDetail) {
    if (voucherDetail.discountType == 'percent') {
      return '${voucherDetail.discountPercent.toStringAsFixed(0)}% OFF';
    } else {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return '${formatter.format(voucherDetail.discountAmount)} OFF';
    }
  }
}
