import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nusantara_mobile/features/cart/presentation/bloc/cart/cart_bloc.dart';

class CartDeleteButton extends StatelessWidget {
  final String productId;
  final String productName;

  const CartDeleteButton({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showDeleteDialog(context),
      icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 24),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      tooltip: 'Hapus Item',
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Item'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "$productName" dari keranjang?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CartBloc>().add(DeleteCartItemEvent(productId));
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
