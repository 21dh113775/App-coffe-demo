import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart'; // Import thư viện intl
import '../../../data/databasehelper.dart';
import '../widget/custom_drawer.dart';
import 'admin_add_product.dart';
import 'update_product.dart'; // Import trang cập nhật

class AdminProductPage extends StatefulWidget {
  @override
  _AdminProductPageState createState() => _AdminProductPageState();
}

class _AdminProductPageState extends State<AdminProductPage> {
  final dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _productsFuture;
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
    _categoriesFuture = dbHelper.getCategories();
  }

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    return await dbHelper.getProducts();
  }

  void _navigateToAddProductPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductPage()),
    );
    if (result == true) {
      setState(() {
        _productsFuture = _fetchProducts(); // Refresh the product list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.simpleCurrency(locale: 'vi_VN', name: 'VND');

    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý sản phẩm'),
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('Chưa có danh mục nào');
                  } else {
                    final categories = snapshot.data!;
                    return Container(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: categories.map((category) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ChoiceChip(
                                label: Text(category['name']),
                                selected: _selectedCategoryId == category['id'],
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategoryId = selected ? category['id'] : null;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }
                },
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('Chưa có sản phẩm nào'));
                    } else {
                      final products = snapshot.data!;
                      final filteredProducts = _selectedCategoryId == null
                          ? products
                          : products.where((product) => product['categoryId'] == _selectedCategoryId).toList();

                      return ListView.builder(
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return Card(
                            child: ListTile(
                              leading: CachedNetworkImage(
                                imageUrl: product['image'],
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                              title: Text(product['name']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Giá: ${currencyFormatter.format(product['price'])}'),
                                  Text(
                                    'Giá cũ: ${currencyFormatter.format(product['old_price'])}',
                                    style: TextStyle(decoration: TextDecoration.lineThrough),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UpdateProductPage(product: product),
                                        ),
                                      );
                                      if (result == true) {
                                        setState(() {
                                          _productsFuture = _fetchProducts(); // Refresh the product list
                                        });
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      await dbHelper.deleteProduct(product['id']);
                                      setState(() {
                                        _productsFuture = _fetchProducts(); // Refresh the product list
                                      });
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
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _navigateToAddProductPage,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(),
    );
  }
}
