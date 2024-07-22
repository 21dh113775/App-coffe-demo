import 'package:flutter/material.dart';
import '../data/databasehelper.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final dbHelper = DatabaseHelper();

  Future<void> _login() async {
    try {
      int phone = int.parse(_phoneController.text);
      String password = _passwordController.text;

      var user = await dbHelper.getUser(phone, password);
      if (user != null) {
        if (user['isAdmin'] == 1) {
          // Hiển thị thông báo đăng nhập thành công và chuyển hướng đến màn hình admin
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đăng nhập thành công')),
          );
          Navigator.pushReplacementNamed(context, '/admin_screen');
        } else {
          // Hiển thị thông báo đăng nhập thành công và chuyển hướng đến màn hình home
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đăng nhập thành công')),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Số điện thoại hoặc mật khẩu không đúng')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng nhập'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Số điện thoại'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Đăng nhập'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Đăng ký'),
            ),
          ],
        ),
      ),
    );
  }
}