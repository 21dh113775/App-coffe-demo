import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../data/databasehelper.dart';
import '../widget/custom_drawer.dart';
import 'admin_add_product.dart';
import 'update_product.dart';

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
        _productsFuture = _fetchProducts();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sản phẩm đã được thêm thành công')),
      );
    }
  }

  void _navigateToUpdateProductPage(Map<String, dynamic> product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateProductPage(product: product),
      ),
    );
    if (result == true) {
      setState(() {
        _productsFuture = _fetchProducts();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sản phẩm đã được cập nhật thành công')),
      );
    }
  }

  void _deleteProduct(int productId) async {
    await dbHelper.deleteProduct(productId);
    setState(() {
      _productsFuture = _fetchProducts();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sản phẩm đã được xóa thành công')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.simpleCurrency(locale: 'vi_VN', name: 'VND');

    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý sản phẩm' , style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromARGB(255, 51, 51, 51),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LinearProgressIndicator();
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
                                selectedColor: Color.fromARGB(255, 255, 186, 48),
                                backgroundColor: Colors.grey[200],
                                labelStyle: TextStyle(color: _selectedCategoryId == category['id'] ? Colors.white : Colors.black),
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
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: InkWell(
                              onTap: () => _navigateToUpdateProductPage(product),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16.0),
                                leading: CachedNetworkImage(
                                  imageUrl: product['image'],
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                                title: Text(product['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Giá: ${currencyFormatter.format(product['price'])}', style: TextStyle(color: Colors.teal)),
                                    Text(
                                      'Giá cũ: ${currencyFormatter.format(product['old_price'])}',
                                      style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.red),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteProduct(product['id']),
                                ),
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
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(),
      backgroundColor: Colors.grey[100],
    );
  }
}
