// Salin dan ganti seluruh isi file Anda dengan kode ini

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  late VoucherBloc _voucherBloc;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterVouchers);

    // --- PERUBAHAN ---
    // 1. Dapatkan BLoC yang sudah ada dari context.
    _voucherBloc = context.read<VoucherBloc>();

    // 2. Trigger event untuk mengambil data.
    // Tambahkan pengecekan agar tidak fetch ulang jika data sudah ada.
    if (_voucherBloc.state is! ClaimedVouchersLoaded) {
      // debug: 🎟️ MyVoucherPage: Memuat data claimed vouchers...
      _voucherBloc.add(GetClaimedVouchersEvent());
    } else {
      // debug: 🎟️ MyVoucherPage: Data claimed vouchers sudah ada.
      // Jika data sudah ada, langsung update list lokal
      final currentState = _voucherBloc.state as ClaimedVouchersLoaded;
      _updateVoucherList(currentState.claimedVouchers);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterVouchers);
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
    // Memastikan widget masih ada di tree sebelum memanggil setState
    if (mounted) {
      setState(() {
        _allVouchers = vouchers;
        _filterVouchers(); // Terapkan filter yang mungkin sudah ada
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- PERUBAHAN ---
    // 3. Hapus BlocProvider lokal. Widget sekarang akan menggunakan BLoC dari router.
    return Scaffold(
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
                // debug: 🎟️ MyVoucherPage: Current state: ${state.runtimeType}

                if (state is ClaimedVouchersLoading) {
                  return Skeletonizer(
                    enabled: true,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      itemCount: 3,
                      itemBuilder: (context, index) => _buildSkeletonCard(),
                    ),
                  );
                }

                if (state is ClaimedVouchersError) {
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
                          onPressed: () => context.read<VoucherBloc>().add(
                            GetClaimedVouchersEvent(),
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (_allVouchers.isEmpty && state is! ClaimedVouchersLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.card_giftcard, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Anda belum memiliki voucher',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredVouchers.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Voucher yang Anda cari tidak ditemukan',
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
                    final voucher = _filteredVouchers[index];
                    return _VoucherCard(
                      voucher: voucher,
                      onTap: () {
                        context.push(
                          InitialRoutes.myVoucherDetail,
                          extra: voucher,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari voucher Anda',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: 150,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherCard extends StatelessWidget {
  final ClaimedVoucherEntity voucher;
  final VoidCallback onTap;

  const _VoucherCard({required this.voucher, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_offer,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Berlaku hingga: ${dateFormatter.format(voucher.voucher.endDate)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
