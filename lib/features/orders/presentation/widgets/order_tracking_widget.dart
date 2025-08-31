import 'package:flutter/material.dart';

class OrderTrackingWidget extends StatelessWidget {
  final String orderNumber;
  final OrderTrackingStatus currentStatus;
  final List<TrackingStep> trackingSteps;

  const OrderTrackingWidget({
    super.key,
    required this.orderNumber,
    required this.currentStatus,
    required this.trackingSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.local_shipping, color: Colors.orange[600], size: 24),
              const SizedBox(width: 8),
              Text(
                'Lacak Pesanan #$orderNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Current Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor(currentStatus).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getStatusColor(currentStatus),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(currentStatus),
                  color: _getStatusColor(currentStatus),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusTitle(currentStatus),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(currentStatus),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _getStatusDescription(currentStatus),
                        style: TextStyle(
                          color: _getStatusColor(currentStatus),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tracking Timeline
          Text(
            'Riwayat Pengiriman',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(height: 12),

          ...trackingSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == trackingSteps.length - 1;

            return _buildTrackingStep(step, isLast);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(TrackingStep step, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: step.isCompleted ? Colors.orange : Colors.grey[300],
                shape: BoxShape.circle,
                border: Border.all(
                  color: step.isCompleted ? Colors.orange : Colors.grey[400]!,
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: step.isCompleted ? Colors.orange : Colors.grey[300],
              ),
          ],
        ),

        const SizedBox(width: 12),

        // Step content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: step.isCompleted ? Colors.black87 : Colors.grey[500],
                  ),
                ),
                if (step.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: step.isCompleted
                          ? Colors.grey[600]
                          : Colors.grey[400],
                    ),
                  ),
                ],
                if (step.timestamp != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(step.timestamp!),
                    style: TextStyle(
                      fontSize: 11,
                      color: step.isCompleted
                          ? Colors.grey[500]
                          : Colors.grey[400],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderTrackingStatus status) {
    switch (status) {
      case OrderTrackingStatus.orderReceived:
        return Colors.blue;
      case OrderTrackingStatus.preparing:
        return Colors.orange;
      case OrderTrackingStatus.shipped:
        return Colors.purple;
      case OrderTrackingStatus.delivered:
        return Colors.green;
      case OrderTrackingStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderTrackingStatus status) {
    switch (status) {
      case OrderTrackingStatus.orderReceived:
        return Icons.receipt;
      case OrderTrackingStatus.preparing:
        return Icons.kitchen;
      case OrderTrackingStatus.shipped:
        return Icons.local_shipping;
      case OrderTrackingStatus.delivered:
        return Icons.check_circle;
      case OrderTrackingStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusTitle(OrderTrackingStatus status) {
    switch (status) {
      case OrderTrackingStatus.orderReceived:
        return 'Pesanan Diterima';
      case OrderTrackingStatus.preparing:
        return 'Sedang Disiapkan';
      case OrderTrackingStatus.shipped:
        return 'Dalam Pengiriman';
      case OrderTrackingStatus.delivered:
        return 'Pesanan Sampai';
      case OrderTrackingStatus.cancelled:
        return 'Pesanan Dibatalkan';
    }
  }

  String _getStatusDescription(OrderTrackingStatus status) {
    switch (status) {
      case OrderTrackingStatus.orderReceived:
        return 'Pesanan Anda telah diterima dan akan segera diproses';
      case OrderTrackingStatus.preparing:
        return 'Pesanan sedang disiapkan oleh toko';
      case OrderTrackingStatus.shipped:
        return 'Pesanan dalam perjalanan menuju alamat Anda';
      case OrderTrackingStatus.delivered:
        return 'Pesanan telah sampai di tujuan';
      case OrderTrackingStatus.cancelled:
        return 'Pesanan telah dibatalkan';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }
}

class TrackingStep {
  final String title;
  final String? description;
  final DateTime? timestamp;
  final bool isCompleted;

  TrackingStep({
    required this.title,
    this.description,
    this.timestamp,
    required this.isCompleted,
  });
}

enum OrderTrackingStatus {
  orderReceived,
  preparing,
  shipped,
  delivered,
  cancelled,
}
