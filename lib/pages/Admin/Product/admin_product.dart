import 'package:flutter/material.dart';
import '../../../data/databasehelper.dart';
import './admin_add_product.dart';

class AdminProductPage extends StatefulWidget {
  @override
  _AdminProductPageState createState() => _AdminProductPageState();
}

class _AdminProductPageState extends State<AdminProductPage> {
  final dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    return await dbHelper.getProducts();
  }

  void _navigateToAddProductPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductPage()),
    );
    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Quản lý sản phẩm'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navigateToAddProductPage,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Chưa có sản phẩm nào'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      product['image'],
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(product['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Giá: \$${product['price']}'),
                        Text('Giá cũ: \$${product['old_price']}', style: TextStyle(decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Cập nhật sản phẩm
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await dbHelper.deleteProduct(product['id']);
                            setState(() {});
                          },
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
