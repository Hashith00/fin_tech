import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/transaction_model.dart';
import '../data/database_helper.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];

  TransactionProvider() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('transactions');

    _transactions = maps.map((map) => TransactionModel.fromMap(map)).toList();
    notifyListeners();
  }

  List<TransactionModel> get transactions => [..._transactions];

  List<TransactionModel> get recentTransactions {
    final sorted = [..._transactions];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  double get totalIncome {
    return _transactions
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpense {
    return _transactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get balance => totalIncome - totalExpense;

  Future<void> addTransaction({
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    String note = '',
  }) async {
    final newTx = TransactionModel(
      id: const Uuid().v4(),
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: note,
    );

    final db = await DatabaseHelper.instance.database;
    await db.insert('transactions', newTx.toMap());

    _transactions.add(newTx);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);

    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }
}
