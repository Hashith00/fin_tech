import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/category_model.dart';
import '../data/database_helper.dart';
import '../data/models/transaction_model.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];

  CategoryProvider() {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('categories');

    if (maps.isEmpty) {
      await _seedDefaultCategories();
    } else {
      _categories = maps.map((map) => CategoryModel.fromMap(map)).toList();
      notifyListeners();
    }
  }

  Future<void> _seedDefaultCategories() async {
    final defaultCategories = [
      CategoryModel(
        id: '1',
        name: 'Food',
        icon: Icons.fastfood,
        color: Colors.orange,
        type: TransactionType.expense,
      ),
      CategoryModel(
        id: '2',
        name: 'Transport',
        icon: Icons.directions_car,
        color: Colors.blue,
        type: TransactionType.expense,
      ),
      CategoryModel(
        id: '3',
        name: 'Shopping',
        icon: Icons.shopping_bag,
        color: Colors.purple,
        type: TransactionType.expense,
      ),
      CategoryModel(
        id: '4',
        name: 'Entertainment',
        icon: Icons.movie,
        color: Colors.red,
        type: TransactionType.expense,
      ),
      CategoryModel(
        id: '5',
        name: 'Bills',
        icon: Icons.receipt,
        color: Colors.green,
        type: TransactionType.expense,
      ),
      CategoryModel(
        id: '6',
        name: 'Salary',
        icon: Icons.attach_money,
        color: Colors.green,
        type: TransactionType.income,
      ),
      CategoryModel(
        id: '7',
        name: 'Freelance',
        icon: Icons.computer,
        color: Colors.blue,
        type: TransactionType.income,
      ),
      CategoryModel(
        id: '8',
        name: 'Gift',
        icon: Icons.card_giftcard,
        color: Colors.pink,
        type: TransactionType.income,
      ),
    ];

    for (var category in defaultCategories) {
      await DatabaseHelper.instance.database.then((db) {
        db.insert('categories', category.toMap());
      });
    }
    _categories = defaultCategories;
    notifyListeners();
  }

  List<CategoryModel> get categories => [..._categories];

  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.type == TransactionType.expense).toList();

  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => c.type == TransactionType.income).toList();

  Future<void> addCategory({
    required String name,
    required IconData icon,
    required Color color,
    required TransactionType type,
  }) async {
    final newCategory = CategoryModel(
      id: const Uuid().v4(),
      name: name,
      icon: icon,
      color: color,
      type: type,
    );

    final db = await DatabaseHelper.instance.database;
    await db.insert('categories', newCategory.toMap());

    _categories.add(newCategory);
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);

    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
