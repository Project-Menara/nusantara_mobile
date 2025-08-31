import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';
import 'package:nusantara_mobile/features/orders/presentation/widgets/order_skeleton.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  final List<String> _tabs = [
    'Semua',
    'Menunggu',
    'Diproses',
    'Dikirim',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.orange,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          return _buildOrderList(tab);
        }).toList(),
      ),
    );
  }

  Widget _buildOrderList(String status) {
    // Simulate loading state
    if (_isLoading) {
      return const OrderSkeletonList();
    }

    // Mock data untuk demonstrasi
    final orders = _getMockOrders(status);

    if (orders.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isLoading = true;
        });
        // TODO: Implement refresh functionality
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _isLoading = false;
        });
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return GestureDetector(
      onTap: () {
        context.push(InitialRoutes.orderDetail, extra: order.orderNumber);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Order #${order.orderNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildStatusChip(order.status),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat(
                          'dd MMM yyyy, HH:mm',
                        ).format(order.orderDate),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Items preview
                  ...order.items.take(2).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.fastfood,
                                color: Colors.grey[400],
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
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
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
                        ],
                      ),
                    );
                  }).toList(),

                  if (order.items.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${order.items.length - 2} item lainnya',
                        style: TextStyle(
                          color: Colors.orange[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Total and actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Pembayaran',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatCurrency(order.totalAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      _buildOrderActions(order),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        text = 'Menunggu';
        break;
      case OrderStatus.processing:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        text = 'Diproses';
        break;
      case OrderStatus.shipped:
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[700]!;
        text = 'Dikirim';
        break;
      case OrderStatus.completed:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        text = 'Selesai';
        break;
      case OrderStatus.cancelled:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        text = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildOrderActions(OrderModel order) {
    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            _buildActionButton(
              'Batalkan',
              Colors.grey[600]!,
              Colors.grey[100]!,
              () {
                // TODO: Implement cancel order
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton('Bayar', Colors.white, Colors.orange, () {
              // TODO: Implement payment
            }),
          ],
        );
      case OrderStatus.processing:
        return _buildActionButton('Lacak', Colors.white, Colors.blue, () {
          // TODO: Implement tracking
        });
      case OrderStatus.shipped:
        return _buildActionButton('Lacak', Colors.white, Colors.purple, () {
          // TODO: Implement tracking
        });
      case OrderStatus.completed:
        return Row(
          children: [
            _buildActionButton(
              'Beli Lagi',
              Colors.orange,
              Colors.orange[50]!,
              () {
                // TODO: Implement reorder
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton('Nilai', Colors.white, Colors.orange, () {
              // TODO: Implement review
            }),
          ],
        );
      case OrderStatus.cancelled:
        return _buildActionButton(
          'Beli Lagi',
          Colors.orange,
          Colors.orange[50]!,
          () {
            // TODO: Implement reorder
          },
        );
    }
  }

  Widget _buildActionButton(
    String text,
    Color textColor,
    Color backgroundColor,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: textColor == Colors.white
              ? BorderSide.none
              : BorderSide(color: textColor),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    String message;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'menunggu':
        message = 'Belum ada pesanan yang menunggu pembayaran';
        icon = Icons.pending_actions;
        break;
      case 'diproses':
        message = 'Belum ada pesanan yang sedang diproses';
        icon = Icons.engineering;
        break;
      case 'dikirim':
        message = 'Belum ada pesanan yang sedang dikirim';
        icon = Icons.local_shipping;
        break;
      case 'selesai':
        message = 'Belum ada pesanan yang selesai';
        icon = Icons.check_circle;
        break;
      case 'dibatalkan':
        message = 'Belum ada pesanan yang dibatalkan';
        icon = Icons.cancel;
        break;
      default:
        message = 'Belum ada pesanan';
        icon = Icons.receipt_long;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to home or products
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Mulai Belanja'),
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

  List<OrderModel> _getMockOrders(String status) {
    // Mock data untuk demonstrasi
    if (status == 'Semua') {
      return [
        OrderModel(
          orderNumber: '001234',
          orderDate: DateTime.now().subtract(const Duration(hours: 2)),
          status: OrderStatus.pending,
          totalAmount: 125000,
          items: [
            OrderItemModel(
              name: 'Bolu Menara Khas Nusantara',
              quantity: 2,
              price: 45000,
            ),
            OrderItemModel(
              name: 'Keripik Singkong Pedas',
              quantity: 1,
              price: 35000,
            ),
          ],
        ),
        OrderModel(
          orderNumber: '001233',
          orderDate: DateTime.now().subtract(const Duration(days: 1)),
          status: OrderStatus.processing,
          totalAmount: 89000,
          items: [
            OrderItemModel(
              name: 'Dodol Betawi Premium',
              quantity: 3,
              price: 25000,
            ),
            OrderItemModel(name: 'Kue Lapis Legit', quantity: 1, price: 75000),
          ],
        ),
        OrderModel(
          orderNumber: '001232',
          orderDate: DateTime.now().subtract(const Duration(days: 3)),
          status: OrderStatus.completed,
          totalAmount: 156000,
          items: [
            OrderItemModel(
              name: 'Paket Oleh-oleh Spesial',
              quantity: 1,
              price: 120000,
            ),
            OrderItemModel(
              name: 'Kopi Arabika Gayo',
              quantity: 2,
              price: 18000,
            ),
          ],
        ),
      ];
    }

    // Filter berdasarkan status
    final allOrders = _getMockOrders('Semua');
    return allOrders.where((order) {
      switch (status.toLowerCase()) {
        case 'menunggu':
          return order.status == OrderStatus.pending;
        case 'diproses':
          return order.status == OrderStatus.processing;
        case 'dikirim':
          return order.status == OrderStatus.shipped;
        case 'selesai':
          return order.status == OrderStatus.completed;
        case 'dibatalkan':
          return order.status == OrderStatus.cancelled;
        default:
          return false;
      }
    }).toList();
  }
}

// Mock models untuk demonstrasi
class OrderModel {
  final String orderNumber;
  final DateTime orderDate;
  final OrderStatus status;
  final double totalAmount;
  final List<OrderItemModel> items;

  OrderModel({
    required this.orderNumber,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    required this.items,
  });
}

class OrderItemModel {
  final String name;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.name,
    required this.quantity,
    required this.price,
  });
}

enum OrderStatus { pending, processing, shipped, completed, cancelled }
