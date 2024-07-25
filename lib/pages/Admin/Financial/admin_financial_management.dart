import 'package:flutter/material.dart';

import '../widget/admin_bottom_navigation.dart';
import '../widget/custom_drawer.dart';

class AdminFinancialManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý thu chi'),
      ),
      body: Center(
        child: Text('Đây là trang quản lý thu chi'),
      ),
      bottomNavigationBar: AdminBottomNavigation(
        currentIndex: 5,
        onItemTapped: (index) {
          // Handle navigation here
        },
      ),
      drawer: CustomDrawer(), // Assuming AdminDrawer is a separate widget
    );
  }
}
