import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_login_sqlite/data/databasehelper.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<Map<String, dynamic>>> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = DatabaseHelper().getCartItems();
  }

  String _formatCurrency(double amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(amount);
  }

  void _updateCart() {
    setState(() {
      _cartItems = DatabaseHelper().getCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ Hàng'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () async {
              await DatabaseHelper().clearCart();
              _updateCart();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cartItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Giỏ hàng của bạn đang trống'));
          } else {
            final cartItems = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            item['image'] != null
                                ? Image.network(item['image'], width: 70, height: 70, fit: BoxFit.cover)
                                : Icon(Icons.image, size: 70),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? 'Tên sản phẩm',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  SizedBox(height: 5),
                                  Text('Số lượng: ${item['quantity']}'),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove_circle, color: Colors.red),
                                        onPressed: () async {
                                          if (item['quantity'] > 1) {
                                            await DatabaseHelper().updateCartQuantity(item['id'], item['quantity'] - 1);
                                          } else {
                                            await DatabaseHelper().removeFromCart(item['id']);
                                          }
                                          _updateCart();
                                        },
                                      ),
                                      Text('${item['quantity']}'),
                                      IconButton(
                                        icon: Icon(Icons.add_circle, color: Colors.green),
                                        onPressed: () async {
                                          await DatabaseHelper().updateCartQuantity(item['id'], item['quantity'] + 1);
                                          _updateCart();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Giá: ${_formatCurrency(item['price'] ?? 0.0)}',
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await DatabaseHelper().removeFromCart(item['id']);
                                    _updateCart();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
