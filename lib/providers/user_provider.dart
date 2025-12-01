import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/database_helper.dart';

class UserProvider with ChangeNotifier {
  String? _userName;
  String _currency = '\$';
  bool _hasRegisteredUser = false;
  bool _isLoggedIn = false;

  String? get userName => _userName;
  String get currency => _currency;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasRegisteredUser => _hasRegisteredUser;

  UserProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _currency = prefs.getString('currency') ?? '\$';

    final db = await DatabaseHelper.instance.database;
    final users = await db.query('users');
    _hasRegisteredUser = users.isNotEmpty;

    if (_isLoggedIn && users.isNotEmpty) {
      _userName = users.first['name'] as String?;
    }
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password) async {
    final db = await DatabaseHelper.instance.database;

    // Check if email exists
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existing.isNotEmpty) {
      return false; // Email already taken
    }

    await db.insert('users', {
      'id': const Uuid().v4(),
      'name': name,
      'email': email,
      'password': password, // In production, hash this!
      'created_at': DateTime.now().toIso8601String(),
    });

    _userName = name;
    _isLoggedIn = true;
    _hasRegisteredUser = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', name);

    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    final db = await DatabaseHelper.instance.database;

    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      _userName = maps.first['name'] as String;
      _isLoggedIn = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userName', _userName!);

      notifyListeners();
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    // We don't clear the DB on logout, just the session

    _userName = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
