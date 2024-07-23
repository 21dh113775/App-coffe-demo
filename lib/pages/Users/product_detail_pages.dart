import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  ProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image.network(
              product['image'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
            Text(
              product['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Giá: \$${product['price']}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Giá cũ: \$${product['old_price']}',
              style: TextStyle(
                fontSize: 16,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            SizedBox(height: 16),
            Text(
              product['description'],
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
