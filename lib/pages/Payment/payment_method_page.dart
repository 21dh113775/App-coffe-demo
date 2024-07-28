import 'package:flutter/material.dart';
import 'package:test_login_sqlite/pages/Payment/bank_transfer_page.dart';
import 'package:test_login_sqlite/pages/Payment/cash_on_delivery_page.dart';
import 'package:test_login_sqlite/pages/Payment/momolink.dart';

class PaymentMethod {
  final String title;
  final IconData icon;
  final Color color;

  PaymentMethod({required this.title, required this.icon, required this.color});
}

class PaymentMethodPage extends StatefulWidget {
  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(title: 'Thanh toán khi nhận hàng', icon: Icons.local_shipping, color: Color.fromARGB(255, 223, 146, 32)),
    PaymentMethod(title: 'Thanh toán qua ngân hàng', icon: Icons.account_balance, color: Colors.blue),
    PaymentMethod(title: 'Thanh toán qua Momo', icon: Icons.account_balance_wallet, color: Color.fromARGB(255, 179, 10, 114)),
  ];
void _handleContinue(BuildContext context) {
    // Xử lý việc chuyển trang dựa trên phương thức thanh toán được chọn
    switch (selectedMethodIndex) {
      case 0:
        // Chuyển đến trang thanh toán khi nhận hàng
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CashOnDeliveryPage()),
        );
        break;
      case 1:
        // Chuyển đến trang thanh toán qua ngân hàng
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BankTransferPage()),
        );
        break;
      case 2:
        // Chuyển đến trang liên kết Momo
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MomoLinkPage()),
        );
        break;
      default:
        // Trường hợp không có phương thức nào được chọn (không nên xảy ra)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn phương thức thanh toán')),
        );
    }
  }
  int? selectedMethodIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phương thức thanh toán'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Chọn phương thức thanh toán',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: paymentMethods.length,
                separatorBuilder: (context, index) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildPaymentOption(paymentMethods[index], index);
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Tiếp tục', style: TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 38, 138, 23),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),  
              ),
              onPressed: selectedMethodIndex != null
                  ? () => _handleContinue(context)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(PaymentMethod method, int index) {
    return InkWell(
      onTap: () => setState(() => selectedMethodIndex = index),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedMethodIndex == index ? method.color : Colors.grey[300]!,
            width: selectedMethodIndex == index ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(method.icon, color: method.color),
            SizedBox(width: 16),
            Expanded(
              child: Text(method.title, style: TextStyle(fontSize: 16)),
            ),
            if (selectedMethodIndex == index)
              Icon(Icons.check_circle, color: method.color),
          ],
        ),
      ),
    );
  }

   
}