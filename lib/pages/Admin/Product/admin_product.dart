import 'package:flutter/material.dart';
import '/data/databasehelper.dart';

class AdminProductPage extends StatefulWidget {
  @override
  _AdminProductPageState createState() => _AdminProductPageState();
}

class _AdminProductPageState extends State<AdminProductPage> {
  final dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _oldPriceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();

  Future<void> _insertProduct() async {
    if (_formKey.currentState!.validate()) {
      await dbHelper.insertProduct({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'old_price': double.parse(_oldPriceController.text),
        'description': _descriptionController.text,
        'image': _imageController.text,
      });
      setState(() {});
      _clearForm();
    }
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _oldPriceController.clear();
    _descriptionController.clear();
    _imageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Quản lý sản phẩm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Tên sản phẩm'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên sản phẩm';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: 'Giá'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập giá';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _oldPriceController,
                    decoration: InputDecoration(labelText: 'Giá cũ'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _imageController,
                    decoration: InputDecoration(labelText: 'URL hình ảnh'),
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Mô tả'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _insertProduct,
                    child: Text('Thêm sản phẩm'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: dbHelper.getProducts(),
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
            ),
          ],
        ),
      ),
    );
  }
}