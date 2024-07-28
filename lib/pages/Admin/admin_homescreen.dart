import 'package:flutter/material.dart';
import 'widget/custom_drawer.dart'; // Import your CustomDrawer widget

class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Trang Chủ Admin'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              // Đăng xuất khi người dùng nhấn nút exit_to_app
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Chào mừng bạn đến với trang chủ admin!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: screenWidth * 0.8,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2), // Color of your choice
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage('assets/logoAdmin.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      
                        
                        child: Text(
                          'Quản lý hệ thống',
                            style: TextStyle(
                              fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Implement navigation to other admin sections here
                  },
                  child: Text('Xem thêm'),
                ),
              ],
            ),
          );
        },
      ),
      
      drawer: CustomDrawer(),
    );
  }
}
