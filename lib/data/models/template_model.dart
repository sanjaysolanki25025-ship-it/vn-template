import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class TemplateModel {
  final String? id;
  final String? description;
  final String? qrCode;
  final List<String>? category;
  final String? language;
  final String? code;
  final String? clip;
  final String? duration;
  final DateTime createdAt;
  final double rand;
  final int? coin;
  final String? title;
  final String? previewVideo;
  final String? previewImage;
  final int? likes;
  final int? usage;

  // UI-only helper states
  final bool isFavourite;
  final bool isMute;
  final bool isPlaying;

  TemplateModel({
    this.id,
    this.description,
    this.qrCode,
    this.category,
    this.language,
    this.code,
    this.clip,
    this.duration,
    DateTime? createdAt,
    double? rand,
    this.coin,
    this.title,
    this.previewVideo,
    this.previewImage,
    this.likes,
    this.usage,
    this.isFavourite = false,
    this.isMute = false,
    this.isPlaying = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       rand = rand ?? Random().nextDouble();

  TemplateModel copyWith({
    String? id,
    String? description,
    String? qrCode,
    List<String>? category,
    String? language,
    String? code,
    String? clip,
    String? duration,
    DateTime? createdAt,
    double? rand,
    int? coin,
    String? title,
    String? previewVideo,
    String? previewImage,
    int? likes,
    int? usage,
    bool? isFavourite,
    bool? isMute,
    bool? isPlaying,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      description: description ?? this.description,
      qrCode: qrCode ?? this.qrCode,
      category: category ?? this.category,
      language: language ?? this.language,
      code: code ?? this.code,
      clip: clip ?? this.clip,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      rand: rand ?? this.rand,
      coin: coin ?? this.coin,
      title: title ?? this.title,
      previewVideo: previewVideo ?? this.previewVideo,
      previewImage: previewImage ?? this.previewImage,
      likes: likes ?? this.likes,
      usage: usage ?? this.usage,
      isFavourite: isFavourite ?? this.isFavourite,
      isMute: isMute ?? this.isMute,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'qrCode': qrCode,
      'category': category,
      'language': language,
      'code': code,
      'clip': clip,
      'duration': duration,
      'createdAt': createdAt,
      'rand': rand,
      'coin': coin,
      'title': title,
      'previewVideo': previewVideo,
      'previewImage': previewImage,
      'likes': likes,
      'usage': usage,
    };
  }

  factory TemplateModel.fromMap(Map<String, dynamic> map) {
    return TemplateModel(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      qrCode: map['qrCode'] ?? '',
      category: List<String>.from(map['category'] ?? []),
      language: map['language'] ?? '',
      code: map['code'] ?? '',
      clip: map['clip'] ?? '',
      duration: map['duration'] ?? '',
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] ?? DateTime.now()),
      rand: (map['rand'] is num)
          ? (map['rand'] as num).toDouble()
          : Random().nextDouble(),
      coin: map['coin'] is int ? map['coin'] : 0,
      title: map['title'] ?? '',
      previewVideo: map['previewVideo'] ?? '',
      previewImage: map['previewImage'] ?? '',
      likes: map['likes'] is int ? map['likes'] : 0,
      usage: map['usage'] is int ? map['usage'] : 0,
    );
  }

  factory TemplateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TemplateModel.fromMap({...data, 'id': doc.id});
  }
}
