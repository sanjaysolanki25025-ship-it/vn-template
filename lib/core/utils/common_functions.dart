import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vn_template/core/constant/app_string.dart';

class CommonFunction {
  static Future<void> launchUrlLink(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  static Future<bool> startCreatingIos({required String qrCodeLink}) async {
    final vnUrl = Uri.parse(qrCodeLink);

    final bool launched = await launchUrl(vnUrl, mode: LaunchMode.externalApplication);

    if (launched) {
      return true;
    } else {
      return false;
    }
  }

  static String cleanDescription(String? description) {
    if (description == null) return '';
    final regExp = RegExp(r'^(clips?|clipes?|photos?|photoes?)\s*:\s*[^,\s]+(,\s*)?', caseSensitive: false);
    return description.replaceFirst(regExp, '');
  }

  static Future<void> shareApp() async {
    await SharePlus.instance.share(
      ShareParams(
        text: AppStrings.shareAppMessage,
      ),
    );
  }
}
