import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';

class RecentOrders extends StatelessWidget {
  const RecentOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "PESANAN TERBARU",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              GestureDetector(
                onTap: () => context.go(InitialRoutes.orders),
                child: const Text(
                  "Lihat Semua",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Orders list
        Container(
          height: 140,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _mockOrders.length,
            itemBuilder: (context, index) {
              final order = _mockOrders[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                child: _buildOrderCard(context, order),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.go('/orders/detail/${order['id']}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order['id'].toString().substring(0, 8)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order['status'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(order['status']),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Order details
              Text(
                order['title'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              Text(
                '${order['items']} item • ${order['date']}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),

              const Spacer(),

              // Price and action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rp ${_formatCurrency(order['total'])}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  if (order['status'] == 'Dikirim')
                    const Icon(
                      Icons.local_shipping,
                      size: 16,
                      color: Colors.blue,
                    )
                  else if (order['status'] == 'Selesai')
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    )
                  else
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.orange,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu':
        return Colors.orange;
      case 'Diproses':
        return Colors.blue;
      case 'Dikirim':
        return Colors.purple;
      case 'Selesai':
        return Colors.green;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  // Mock data untuk recent orders
  static final List<Map<String, dynamic>> _mockOrders = [
    {
      'id': 'ORD-2024-001',
      'title': 'Bolu Meranti Medan + Kopi Luwak',
      'items': 3,
      'total': 285000,
      'status': 'Dikirim',
      'date': '12 Agt',
    },
    {
      'id': 'ORD-2024-002',
      'title': 'Rendang Padang Original',
      'items': 2,
      'total': 150000,
      'status': 'Selesai',
      'date': '10 Agt',
    },
    {
      'id': 'ORD-2024-003',
      'title': 'Sambal Lado Mudo + Keripik Balado',
      'items': 4,
      'total': 95000,
      'status': 'Diproses',
      'date': '14 Agt',
    },
    {
      'id': 'ORD-2024-004',
      'title': 'Dodol Betawi Premium',
      'items': 1,
      'total': 45000,
      'status': 'Menunggu',
      'date': '13 Agt',
    },
  ];
}
