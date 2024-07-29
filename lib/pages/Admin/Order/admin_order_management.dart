import 'package:flutter/material.dart';
import '../widget/custom_drawer.dart';

class AdminOrderManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý đơn hàng'),
      ),
      body: Center(
        child: Text('Đây là trang quản lý đơn hàng'),
      ),
      
      drawer: CustomDrawer(),
    );
  }
}
