import 'package:flutter/material.dart';
import 'package:test_login_sqlite/pages/Login/login.dart';
import '../../../data/databasehelper.dart';

class ProfilePages extends StatefulWidget {
  final int phone;
  const ProfilePages({super.key, required this.phone});

  @override
  _ProfilePagesState createState() => _ProfilePagesState();
}

class _ProfilePagesState extends State<ProfilePages> {
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // Load user information when the widget is initialized
  }

  // Method to load user information from the database
  Future<void> _loadUserInfo() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final userInfo = await dbHelper.getUserByPhone(widget.phone);
    setState(() {
      _userInfo = userInfo;
    });
  }

  // Method to handle logout action
  void _logout() {
    // Implement your logout logic here
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hồ sơ cá nhân'), // Title of the AppBar
      ),
      body: _userInfo == null
          ? Center(child: CircularProgressIndicator()) // Show a loading indicator if userInfo is null
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_userInfo!['imageUrl'] ?? ''), // Display user's profile image
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildInfoTile('Họ và tên', _userInfo!['name']),
                  _buildInfoTile('Email', _userInfo!['email']),
                  _buildInfoTile('Địa chỉ', _userInfo!['address']),
                  _buildInfoTile('Ngày sinh', _userInfo!['dateOfBirth']),
                  _buildInfoTile('Giới tính', _userInfo!['gender']),
                  _buildInfoTile('Số điện thoại', _userInfo!['phone'].toString()),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Set button color to red
                      ),
                      child: Text(
                        'Đăng xuất',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Method to create information tiles
  Widget _buildInfoTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, // Label for the information
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value ?? 'Không có thông tin', // Display value or 'Không có thông tin' if value is null
            style: TextStyle(fontSize: 14),
          ),
          Divider(), // Divider to separate each info tile
        ],
      ),
    );
  }
}
