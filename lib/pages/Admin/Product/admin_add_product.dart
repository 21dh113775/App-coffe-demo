import 'package:flutter/material.dart';
import '../../../data/databasehelper.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
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
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm sản phẩm'),
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
      ),
    );
  }
}
