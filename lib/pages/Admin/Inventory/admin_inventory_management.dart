import 'package:flutter/material.dart';

import '../widget/admin_bottom_navigation.dart';
import '../widget/custom_drawer.dart';

class AdminInventoryManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý kho'),
      ),
      body: Center(
        child: Text('Đây là trang quản lý kho'),
      ),
      bottomNavigationBar: AdminBottomNavigation(
        currentIndex: 2,
        onItemTapped: (index) {
          // Handle navigation here
        },
      ),
      drawer: CustomDrawer(),
    );
  }
}
