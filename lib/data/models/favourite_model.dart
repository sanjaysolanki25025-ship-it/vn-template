class FavouriteModel {
  final int? id;
  final String templateId;
  final String description;
  final String qrCode;
  final String category;
  final String language;
  final String code;
  final String clip;
  final String duration;
  final String createdAt;
  final double rand;
  final int coin;
  final String? title;
  final String? previewVideo;
  final String? previewImage;

  FavouriteModel({
    this.id,
    required this.templateId,
    required this.description,
    required this.qrCode,
    required this.category,
    required this.language,
    required this.code,
    required this.clip,
    required this.duration,
    required this.createdAt,
    required this.rand,
    required this.coin,
    this.title,
    this.previewVideo,
    this.previewImage,
  });

  FavouriteModel copyWith({
    int? id,
    String? templateId,
    String? description,
    String? qrCode,
    String? category,
    String? language,
    String? code,
    String? clip,
    String? duration,
    String? createdAt,
    double? rand,
    int? coin,
    String? title,
    String? previewVideo,
    String? previewImage,
  }) {
    return FavouriteModel(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'templateId': templateId,
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
    };
  }

  factory FavouriteModel.fromMap(Map<String, dynamic> map) {
    return FavouriteModel(
      id: map['id'],
      templateId: map['templateId'] ?? '',
      description: map['description'] ?? '',
      qrCode: map['qrCode'] ?? '',
      category: map['category'] ?? '',
      language: map['language'] ?? '',
      code: map['code'] ?? '',
      clip: map['clip'] ?? '',
      duration: map['duration'] ?? '',
      createdAt: map['createdAt'] ?? '',
      rand: (map['rand'] is num) ? (map['rand'] as num).toDouble() : 0.0,
      coin: map['coin'] is int ? map['coin'] : (int.tryParse(map['coin']?.toString() ?? '0') ?? 0),
      title: map['title'],
      previewVideo: map['previewVideo'],
      previewImage: map['previewImage'],
    );
  }
}
