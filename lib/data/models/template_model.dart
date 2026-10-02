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
  final String? videoUrl;
  final String? photoUrl;
  final int? likes;
  final int? usage;

  // UI-only helper states
  final bool isFavourite;
  final bool isMute;
  final bool isPlaying;

  // Compatibility getters for existing UI referencing previewVideo / previewImage
  String? get previewVideo => videoUrl;
  String? get previewImage => photoUrl;

  /// Returns true if video_url points to an image format (.jpg, .jpeg, .png, .webp, .gif, .bmp, etc.)
  bool get isVideoUrlImage {
    final rawUrl = (videoUrl ?? previewVideo ?? '').trim();
    if (rawUrl.isEmpty) return false;
    final cleanPath = Uri.decodeFull(rawUrl).toLowerCase().split('?').first;
    const imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
      '.gif',
      '.bmp',
      '.avif',
      '.heic',
      '.svg',
      '.tiff',
      '.ico',
    ];
    for (final ext in imageExtensions) {
      if (cleanPath.endsWith(ext) || cleanPath.contains(ext)) {
        return true;
      }
    }
    return false;
  }

  /// Returns true only if the template has a valid, non-empty video URL that is NOT an image
  bool get hasValidVideo {
    final rawUrl = (videoUrl ?? previewVideo ?? '').trim();
    if (rawUrl.isEmpty) return false;
    return !isVideoUrlImage;
  }

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
    String? previewVideo,
    String? previewImage,
    String? videoUrl,
    String? photoUrl,
    this.likes,
    this.usage,
    this.isFavourite = false,
    this.isMute = false,
    this.isPlaying = false,
  }) : videoUrl = videoUrl ?? previewVideo,
       photoUrl = photoUrl ?? previewImage,
       createdAt = createdAt ?? DateTime.now(),
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
    String? videoUrl,
    String? photoUrl,
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
      videoUrl: videoUrl ?? previewVideo ?? this.videoUrl,
      photoUrl: photoUrl ?? previewImage ?? this.photoUrl,
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
      'video_url': videoUrl ?? '',
      'photo_url': photoUrl ?? '',
      'likes': likes ?? 0,
      'usage': usage ?? 0,
    };
  }

  factory TemplateModel.fromMap(Map<String, dynamic> map) {
    return TemplateModel(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      qrCode: map['qrCode'] ?? '',
      category: () {
        final cat = map['category'];
        if (cat is List) {
          return cat.map((e) => e.toString()).toList();
        } else if (cat is String && cat.isNotEmpty) {
          return cat.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }
        return <String>[];
      }(),
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
      videoUrl: () {
        final v = map['video_url'] ??
            map['preview_video'] ??
            map['videoUrl'] ??
            map['previewVideo'] ??
            map['video'] ??
            map['url'];
        return v != null ? v.toString().trim() : '';
      }(),
      photoUrl: () {
        final p = map['photo_url'] ??
            map['preview_image'] ??
            map['photoUrl'] ??
            map['previewImage'] ??
            map['photo'] ??
            map['image'];
        return p != null ? p.toString().trim() : '';
      }(),
      likes: map['likes'] is int ? map['likes'] : 0,
      usage: map['usage'] is int ? map['usage'] : 0,
    );
  }

  factory TemplateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TemplateModel.fromMap({...data, 'id': doc.id});
  }
}
