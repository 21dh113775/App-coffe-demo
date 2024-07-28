import 'package:flutter/material.dart';

class BankTransferPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thanh toán qua ngân hàng')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Trang thanh toán qua ngân hàng'),
            // TODO: Thêm các widget cần thiết cho thanh toán qua ngân hàng
          ],
        ),
      ),
    );
  }
}