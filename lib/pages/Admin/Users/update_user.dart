import 'package:flutter/material.dart';
import '../../../data/databasehelper.dart'; // Import DatabaseHelper

class UpdateUserPage extends StatefulWidget {
  final Map<String, dynamic> user;

  UpdateUserPage({required this.user});

  @override
  _UpdateUserPageState createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage>
    with SingleTickerProviderStateMixin {
  final dbHelper = DatabaseHelper();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _imageUrlController;
  String _selectedGender = 'Male';
  bool _isAdmin = false;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['name']);
    _phoneController = TextEditingController(text: widget.user['phone'].toString());
    _passwordController = TextEditingController(text: widget.user['password']);
    _emailController = TextEditingController(text: widget.user['email']);
    _addressController = TextEditingController(text: widget.user['address']);
    _dateOfBirthController = TextEditingController(text: widget.user['dateOfBirth']);
    _imageUrlController = TextEditingController(text: widget.user['imageUrl']);
    _selectedGender = genderOptions.contains(widget.user['gender']) ? widget.user['gender'] : 'Male';
    _isAdmin = widget.user['isAdmin'] == 1;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    _imageUrlController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    final updatedUser = {
      'id': widget.user['id'],
      'name': _nameController.text,
      'phone': int.tryParse(_phoneController.text),
      'password': _passwordController.text,
      'isAdmin': _isAdmin ? 1 : 0,
      'email': _emailController.text,
      'address': _addressController.text,
      'dateOfBirth': _dateOfBirthController.text,
      'gender': _selectedGender,
      'imageUrl': _imageUrlController.text,
    };

    await dbHelper.updateUser(updatedUser);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa thông tin người dùng'),
      ),
      body: FadeTransition(
        opacity: _opacityAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              if (_imageUrlController.text.isNotEmpty)
                Center(
                  child: AnimatedBuilder(
                    animation: _imageUrlController,
                    builder: (context, child) {
                      return Image.network(
                        _imageUrlController.text,
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error);
                        },
                      );
                    },
                  ),
                ),
              SizedBox(height: 16),
              _buildTextField(_nameController, 'Tên', TextInputType.text),
              _buildTextField(_phoneController, 'Số điện thoại', TextInputType.phone),
              _buildTextField(_passwordController, 'Mật khẩu', TextInputType.text, obscureText: true),
              _buildTextField(_emailController, 'Email', TextInputType.emailAddress),
              _buildTextField(_addressController, 'Địa chỉ', TextInputType.text),
              _buildTextField(_dateOfBirthController, 'Ngày sinh', TextInputType.datetime),
              _buildTextField(_imageUrlController, 'URL hình ảnh', TextInputType.url, onChanged: (value) {
                setState(() {});
              }),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(labelText: 'Giới tính'),
                items: genderOptions.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value ?? 'Male';
                  });
                },
              ),
              SwitchListTile(
                title: Text('Admin'),
                value: _isAdmin,
                onChanged: (value) {
                  setState(() {
                    _isAdmin = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text('Cập nhật'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, TextInputType keyboardType, {bool obscureText = false, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
      ),
    );
  }
}
