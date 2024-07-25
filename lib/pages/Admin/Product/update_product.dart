import 'package:flutter/material.dart';
import '../../../data/databasehelper.dart';

class UpdateProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  UpdateProductPage({required this.product});

  @override
  _UpdateProductPageState createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  final dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _oldPriceController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  int? _selectedCategoryId;
  late Future<List<Map<String, dynamic>>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _priceController = TextEditingController(text: widget.product['price'].toString());
    _oldPriceController = TextEditingController(text: widget.product['old_price'].toString());
    _descriptionController = TextEditingController(text: widget.product['description']);
    _imageController = TextEditingController(text: widget.product['image']);
    _selectedCategoryId = widget.product['categoryId'];
    _categoriesFuture = dbHelper.getCategories();
  }

  void _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      await dbHelper.updateProduct({
        'id': widget.product['id'],
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0,
        'old_price': double.tryParse(_oldPriceController.text) ?? 0,
        'description': _descriptionController.text,
        'image': _imageController.text,
        'categoryId': _selectedCategoryId,
      });
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cập nhật sản phẩm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
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
                    return DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      items: categories.map((category) {
                        return DropdownMenuItem<int>(
                          value: category['id'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      hint: Text('Chọn danh mục'),
                      validator: (value) {
                        if (value == null) {
                          return 'Vui lòng chọn danh mục';
                        }
                        return null;
                      },
                    );
                  }
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Mô tả'),
              ),
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(labelText: 'URL hình ảnh'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProduct,
                child: Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
