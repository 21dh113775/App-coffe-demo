import 'package:flutter/material.dart';

class CashOnDeliveryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thanh toán khi nhận hàng')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Trang thanh toán khi nhận hàng'),
            // TODO: Thêm các widget cần thiết cho thanh toán khi nhận hàng
          ],
        ),
      ),
    );
  }
}