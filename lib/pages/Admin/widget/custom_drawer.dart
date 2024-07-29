import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _createDrawerHeader(),
                _createDrawerItem(
                  icon: Icons.home,
                  text: 'Trang chủ',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/admin_screen');
                  },
                ),
                _createDrawerItem(
                  icon: Icons.celebration,
                  text: 'Quản lý loại sản phẩm',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/admin_category');
                  },
                ),
                _createDrawerItem(
                  icon: Icons.production_quantity_limits,
                  text: 'Quản lý sản phẩm',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/admin_product');
                  },
                ),
                _createDrawerItem(
                  icon: Icons.people,
                  text: 'Quản lý người dùng',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/admin_user_management');
                  },
                ),
                _createDrawerItem(
                  icon: Icons.local_offer,
                  text: 'Quản lý khuyến mãi',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/admin_promotion_management');
                  },
                ),
                _createDrawerItem(
                  icon: Icons.receipt,
                  text: 'Quản lý đơn hàng',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/admin_order_management');
                  },
                ),
                _createDrawerItem(
                  icon: Icons.account_balance_wallet,
                  text: 'Thu chi',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/admin_finance');
                  },
                ),
              ],
            ),
          ),
          // Thêm mục đăng xuất ở cuối cùng
          _createDrawerItem(
            icon: Icons.logout,
            text: 'Đăng Xuất',
            onTap: () {
              // Thực hiện đăng xuất
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          SizedBox(height: 20), // Khoảng cách dưới cùng
        ],
      ),
    );
  }

  Widget _createDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 58, 58, 58),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/profile.png'), // Thay thế bằng hình ảnh thực tế
          ),
          SizedBox(height: 10),
          Text(
            'Quản lý',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Admin', // Thay thế bằng chức vụ thực tế
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem({required IconData icon, required String text, required GestureTapCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Color.fromARGB(255, 255, 187, 13)), // Chỉnh màu icon ở đây
      title: Text(text, style: TextStyle(color: Color.fromARGB(221, 23, 23, 23))), // Chỉnh màu chữ ở đây
      onTap: onTap,
    );
  }
}
