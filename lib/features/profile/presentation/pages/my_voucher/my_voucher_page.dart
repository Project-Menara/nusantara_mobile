import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nusantara_mobile/core/injection_container.dart';
import 'package:nusantara_mobile/features/voucher/domain/entities/claimed_voucher_entity.dart';
import 'package:nusantara_mobile/features/voucher/presentation/bloc/voucher/voucher_bloc.dart';
import 'package:nusantara_mobile/routes/initial_routes.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';

class MyVoucherPage extends StatefulWidget {
  const MyVoucherPage({super.key});

  @override
  State<MyVoucherPage> createState() => _MyVoucherPageState();
}

class _MyVoucherPageState extends State<MyVoucherPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ClaimedVoucherEntity> _filteredVouchers = [];
  List<ClaimedVoucherEntity> _allVouchers = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterVouchers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterVouchers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVouchers = _allVouchers.where((voucher) {
        final voucherCode = voucher.voucher.code.toLowerCase();
        final voucherDescription = voucher.voucher.description.toLowerCase();
        return voucherCode.contains(query) ||
            voucherDescription.contains(query);
      }).toList();
    });
  }

  void _updateVoucherList(List<ClaimedVoucherEntity> vouchers) {
    setState(() {
      _allVouchers = vouchers;
      _filterVouchers(); // Apply current filter
    });
  }

  @override
  Widget build(BuildContext context) {
    print("🎟️ MyVoucherPage: Building with VoucherBloc");

    return BlocProvider(
      create: (context) {
        print(
          "🎟️ MyVoucherPage: Creating VoucherBloc and triggering GetClaimedVouchersEvent",
        );
        final bloc = sl<VoucherBloc>();
        bloc.add(GetClaimedVouchersEvent());
        return bloc;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.orange,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Voucher Saya',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: BlocConsumer<VoucherBloc, VoucherState>(
                listener: (context, state) {
                  if (state is ClaimedVouchersLoaded) {
                    _updateVoucherList(state.claimedVouchers);
                  }
                },
                builder: (context, state) {
                  print(
                    "🎟️ MyVoucherPage: Current state: ${state.runtimeType}",
                  );

                  if (state is ClaimedVouchersLoading) {
                    return Skeletonizer(
                      enabled: true,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return _buildSkeletonCard();
                        },
                      ),
                    );
                  } else if (state is ClaimedVouchersError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${state.message}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<VoucherBloc>().add(
                                GetClaimedVouchersEvent(),
                              );
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  } else if (_filteredVouchers.isEmpty &&
                      _allVouchers.isNotEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Voucher tidak ditemukan',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  } else if (_allVouchers.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.card_giftcard,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada voucher',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: _filteredVouchers.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          try {
                            context.push(
                              InitialRoutes.myVoucherDetail,
                              extra: _filteredVouchers[index],
                            );
                          } catch (e) {
                            print('❌ Navigation error: $e');
                            // Fallback - show error message to user
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error navigating to voucher detail: $e',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                context.push(
                                  InitialRoutes.myVoucherDetail,
                                  extra: _filteredVouchers[index],
                                );
                              },
                              child: _VoucherCard(
                                voucher: _filteredVouchers[index],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search Voucher',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: Colors.grey[500]),
            onPressed: () {
              _searchController.clear();
            },
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final ClaimedVoucherEntity voucher;

  const _VoucherCard({required this.voucher});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon voucher
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Voucher details - Flexible to prevent overflow
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      voucher.voucher.code,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      voucher.voucher.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Date row with flexible layout
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Exp: ${dateFormatter.format(voucher.voucher.endDate)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status indicator - Flexible to prevent overflow
              Flexible(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(voucher.voucher.endDate),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      _getStatusText(voucher.voucher.endDate),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;

    if (difference < 0) {
      return Colors.grey; // Expired
    } else if (difference <= 7) {
      return Colors.orange; // Expiring soon
    } else {
      return Colors.green; // Valid
    }
  }

  String _getStatusText(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;

    if (difference < 0) {
      return 'Expired';
    } else if (difference <= 7) {
      return 'Soon';
    } else {
      return 'Active';
    }
  }
}
