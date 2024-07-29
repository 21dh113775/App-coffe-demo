import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<String> _searchHistory = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

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
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    print("Search Query: $_searchQuery"); // Logging
    List<Map<String, dynamic>> results;
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      results = await dbHelper.getProductsByCategory(selectedCategory!,
          searchQuery: _searchQuery);
    } else {
      results = await dbHelper.getProducts(searchQuery: _searchQuery);
    }
    print("Fetch Results: ${results.length}"); // Logging
    return results;
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

  void _saveSearchQuery(String query) {
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 5) {
          _searchHistory.removeLast();
        }
      });
      _saveSearchHistory();
    }
  }

  void _showSearchHistory() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)!.insert(_overlayEntry!);
  }

  void _hideSearchHistory() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 16,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, 60),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: _searchHistory.map((query) {
                return ListTile(
                  title: Text(query),
                  onTap: () {
                    _searchController.text = query;
                    setState(() {
                      _searchQuery = query;
                    });
                    _performSearch();
                    _hideSearchHistory();
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _performSearch() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {}); // This will trigger a rebuild and call _fetchProducts()
    });
    _saveSearchQuery(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CompositedTransformTarget(
                        link: _layerLink,
                        child: TextField(
                          controller: _searchController,
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
                            _performSearch();
                          },
                          onTap: _showSearchHistory,
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
      body: GestureDetector(
        onTap: _hideSearchHistory,
        child: Column(
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Lỗi: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('Không có sản phẩm nào'));
                        } else {
                          final products = snapshot.data!;
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            padding: const EdgeInsets.all(8.0),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              return _buildProductItem(
                                  context, products[index]);
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
          return Center(child: Text('Lỗi: ${snapshot.error}'));
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

  Widget _buildProductItem(BuildContext context, Map<String, dynamic> product) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product),
            ),
          );
        },
        child: ProductItemCard(
          product: product, 
          constraints: constraints, 
          formatCurrency: _formatCurrency,
          dbHelper: dbHelper,
          onAddToCart: _updateCartItemCount
        ),
      );
    });
  }
}

class ProductItemCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final BoxConstraints constraints;
  final String Function(double) formatCurrency;
  final DatabaseHelper dbHelper;
  final VoidCallback onAddToCart;

  const ProductItemCard({
    required this.product,
    required this.constraints,
    required this.formatCurrency,
    required this.dbHelper,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
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
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
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
                              '${formatCurrency(product['price'] ?? 0.0)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            if (product['old_price'] != null)
                              Text(
                                '${formatCurrency(product['old_price'] ?? 0.0)}',
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
                          onAddToCart();
                        },
                        child: Icon(Icons.add_circle,
                            color: Colors.green, size: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}