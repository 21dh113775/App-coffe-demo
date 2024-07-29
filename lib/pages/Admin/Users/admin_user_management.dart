import 'package:flutter/material.dart';
import '../widget/custom_drawer.dart';
import '../../../data/databasehelper.dart'; // Import DatabaseHelper

class AdminUserManagementPage extends StatefulWidget {
  @override
  _AdminUserManagementPageState createState() => _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> with SingleTickerProviderStateMixin {
  final dbHelper = DatabaseHelper();
  late Future<List<Map<String, dynamic>>> _usersFuture;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();

    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    return await dbHelper.getUsers();
  }

  void _showDeleteConfirmationDialog(int userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thông báo', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Bạn có chắc chắn muốn xóa tài khoản người dùng?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                await dbHelper.deleteUser(userId);
                setState(() {
                  _usersFuture = _fetchUsers();
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý người dùng'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Chưa có người dùng nào'));
                } else {
                  final users = snapshot.data!;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/update_user', // Đường dẫn đến trang chỉnh sửa
                              arguments: {
                                'id': user['id'],
                                'name': user['name'] ?? '',
                                'phone': user['phone']?.toString() ?? '',
                                'password': user['password'] ?? '',
                                'isAdmin': user['isAdmin'] ?? 0,
                                'email': user['email'] ?? '',
                                'address': user['address'] ?? '',
                                'dateOfBirth': user['dateOfBirth'] ?? '',
                                'gender': user['gender'] ?? 'Male',
                                'imageUrl': user['imageUrl'] ?? '',
                              }, // Truyền thông tin người dùng sang trang chỉnh sửa
                            );
                          },
                          child: ListTile(
                            leading: user['imageUrl'] != null && user['imageUrl'].isNotEmpty
                                ? Image.network(
                                    user['imageUrl'],
                                    width: 50,
                                    height: 50,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.error);
                                    },
                                  )
                                : CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                            title: Text('Số điện thoại: ${user['phone']}', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['name'] ?? 'Tên không có'),
                                Text(user['address'] ?? 'Địa chỉ không có'),
                                Text(user['gender'] ?? 'Giới tính không có'),
                                Text(user['isAdmin'] == 1 ? 'Admin' : 'Người dùng'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmationDialog(user['id']);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          );
        },
      ),
      drawer: CustomDrawer(),
    );
  }
}
