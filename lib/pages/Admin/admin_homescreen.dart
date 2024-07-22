import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              // Đăng xuất khi người dùng nhấn nút exit_to_app
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chào mừng bạn đến với trang chủ admin!',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Chuyển hướng sang trang AdminProductPage
                Navigator.pushNamed(context, '/admin_product');
              },
              child: Text('Quản lý sản phẩm'),
            ),
          ],
        ),
      ),
    );
  }
}