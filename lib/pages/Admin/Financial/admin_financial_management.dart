import 'package:flutter/material.dart';
import '../widget/custom_drawer.dart';
class AdminFinanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý thu chi'),
      ),
      body: Center(
        child: Text('Đây là trang quản lý thu chi'),
      ),
      drawer: CustomDrawer(), // Assuming AdminDrawer is a separate widget
    );
  }
}
