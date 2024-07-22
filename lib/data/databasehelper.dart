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

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app.db');

    // Xóa cơ sở dữ liệu cũ (chỉ nên dùng trong quá trình phát triển)
    await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            phone INTEGER,
            password TEXT,
            isAdmin INTEGER DEFAULT 0
          )
          '''
        );

        // Insert default admin user
        await db.insert('users', {
          'phone': 123456789,    // Số điện thoại admin mặc định
          'password': 'admin',   // Mật khẩu admin mặc định
          'isAdmin': 1           // Đặt isAdmin thành 1
        });
      },
    );
  }

  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('users', row);
  }

  Future<Map<String, dynamic>?> getUser(int phone, String password) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'phone = ? AND password = ?',
      whereArgs: [phone, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
  Future<List<Map<String, dynamic>>> getProducts() async {
    Database db = await database;
    return await db.query('products');
  }

  Future<int> insertProduct(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('products', row);
  }

  Future<int> updateProduct(int id, Map<String, dynamic> row) async {
    Database db = await database;
    return await db.update('products', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProduct(int id) async {
    Database db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}