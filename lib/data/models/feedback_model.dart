class FeedbackModel {
  final String id;
  final String feedBackCategory;
  final String description;
  final bool privacyPolicy;
  final String phoneNumber;
  final String? referenceImage;

  FeedbackModel({
    this.id = '',
    required this.feedBackCategory,
    required this.description,
    required this.privacyPolicy,
    required this.phoneNumber,
    this.referenceImage,
  });

  FeedbackModel copyWith({
    String? id,
    String? feedBackCategory,
    String? description,
    bool? privacyPolicy,
    String? phoneNumber,
    String? referenceImage,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      feedBackCategory: feedBackCategory ?? this.feedBackCategory,
      description: description ?? this.description,
      privacyPolicy: privacyPolicy ?? this.privacyPolicy,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      referenceImage: referenceImage ?? this.referenceImage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'feedBackCategory': feedBackCategory,
      'description': description,
      'privacyPolicy': privacyPolicy,
      'referenceImage': referenceImage,
      'phoneNumber': phoneNumber,
      'createdAt': DateTime.now(),
    };
  }
}
