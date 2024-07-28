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

  @override
  void initState() {
    super.initState();
    _updateCartItemCount();
  }

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      return await dbHelper.getProductsByCategory(selectedCategory!,
          searchQuery: _searchQuery);
    } else {
      return await dbHelper.getProducts(searchQuery: _searchQuery);
    }
  }

  void _navigateToProductDetail(
      BuildContext context, Map<String, dynamic> product) {
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
        builder: (context) => CartPage(
          cartItems: DatabaseHelper().getCartItems(),
        ),
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
        backgroundColor: Colors.green,
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
                      hintText: 'Bạn muốn tìm gì?',
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
                // SizedBox(width: 8),
                // Stack(
                //   children: [
                //     IconButton(
                //       icon: Icon(Icons.shopping_cart, color: Colors.black),
                //       onPressed: () => _navigateToCart(context),
                //     ),
                //     if (_cartItemCount > 0)
                //       Positioned(
                //         right: 0,
                //         child: CircleAvatar(
                //           radius: 10,
                //           backgroundColor: Colors.red,
                //           child: Text(
                //             '$_cartItemCount',
                //             style: TextStyle(fontSize: 12, color: Colors.white),
                //           ),
                //         ),
                //       ),
                //   ],
                // ),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                          _getIconForCategory(category['name']),
                          color: selectedCategory == category['name']
                              ? Colors.green
                              : Colors.grey,
                          size: 30,
                        ),
                        SizedBox(height: 2),
                        Text(
                          category['name'],
                          style: TextStyle(
                            fontSize: 10,
                            color: selectedCategory == category['name']
                                ? Colors.green
                                : Colors.black,
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

  IconData _getIconForCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'trà sữa':
        return Icons.local_cafe;
      case 'coffee':
        return Icons.coffee;
      case 'trà trái cây':
        return Icons.emoji_food_beverage;
      case 'best seller':
        return Icons.star;
      case 'topping':
        return Icons.add_circle_outline;
      default:
        return Icons.category;
    }
  }

  Widget _buildProductItem(BuildContext context, Map<String, dynamic> product) {
    return Container(
      child: GestureDetector(
        onTap: () => _navigateToProductDetail(context, product),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    product['image'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Center(child: Icon(Icons.error)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] ?? '',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_formatCurrency(product['price'] ?? 0.0)}',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.green, size: 28),
                  onPressed: () async {
                    await dbHelper.addToCart(product['id']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                    );
                    _updateCartItemCount();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
