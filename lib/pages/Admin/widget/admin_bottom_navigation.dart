import 'package:flutter/material.dart';
 

class AdminBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  AdminBottomNavigation({required this.currentIndex, required this.onItemTapped});

  @override
  _AdminBottomNavigationState createState() => _AdminBottomNavigationState();
}

class _AdminBottomNavigationState extends State<AdminBottomNavigation> {
  void _onItemTapped(int index) {
    widget.onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.production_quantity_limits),
          label: 'Quản lý sản phẩm',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Quản lý người dùng',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.warehouse),
          label: 'Quản lý kho',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_offer),
          label: 'Quản lý khuyến mãi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: 'Quản lý đơn hàng',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Quản lý thu chi',
        ),
      ],
      currentIndex: widget.currentIndex,
      selectedItemColor: Colors.amber[800],
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
    );
  }
}
