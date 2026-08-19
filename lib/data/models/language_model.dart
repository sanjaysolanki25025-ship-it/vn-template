import 'package:cloud_firestore/cloud_firestore.dart';

class LanguageModel {
  final String? id;
  final String languageName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSelected;

  LanguageModel({
    this.id,
    required this.languageName,
    this.createdAt,
    this.updatedAt,
    this.isSelected = false,
  });

  LanguageModel copyWith({
    String? id,
    String? languageName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSelected,
  }) {
    return LanguageModel(
      id: id ?? this.id,
      languageName: languageName ?? this.languageName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'languageName': languageName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory LanguageModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return LanguageModel(
      id: docId ?? map['id'],
      languageName: map['languageName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
