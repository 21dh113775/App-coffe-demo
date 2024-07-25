import 'package:flutter/material.dart';
import 'package:test_login_sqlite/data/databasehelper.dart';

class AddCategoryPage extends StatefulWidget {
  final Map<String, dynamic>? category;

  AddCategoryPage({this.category});

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int? _selectedCategoryId;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!['name'];
      _descriptionController.text = widget.category!['description'];
      _selectedCategoryId = widget.category!['id'];
    }

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _addOrUpdateCategory() async {
    String name = _nameController.text;
    String description = _descriptionController.text;

    if (_selectedCategoryId == null) {
      await _dbHelper.insertCategory({
        'name': name,
        'description': description,
      });
    } else {
      await _dbHelper.updateCategory({
        'id': _selectedCategoryId,
        'name': name,
        'description': description,
      });
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedCategoryId == null
            ? 'Thêm danh mục'
            : 'Cập nhật danh mục'),
        backgroundColor: Colors.green,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Flexible(
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Tên danh mục',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        SizedBox(height: 16),
                        Flexible(
                          child: TextField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Mô tả',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        SizedBox(height: 16),
                        AspectRatio(
                          aspectRatio: 7 / 1,
                          child: ElevatedButton(
                            onPressed: _addOrUpdateCategory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(_selectedCategoryId == null
                                ? 'Thêm danh mục'
                                : 'Cập nhật danh mục'),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}