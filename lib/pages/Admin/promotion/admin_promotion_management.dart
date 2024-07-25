import 'package:flutter/material.dart';

import '../widget/admin_bottom_navigation.dart';
import '../widget/custom_drawer.dart';

class AdminPromotionManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý khuyến mãi'),
      ),
      body: Center(
        child: Text('Đây là trang quản lý khuyến mãi'),
      ),
      
      drawer: CustomDrawer(),
    );
  }
}
