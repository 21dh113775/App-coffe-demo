import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_login_sqlite/data/databasehelper.dart';
import 'package:test_login_sqlite/pages/Users/Cart/cart_page.dart';
import 'package:test_login_sqlite/pages/Users/Product/product_detail_pages.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final dbHelper = DatabaseHelper();
  String? selectedCategory;
  String _searchQuery = '';
  int _cartItemCount = 0;
  

  final List<IconData> categoryIcons = [
    Icons.local_cafe,
    Icons.coffee,
    Icons.emoji_food_beverage,
    Icons.star,
    Icons.add_circle_outline,
    Icons.local_drink,
    Icons.fastfood,
    Icons.icecream,
    Icons.local_pizza,
    Icons.cake
  ];

  @override
  void initState() {
    super.initState();
    _updateCartItemCount();
  }

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      return await dbHelper.getProductsByCategory(selectedCategory!, searchQuery: _searchQuery);
    } else {
      return await dbHelper.getProducts(searchQuery: _searchQuery);
    }
  }

  void _navigateToProductDetail(BuildContext context, Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }

  void _navigateToCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(),
      ),
    ).then((_) => _updateCartItemCount());
  }

  String _formatCurrency(double amount) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatCurrency.format(amount);
  }

  Future<void> _updateCartItemCount() async {
    final count = await dbHelper.getCartItemCount();
    setState(() {
      _cartItemCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // Đổi màu nền AppBar thành màu trắng
        title: Center(
          child: Image.asset(
            'assets/logo2.png',
            height: 40,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Shaker muốn tìm gì?',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _fetchProducts();
                    },
                  ),
                ),
                SizedBox(width: 8),
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart, color: Colors.black),
                      onPressed: () => _navigateToCart(context),
                    ),
                    if (_cartItemCount > 0)
                      Positioned(
                        right: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Text(
                            '$_cartItemCount',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedCategory != null && selectedCategory!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                selectedCategory!,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.yellow[700]), // Đổi màu chữ danh mục thành màu vàng
              ),
            ),
          Expanded(
            child: Row(
              children: [
                _buildCategoryIcons(),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Không có sản phẩm nào'));
                      } else {
                        final products = snapshot.data!;
                        return GridView.builder(
                          padding: EdgeInsets.all(10),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return _buildProductItem(context, products[index]);
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcons() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: dbHelper.getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Không có danh mục nào'));
        } else {
          final categories = snapshot.data!;
          return Container(
            width: 80,
            color: Colors.white,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedCategory = category['name'];
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Icon(
                          categoryIcons[index % categoryIcons.length],
                          color: selectedCategory == category['name'] ? Colors.green : Colors.grey,
                          size: 30,
                        ),
                        SizedBox(height: 2),
                        Text(
                          category['name'],
                          style: TextStyle(
                            fontSize: 10,
                            color: selectedCategory == category['name'] ? Colors.green : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

 Widget _buildProductItem(BuildContext context, Map<String, dynamic> product) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product),
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Stack(
                  children: [
                    Image.network(
                      product['image'] ?? '',
                      height: constraints.maxHeight * 0.6,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product['brand'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product['name'] ?? '',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_formatCurrency(product['price'] ?? 0.0)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                if (product['old_price'] != null)
                                  Text(
                                    '${_formatCurrency(product['old_price'] ?? 0.0)}',
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await dbHelper.addToCart(product['id']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                              );
                              _updateCartItemCount();
                            },
                            child: Icon(Icons.add_circle, color: Colors.green, size: 24),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  );
} 
}
