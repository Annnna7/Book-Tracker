import 'package:flutter/material.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'СТРАНИЦА: Список Желаемого (Wishlist)',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}