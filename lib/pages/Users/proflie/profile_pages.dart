import 'package:flutter/material.dart';
import 'package:test_login_sqlite/pages/Login/login.dart';
import '../../../data/databasehelper.dart';
 // Import your login page here

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
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final userInfo = await dbHelper.getUserByPhone(widget.phone);
    setState(() {
      _userInfo = userInfo;
    });
  }

  void _logout() {
    // Add your logout logic here
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to login page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hồ sơ cá nhân'),
      ),
      body: _userInfo == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_userInfo!['imageUrl'] ?? ''),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildInfoTile('Họ và tên', _userInfo!['name']),
                  _buildInfoTile('Email', _userInfo!['email']),
                  _buildInfoTile('Địa chỉ', _userInfo!['address']),
                  _buildInfoTile('Ngày sinh', _userInfo!['dateOfBirth']),
                  _buildInfoTile('Giới tính', _userInfo!['gender']),
                  _buildInfoTile('Số điện thoại', _userInfo!['phone'].toString()),
                  SizedBox(height: 40),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: Icon(Icons.logout),
                      label: Text('Đăng xuất'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value ?? 'Không có thông tin',
            style: TextStyle(fontSize: 14),
          ),
          Divider(),
        ],
      ),
    );
  }
}