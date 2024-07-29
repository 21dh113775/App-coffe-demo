import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  int? _selectedCategoryId;
  late Future<List<Map<String, dynamic>>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = dbHelper.getCategories();
  }

  Future<void> _insertProduct() async {
    if (_formKey.currentState!.validate()) {
      await dbHelper.insertProduct({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'old_price': double.parse(_oldPriceController.text),
        'description': _descriptionController.text,
        'image': _imageController.text,
        'categoryId': _selectedCategoryId,
      });
      Navigator.pop(context, true);
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return FutureBuilder<List<Map<String, dynamic>>>(
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
            decoration: InputDecoration(
              labelText: 'Chọn danh mục',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
              prefixIcon: Icon(Icons.category),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null) {
                return 'Vui lòng chọn danh mục';
              }
              return null;
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm sản phẩm', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal, Colors.teal.shade50],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: CachedNetworkImage(
                              imageUrl: 'https://via.placeholder.com/150',
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 150,
                                width: 150,
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 150,
                                width: 150,
                                color: Colors.grey[300],
                                child: Icon(Icons.error, size: 50, color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        _buildTextField(_nameController, 'Tên sản phẩm', Icons.label),
                        SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(_priceController, 'Giá', Icons.attach_money, isNumber: true)),
                            SizedBox(width: 16.0),
                            Expanded(child: _buildTextField(_oldPriceController, 'Giá cũ', Icons.money_off, isNumber: true)),
                          ],
                        ),
                        SizedBox(height: 16.0),
                        _buildCategoryDropdown(),
                        SizedBox(height: 16.0),
                        _buildTextField(_descriptionController, 'Mô tả', Icons.description, maxLines: 3),
                        SizedBox(height: 16.0),
                        _buildTextField(_imageController, 'URL hình ảnh', Icons.image),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton.icon(
                  onPressed: _insertProduct,
                  icon: Icon(Icons.add),
                  label: Text('Thêm sản phẩm'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _oldPriceController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }
}
