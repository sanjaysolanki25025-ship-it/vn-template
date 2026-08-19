class TemplateApiResponseModel {
  final int? code;
  final String? msg;
  final TemplateApiData? data;

  TemplateApiResponseModel({this.code, this.msg, this.data});

  factory TemplateApiResponseModel.fromJson(Map<String, dynamic> json) {
    return TemplateApiResponseModel(
      code: json['code'] as int?,
      msg: json['msg'] as String?,
      data: json['data'] != null
          ? TemplateApiData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TemplateApiData {
  final int? templateId;
  final String? title;
  final String? previewImage;
  final String? previewVideo;
  final int? duration;
  final String? category;
  final int? likes;
  final int? usage;
  final String? vntUrl;

  TemplateApiData({
    this.templateId,
    this.title,
    this.previewImage,
    this.previewVideo,
    this.duration,
    this.category,
    this.likes,
    this.usage,
    this.vntUrl,
  });

  factory TemplateApiData.fromJson(Map<String, dynamic> json) {
    return TemplateApiData(
      templateId: json['template_id'] as int?,
      title: json['title'] as String?,
      previewImage: json['preview_image'] as String?,
      previewVideo: json['preview_video'] as String?,
      duration: json['duration'] as int?,
      category: json['category'] as String?,
      likes: json['likes'] as int?,
      usage: json['usage'] as int?,
      vntUrl: json['vnt_url'] as String?,
    );
  }
}
