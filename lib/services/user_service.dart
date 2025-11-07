import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class UserService {
  static const _table = 'users';
  static bool _loggedIn = false;
  static String? _currentUserName;

  // Cadastro de usuário
  static Future<void> registerUser(String name, String email, String password) async {
    final db = await DatabaseHelper().database;

    await db.insert(
      _table,
      {'name': name, 'email': email, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Login
  static Future<bool> login(String email, String password) async {
    final db = await DatabaseHelper().database;

    final result = await db.query(
      _table,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      _loggedIn = true;
      _currentUserName = result.first['name'] as String;
      return true;
    }

    return false;
  }

  // Nome do usuário logado
  static Future<String?> getUserName() async {
    return _currentUserName;
  }

  // Verifica login
  static Future<bool> isLoggedIn() async {
    return _loggedIn;
  }

  // Logout
  static Future<void> logout() async {
    _loggedIn = false;
    _currentUserName = null;
  }
}
