enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String note;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name, // Store as string
      'category_id': category, // Match DB column name
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      category: map['category_id'], // Map from DB column
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }
}
