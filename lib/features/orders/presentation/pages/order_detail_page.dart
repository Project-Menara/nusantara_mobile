import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nusantara_mobile/features/orders/presentation/widgets/order_tracking_widget.dart';
import 'package:go_router/go_router.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // Mock data untuk demonstrasi
    final order = _getMockOrderDetail(orderId);
    final topPad = MediaQuery.of(context).padding.top;
    final headerHeight = 180.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Header Background
          Container(
            height: headerHeight,
            decoration: const BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
            ),
          ),

          // Content
          Column(
            children: [
              SizedBox(height: topPad),

              // Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/orders');
                        }
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      'Detail Pesanan #${order.orderNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        // TODO: Implement share functionality
                      },
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Order Tracking
                      if (order.status == OrderDetailStatus.shipped ||
                          order.status == OrderDetailStatus.delivered)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: OrderTrackingWidget(
                            orderNumber: order.orderNumber,
                            currentStatus: _mapToTrackingStatus(order.status),
                            trackingSteps: _generateTrackingSteps(order.status),
                          ),
                        ),

                      // Order Info
                      _buildOrderInfoCard(order),

                      // Items
                      _buildItemsCard(order),

                      // Payment Info
                      _buildPaymentCard(order),

                      // Delivery Info
                      _buildDeliveryCard(order),

                      // Actions
                      if (order.status != OrderDetailStatus.cancelled &&
                          order.status != OrderDetailStatus.delivered)
                        _buildActionsCard(order, context),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(OrderDetailModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Informasi Pesanan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _buildDetailStatusChip(order.status),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Nomor Pesanan', '#${order.orderNumber}'),
          _buildInfoRow(
            'Tanggal Pesanan',
            DateFormat('dd MMM yyyy, HH:mm').format(order.orderDate),
          ),
          if (order.estimatedDelivery != null)
            _buildInfoRow(
              'Estimasi Pengiriman',
              DateFormat('dd MMM yyyy').format(order.estimatedDelivery!),
            ),
          _buildInfoRow('Metode Pembayaran', order.paymentMethod),
          if (order.trackingNumber != null)
            _buildInfoRow('Nomor Resi', order.trackingNumber!),
        ],
      ),
    );
  }

  Widget _buildItemsCard(OrderDetailModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          const Text(
            'Item Pesanan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.fastfood,
                        color: Colors.grey[400],
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (item.variant != null)
                          Text(
                            'Varian: ${item.variant}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantity}x • ${_formatCurrency(item.price)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(item.price * item.quantity),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(OrderDetailModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          const Text(
            'Rincian Pembayaran',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildPaymentRow('Subtotal', order.subtotal),
          if (order.discount > 0)
            _buildPaymentRow('Diskon', -order.discount, isDiscount: true),
          _buildPaymentRow('Ongkos Kirim', order.shippingCost),
          if (order.tax > 0) _buildPaymentRow('Pajak', order.tax),
          const Divider(height: 24),
          _buildPaymentRow(
            'Total Pembayaran',
            order.totalAmount,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(OrderDetailModel order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          const Text(
            'Alamat Pengiriman',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: Colors.orange[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.deliveryAddress.recipientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.deliveryAddress.phoneNumber,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.deliveryAddress.fullAddress,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(OrderDetailModel order, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        children: [
          if (order.status == OrderDetailStatus.pending) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement payment
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Bayar Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showCancelDialog(context, order);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Batalkan Pesanan'),
              ),
            ),
          ],
          if (order.status == OrderDetailStatus.processing ||
              order.status == OrderDetailStatus.shipped) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement chat with seller
                },
                icon: const Icon(Icons.chat),
                label: const Text('Hubungi Penjual'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailStatusChip(OrderDetailStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case OrderDetailStatus.pending:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        text = 'Menunggu Pembayaran';
        break;
      case OrderDetailStatus.processing:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        text = 'Sedang Diproses';
        break;
      case OrderDetailStatus.shipped:
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[700]!;
        text = 'Dalam Pengiriman';
        break;
      case OrderDetailStatus.delivered:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        text = 'Pesanan Sampai';
        break;
      case OrderDetailStatus.cancelled:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        text = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    double amount, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: isTotal ? 14 : 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isDiscount
                  ? Colors.green
                  : isTotal
                  ? Colors.orange
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, OrderDetailModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: Text(
          'Apakah Anda yakin ingin membatalkan pesanan #${order.orderNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancel order
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pesanan berhasil dibatalkan'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  OrderTrackingStatus _mapToTrackingStatus(OrderDetailStatus status) {
    switch (status) {
      case OrderDetailStatus.pending:
        return OrderTrackingStatus.orderReceived;
      case OrderDetailStatus.processing:
        return OrderTrackingStatus.preparing;
      case OrderDetailStatus.shipped:
        return OrderTrackingStatus.shipped;
      case OrderDetailStatus.delivered:
        return OrderTrackingStatus.delivered;
      case OrderDetailStatus.cancelled:
        return OrderTrackingStatus.cancelled;
    }
  }

  List<TrackingStep> _generateTrackingSteps(OrderDetailStatus currentStatus) {
    final steps = [
      TrackingStep(
        title: 'Pesanan Diterima',
        description: 'Pesanan telah diterima dan akan segera diproses',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isCompleted: true,
      ),
      TrackingStep(
        title: 'Sedang Disiapkan',
        description: 'Pesanan sedang disiapkan oleh toko',
        timestamp: currentStatus.index >= 1
            ? DateTime.now().subtract(const Duration(days: 1))
            : null,
        isCompleted: currentStatus.index >= 1,
      ),
      TrackingStep(
        title: 'Dalam Pengiriman',
        description: 'Pesanan sedang dalam perjalanan',
        timestamp: currentStatus.index >= 2 ? DateTime.now() : null,
        isCompleted: currentStatus.index >= 2,
      ),
      TrackingStep(
        title: 'Pesanan Sampai',
        description: 'Pesanan telah sampai di alamat tujuan',
        timestamp: currentStatus.index >= 3
            ? DateTime.now().add(const Duration(days: 1))
            : null,
        isCompleted: currentStatus.index >= 3,
      ),
    ];

    return steps;
  }

  OrderDetailModel _getMockOrderDetail(String orderId) {
    return OrderDetailModel(
      orderNumber: '001234',
      orderDate: DateTime.now().subtract(const Duration(hours: 2)),
      status: OrderDetailStatus.processing,
      paymentMethod: 'Transfer Bank BCA',
      estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
      trackingNumber: 'JNE123456789',
      subtotal: 90000,
      discount: 5000,
      shippingCost: 15000,
      tax: 0,
      totalAmount: 100000,
      items: [
        OrderDetailItemModel(
          name: 'Bolu Menara Khas Nusantara',
          variant: 'Rasa Pandan',
          quantity: 2,
          price: 45000,
        ),
      ],
      deliveryAddress: DeliveryAddressModel(
        recipientName: 'John Doe',
        phoneNumber: '+62 812 3456 7890',
        fullAddress:
            'Jl. Merdeka No. 123, RT 01/RW 02, Kelurahan Menteng, Kecamatan Menteng, Jakarta Pusat 10310',
      ),
    );
  }
}

// Mock models untuk detail order
class OrderDetailModel {
  final String orderNumber;
  final DateTime orderDate;
  final OrderDetailStatus status;
  final String paymentMethod;
  final DateTime? estimatedDelivery;
  final String? trackingNumber;
  final double subtotal;
  final double discount;
  final double shippingCost;
  final double tax;
  final double totalAmount;
  final List<OrderDetailItemModel> items;
  final DeliveryAddressModel deliveryAddress;

  OrderDetailModel({
    required this.orderNumber,
    required this.orderDate,
    required this.status,
    required this.paymentMethod,
    this.estimatedDelivery,
    this.trackingNumber,
    required this.subtotal,
    required this.discount,
    required this.shippingCost,
    required this.tax,
    required this.totalAmount,
    required this.items,
    required this.deliveryAddress,
  });
}

class OrderDetailItemModel {
  final String name;
  final String? variant;
  final int quantity;
  final double price;

  OrderDetailItemModel({
    required this.name,
    this.variant,
    required this.quantity,
    required this.price,
  });
}

class DeliveryAddressModel {
  final String recipientName;
  final String phoneNumber;
  final String fullAddress;

  DeliveryAddressModel({
    required this.recipientName,
    required this.phoneNumber,
    required this.fullAddress,
  });
}

enum OrderDetailStatus { pending, processing, shipped, delivered, cancelled }
