import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Quản lý',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          _createDrawerItem(
            icon: Icons.celebration,
            text: 'Quản lý loại sản phẩm',
            onTap: () {
              Navigator.pop(context); // Đóng Drawer trước khi điều hướng
              Navigator.pushReplacementNamed(context, '/admin_category');
            },
          ),
          _createDrawerItem(
            icon: Icons.production_quantity_limits,
            text: 'Quản lý sản phẩm',
            onTap: () {
              Navigator.pop(context); // Đóng Drawer trước khi điều hướng
              Navigator.pushReplacementNamed(context, '/admin_product');
            },
          ),
          _createDrawerItem(
            icon: Icons.people,
            text: 'Quản lý người dùng',
            onTap: () {
              Navigator.pop(context); // Đóng Drawer trước khi điều hướng
              Navigator.pushReplacementNamed(context, '/admin_user_management');
            },
          ),
          _createDrawerItem(
            icon: Icons.local_offer,
            text: 'Quản lý khuyến mãi',
            onTap: () {
              Navigator.pop(context); // Đóng Drawer trước khi điều hướng
              Navigator.pushReplacementNamed(context, '/admin_promotion_management');
            },
          ),
          _createDrawerItem(
            icon: Icons.receipt,
            text: 'Quản lý đơn hàng',
            onTap: () {
              Navigator.pop(context); // Đóng Drawer trước khi điều hướng
              Navigator.pushReplacementNamed(context, '/admin_order_management');
            },
          ),
          _createDrawerItem(
            icon: Icons.logout_outlined,
            text: 'Đăng Xuất',
            onTap: () {
              // Thực hiện đăng xuất
              //...
              Navigator.pop(context); // Đóng Drawer trước khi điều hướng
              Navigator.pushReplacementNamed(context, '/login'); // Chuyển trang đăng nhập
            },
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem({required IconData icon, required String text, required GestureTapCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon),
        title: Text(text),
      ),
    );
  }
}
