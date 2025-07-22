import 'package:flutter/material.dart';

class NearbyStoreList extends StatelessWidget {
  const NearbyStoreList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Data ini juga seharusnya dari BLoC nanti
          _buildStoreCard("BALIGE", "JL. PEMATANG SIANTAR", "9.00KM", "Buka pukul 08.30 AM"),
          const SizedBox(height: 12),
          _buildStoreCard("TOKO LAIN", "JL. KOTA SEBELAH", "12.5KM", "Buka pukul 09.00 AM"),
        ],
      ),
    );
  }

  Widget _buildStoreCard(String name, String address, String distance, String openTime) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(distance, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(address, style: const TextStyle(color: Colors.grey)),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text("Tutup", style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text(openTime, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}