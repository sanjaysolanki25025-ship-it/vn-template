import 'package:cloud_firestore/cloud_firestore.dart';

class OtherAppModel {
  final String appName;
  final String appLogo;
  final String appLink;
  final bool isAndroid;
  final DateTime? createdAt;

  OtherAppModel({
    required this.appName,
    required this.appLogo,
    required this.appLink,
    required this.isAndroid,
    this.createdAt,
  });

  OtherAppModel copyWith({
    String? appName,
    String? appLogo,
    String? appLink,
    bool? isAndroid,
    DateTime? createdAt,
  }) {
    return OtherAppModel(
      appName: appName ?? this.appName,
      appLogo: appLogo ?? this.appLogo,
      appLink: appLink ?? this.appLink,
      isAndroid: isAndroid ?? this.isAndroid,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory OtherAppModel.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt'];

    return OtherAppModel(
      appName: (json['appName'] ?? '').toString(),
      appLogo: (json['appLogo'] ?? '').toString(),
      appLink: (json['appLink'] ?? '').toString(),
      isAndroid: json['isAndroid'] ?? false,
      createdAt: _parseCreatedAt(rawCreatedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'appLogo': appLogo,
      'appLink': appLink,
      'isAndroid': isAndroid,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _parseCreatedAt(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}