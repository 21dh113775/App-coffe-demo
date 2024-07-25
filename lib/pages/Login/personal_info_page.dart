import 'package:flutter/material.dart';
import '../../data/databasehelper.dart';
import '../Users/proflie/profile_pages.dart';

class PersonalInfoPage extends StatefulWidget {
  final int phone;

  PersonalInfoPage({required this.phone});

  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _imageUrlController = TextEditingController(); // Thêm controller cho URL hình ảnh
  String _gender = 'Nam';

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

 Future<void> _submitPersonalInfo() async {
  if (_formKey.currentState!.validate()) {
    try {
      DatabaseHelper dbHelper = DatabaseHelper();
      Map<String, dynamic> userInfo = {
        'phone': widget.phone,
        'name': _nameController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'dateOfBirth': _dateOfBirthController.text,
        'gender': _gender,
        'imageUrl': _imageUrlController.text,
      };
      int updateResult = await dbHelper.updateUser(userInfo);
      print("User info updated successfully: $userInfo, update result: $updateResult");

      if (updateResult > 0) {
        // Chuyển hướng đến ProfilePages với phone
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePages(),
            settings: RouteSettings(arguments: widget.phone),
          ),
        );
      } else {
        print("Failed to update user info");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thông tin thất bại. Vui lòng thử lại.')),
        );
      }
    } catch (e) {
      print("Error updating user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thông tin thất bại. Vui lòng thử lại.')),
      );
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin cá nhân'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Thêm hình ảnh từ URL
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'URL hình ảnh đại diện',
                    prefixIcon: Icon(Icons.image),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập URL hình ảnh';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Các trường thông tin khác
                _buildTextField(_nameController, 'Họ và tên', Icons.person),
                SizedBox(height: 20),
                _buildTextField(_emailController, 'Email', Icons.email),
                SizedBox(height: 20),
                _buildTextField(_addressController, 'Địa chỉ', Icons.home),
                SizedBox(height: 20),
                // Trường ngày sinh với DatePicker
                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _dateOfBirthController,
                      decoration: InputDecoration(
                        labelText: 'Ngày sinh',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng chọn ngày sinh';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Dropdown cho giới tính
                DropdownButtonFormField<String>(
                  value: _gender,
                  onChanged: (String? newValue) {
                    setState(() {
                      _gender = newValue!;
                    });
                  },
                  items: <String>['Nam', 'Nữ', 'Khác']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Giới tính',
                    prefixIcon: Icon(Icons.people),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitPersonalInfo,
                  child: Text(
                    'Hoàn thành',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập $label';
        }
        return null;
      },
    );
  }
}
