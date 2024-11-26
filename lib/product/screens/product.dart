import 'package:flutter/material.dart';
class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_cart, size: 64),
          SizedBox(height: 16),
          Text('Catalog Content'),
        ],
      ),
    );
  }
}