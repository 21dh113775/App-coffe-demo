import 'package:flutter/material.dart';
import 'package:test_login_sqlite/pages/Users/voucher.dart';
import '../pages/Users/home.dart';
import 'pages/Users/Cart/cart_page.dart';
import 'pages/Users/Product/product_pages.dart';
import 'pages/Users/proflie/profile_pages.dart';
import 'pages/bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  final int phone;
  const MainScreen({super.key, required this.phone});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomePage(),
      ProductPage(),
      CartPage(),
      VoucherPage(),
      ProfilePages(
        phone: widget.phone,
      ),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onItemTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
