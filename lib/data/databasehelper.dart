import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }


  /*Future<void> _deleteOldDatabaseIfExist() async {
    String path = join(await getDatabasesPath(), 'app.db');
    if (await File(path).exists()) {
      await deleteDatabase(path); // Xóa cơ sở dữ liệu
    }
  }*/

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app.db');

    return await openDatabase(
      path,
      version: 1, // Đặt lại version thành 1
      onCreate: _onCreate,
    );
  }
  // Tạo mới cơ sở dữ liệu
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone INTEGER UNIQUE NOT NULL,
        password TEXT NOT NULL,
        isAdmin INTEGER DEFAULT 0,
        email TEXT,
        address TEXT,
        dateOfBirth TEXT,
        gender TEXT,
        imageUrl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        price REAL,
        old_price REAL,
        image TEXT,
        categoryId INTEGER,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE cart(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER,
        quantity INTEGER,
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');

    // Chèn người dùng mặc định
    await db.insert('users', {
      'name': 'Admin',
      'phone': 123456789,
      'password': 'admin',
      'isAdmin': 1
    });
  }

  // Nâng cấp cơ sở dữ liệu khi phiên bản thay đổi
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE products ADD COLUMN categoryId INTEGER;');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE cart(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId INTEGER,
          quantity INTEGER,
          FOREIGN KEY (productId) REFERENCES products (id)
        )
      ''');
    }
    if (oldVersion < 4) {
      // Thêm các cột mới vào bảng users
      await db.execute('ALTER TABLE users ADD COLUMN email TEXT;');
      await db.execute('ALTER TABLE users ADD COLUMN address TEXT;');
      await db.execute('ALTER TABLE users ADD COLUMN dateOfBirth TEXT;');
      await db.execute('ALTER TABLE users ADD COLUMN gender TEXT;');
      await db.execute('ALTER TABLE users ADD COLUMN imageUrl TEXT;');
    }
  }

  // Phương thức chung để chèn dữ liệu
  Future<int> _insert(String table, Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(table, row);
  }

  // Phương thức chung để cập nhật dữ liệu
Future<int> _update(String table, Map<String, dynamic> row, String where, List<dynamic> whereArgs) async {
  Database db = await database;
  print('Updating $table with values: $row where $whereArgs');
  int result = await db.update(table, row, where: where, whereArgs: whereArgs);
  print('Update result: $result');
  return result;
}

  // Phương thức chung để truy vấn dữ liệu
  Future<List<Map<String, dynamic>>> _query(String table, {String? where, List<dynamic>? whereArgs}) async {
    Database db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  // Phương thức chung để xóa dữ liệu
  Future<int> _delete(String table, String where, List<dynamic> whereArgs) async {
    Database db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // Quản lý người dùng
  Future<int> insertUser(Map<String, dynamic> row) => _insert('users', row);
  Future<int> updateUser(Map<String, dynamic> user) => _update('users', user, 'phone = ?', [user['phone']]);
  Future<Map<String, dynamic>?> getUser(int phone, String password) async {
    List<Map<String, dynamic>> result = await _query('users', where: 'phone = ? AND password = ?', whereArgs: [phone, password]);
    return result.isNotEmpty ? result.first : null;
  }
  Future<Map<String, dynamic>?> getUserByPhone(int phone) async {
    List<Map<String, dynamic>> result = await _query('users', where: 'phone = ?', whereArgs: [phone]);
    return result.isNotEmpty ? result.first : null;
  }
  Future<List<Map<String, dynamic>>> getUsers() => _query('users');
  Future<int> deleteUser(int id) => _delete('users', 'id = ?', [id]);

  // Quản lý danh mục
  Future<int> insertCategory(Map<String, dynamic> row) => _insert('categories', row);
  Future<List<Map<String, dynamic>>> getCategories() => _query('categories');
  Future<int> updateCategory(Map<String, dynamic> category) => _update('categories', category, 'id = ?', [category['id']]);
  Future<int> deleteCategory(int id) => _delete('categories', 'id = ?', [id]);
  Future<int?> getCategoryIdByName(String name) async {
    List<Map<String, dynamic>> result = await _query('categories', where: 'name = ?', whereArgs: [name]);
    return result.isNotEmpty ? result.first['id'] as int? : null;
  }

  // Quản lý sản phẩm
  Future<int> insertProduct(Map<String, dynamic> row) => _insert('products', row);
  Future<int> updateProduct(Map<String, dynamic> product) => _update('products', product, 'id = ?', [product['id']]);
  Future<int> deleteProduct(int id) => _delete('products', 'id = ?', [id]);
  Future<List<Map<String, dynamic>>> getProducts({String searchQuery = ''}) => _query('products', where: 'name LIKE ?', whereArgs: ['%$searchQuery%']);
  Future<List<Map<String, dynamic>>> getProductsByCategory(String categoryName, {String searchQuery = ''}) async {
    final categoryId = await getCategoryIdByName(categoryName);
    if (categoryId != null) {
      return _query('products', where: 'categoryId = ? AND name LIKE ?', whereArgs: [categoryId, '%$searchQuery%']);
    } else {
      return [];
    }
  }

  // Quản lý giỏ hàng
  Future<int> addToCart(int productId) async {
    final result = await _query('cart', where: 'productId = ?', whereArgs: [productId]);
    if (result.isNotEmpty) {
      final cartItem = result.first;
      final newQuantity = (cartItem['quantity'] as int) + 1;
      return await _update('cart', {'quantity': newQuantity}, 'productId = ?', [productId]);
    } else {
      return await _insert('cart', {'productId': productId, 'quantity': 1});
    }
  }

  Future<int> updateCartQuantity(int productId, int quantity) async {
    if (quantity > 0) {
      return await _update('cart', {'quantity': quantity}, 'productId = ?', [productId]);
    } else {
      return await _delete('cart', 'productId = ?', [productId]);
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT p.*, c.quantity FROM cart c
      JOIN products p ON c.productId = p.id
    ''');
  }

  Future<int> removeFromCart(int productId) => _delete('cart', 'productId = ?', [productId]);
  Future<int> clearCart() async {
    Database db = await database;
    return await db.delete('cart');
  }

  Future<int> getCartItemCount() async {
    Database db = await database;
    final result = await db.rawQuery('SELECT SUM(quantity) AS count FROM cart');
    return Sqflite.firstIntValue(result) ?? 0;
  }

 Future<void> dropAndRecreateTables() async {
  final db = await database;

  // Danh sách các bảng cần xóa
  final tables = ['users', 'categories', 'products', 'cart'];

  for (var table in tables) {
    await db.rawDelete('DROP TABLE IF EXISTS $table'); // Xóa bảng
  }

  // Tạo lại các bảng
  await _onCreate(db, 4); // Tạo lại các bảng với version 4
}

}
