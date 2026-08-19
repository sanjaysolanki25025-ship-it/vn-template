import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String? id;
  final String categoryName;
  final DateTime? createdAt;
  late final bool isSelected;
  final DateTime? updatedAt;

  CategoryModel({
    this.id,
    required this.categoryName,
    this.createdAt,
    this.isSelected = false,
    this.updatedAt,
  });

  CategoryModel copyWith({
    String? id,
    String? categoryName,
    DateTime? createdAt,
    bool? isSelected,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      createdAt: createdAt ?? this.createdAt,
      isSelected: isSelected ?? this.isSelected,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryName': categoryName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return CategoryModel(
      id: docId ?? map['id'],
      categoryName: map['categoryName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
