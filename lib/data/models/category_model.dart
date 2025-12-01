import 'package:flutter/material.dart';
import 'transaction_model.dart'; // For TransactionType

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final TransactionType type;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_code': icon.codePoint,
      'color_value': color.value,
      'type': type.name,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      icon: IconData(map['icon_code'], fontFamily: 'MaterialIcons'),
      color: Color(map['color_value']),
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
    );
  }
}
