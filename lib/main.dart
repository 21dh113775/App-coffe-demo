import 'package:flutter/material.dart';
import './data/databasehelper.dart';
import './pages/home.dart';
import './pages/login.dart';
import './pages/signup.dart';
import './pages/Admin/admin_homescreen.dart';
import 'pages/Admin/Product/admin_product.dart';
import 'pages/Admin/product_page.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/admin_screen': (context) => AdminHomeScreen(),
        '/products': (context) => ProductPage(),
        '/admin_product': (context) => AdminProductPage(),
      },
    );
  }
}