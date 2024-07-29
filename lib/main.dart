import 'package:flutter/material.dart';
import 'package:test_login_sqlite/pages/Admin/Users/update_user.dart';
import 'data/databasehelper.dart';
import 'main_screen.dart';
import 'pages/Admin/Categories/categories_page.dart';
import 'pages/Admin/Financial/admin_financial_management.dart';
import 'pages/Admin/Inventory/admin_inventory_management.dart';
import 'pages/Admin/Order/admin_order_management.dart';
import 'pages/Admin/Users/admin_user_management.dart';
import 'pages/Admin/promotion/admin_promotion_management.dart';
import 'pages/Login/personal_info_page.dart';
import 'pages/Users/home.dart';
import 'pages/Login/login.dart';
import 'pages/Login/signup.dart';
import 'pages/Admin/admin_homescreen.dart';
import 'pages/Admin/Product/admin_add_product.dart';
import 'pages/Admin/Product/admin_product.dart';
import 'pages/Users/Product/product_pages.dart';
import 'pages/Users/Cart/cart_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper();

  // Khởi tạo lại cơ sở dữ liệu nếu cần
  await dbHelper.database;

  // In ra thông báo để biết cơ sở dữ liệu đã được tạo lại
  print(
      "Cơ sở dữ liệu đã được tạo lại với version 1."); // Initialize the database
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/personal_info': (context) => PersonalInfoPage(
            phone: ModalRoute.of(context)!.settings.arguments as int? ?? 0),
        '/register': (context) => RegisterPage(),
        '/admin_screen': (context) => AdminHomeScreen(),
        '/products': (context) => ProductPage(),
        '/admin_product': (context) => AdminProductPage(),
        '/addProduct': (context) => AddProductPage(),
        '/admin_user_management': (context) => AdminUserManagementPage(),
        '/admin_inventory_management': (context) =>
            AdminInventoryManagementPage(),
        '/admin_promotion_management': (context) =>
            ManagePromotionsPage(),
        '/admin_order_management': (context) => AdminOrderManagementPage(),
        '/home': (context) => HomePage(),
        '/cart': (context) => CartPage(
              cartItems: DatabaseHelper().getCartItems(),
            ),
        '/main_screen': (context) => MainScreen(
            phone: ModalRoute.of(context)!.settings.arguments as int? ?? 0),
        '/admin_category': (context) => CategoriesPage(),
        '/admin_finance':(context) => AdminFinanPage(),
         '/update_user': (context) => UpdateUserPage(user: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>),
      },
    );
  }
}
