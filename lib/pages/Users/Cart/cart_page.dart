import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_login_sqlite/data/databasehelper.dart';

import '../../Payment/payment_method_page.dart';

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Giỏ hàng'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(item);
                    },
                  ),
                ),
                _buildBottomSection(cartItems),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item['image'] != null
                ? Image.network(item['image'],
                    width: 80, height: 80, fit: BoxFit.cover)
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: Icon(Icons.image, size: 40, color: Colors.grey[600]),
                  ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? 'Tên sản phẩm',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  item['description'] ?? 'Mô tả sản phẩm',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _formatCurrency(item['price'] ?? 0.0),
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    IconButton(
                      icon:
                          Icon(Icons.remove_circle_outline, color: Colors.grey),
                      onPressed: () async {
                        if (item['quantity'] > 1) {
                          await DatabaseHelper().updateCartQuantity(
                              item['id'], item['quantity'] - 1);
                        } else {
                          await DatabaseHelper().removeFromCart(item['id']);
                        }
                        _updateCart();
                      },
                    ),
                    Text('${item['quantity']}', style: TextStyle(fontSize: 16)),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: () async {
                        await DatabaseHelper().updateCartQuantity(
                            item['id'], item['quantity'] + 1);
                        _updateCart();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(List<Map<String, dynamic>> cartItems) {
    double total = cartItems.fold(
        0, (sum, item) => sum + (item['price'] ?? 0) * (item['quantity'] ?? 1));

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${cartItems.length} sản phẩm',
                  style: TextStyle(fontSize: 16)),
              Text(_formatCurrency(total),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton(
            child: Text('Thanh Toán', style: TextStyle(fontSize: 16, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentMethodPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
