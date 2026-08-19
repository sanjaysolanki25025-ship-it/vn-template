import 'package:dio/dio.dart';
import 'package:vn_template/core/utils/app_logger.dart';
import 'package:vn_template/data/models/template_api_response_model.dart';
import 'package:vn_template/data/models/template_model.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<TemplateModel> enrichTemplate(TemplateModel template) async {
    final code = template.code;
    if (code == null || code.isEmpty) return template;
    try {
      final response = await _dio.get(
        'https://vn-api-render.onrender.com/decode',
        queryParameters: {'code': code},
        options: Options(
          headers: {
            'x-key': 'VnApi_K9x2mPqL7nW4vZ8',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        final apiResponse = TemplateApiResponseModel.fromJson(response.data as Map<String, dynamic>);
        final apiData = apiResponse.data;
        if (apiData != null) {
          return template.copyWith(
            title: apiData.title ?? '',
            previewImage: apiData.previewImage ?? '',
            previewVideo: apiData.previewVideo ?? '',
            likes: apiData.likes ?? 0,
            usage: apiData.usage ?? 0,
          );
        }
      }
    } catch (e) {
      AppLogger.log("API error for code $code: $e", error: e);
    }
    return template;
  }
}
