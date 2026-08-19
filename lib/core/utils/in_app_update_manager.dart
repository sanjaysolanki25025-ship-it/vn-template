import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:logger/logger.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/core/constant/app_string.dart';

class InAppUpdateManager {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  /// Checks for available updates and starts the appropriate flow.
  static Future<void> checkForUpdate(BuildContext context) async {
    if (!Platform.isAndroid) return;

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          // Trigger immediate update (Managed entirely by Google Play full-screen UI)
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          // Trigger flexible update (Downloads in the background)
          await InAppUpdate.startFlexibleUpdate();
          if (context.mounted) {
            _showUpdateDownloadedSnackBar(context);
          }
        }
      } else if (updateInfo.installStatus == InstallStatus.downloaded) {
        // If update was already downloaded but not installed (e.g. from previous run)
        if (context.mounted) {
          _showUpdateDownloadedSnackBar(context);
        }
      }
    } catch (e) {
      _logger.e("Error checking/performing in-app update: $e");
    }
  }

  /// Displays a customized SnackBar to notify the user to restart and install the update.
  static void _showUpdateDownloadedSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      backgroundColor: AppColors.secondaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.greyColor, width: 1),
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      content: Row(
        children: [
          const Icon(Icons.system_update_alt, color: AppColors.accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonTextWidget(
                  text: AppStrings.txtUpdateReady,
                  textStyle: size14TextStyle(
                    textColor: AppColors.whiteColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SBH2(),
                CommonTextWidget(
                  text: AppStrings.txtUpdateDownloadedRestart,
                  textStyle: size12TextStyle(textColor: AppColors.greyColor),
                ),
              ],
            ),
          ),
        ],
      ),
      action: SnackBarAction(
        label: AppStrings.txtInAppRestart,
        textColor: AppColors.accentColor,
        onPressed: () async {
          try {
            await InAppUpdate.completeFlexibleUpdate();
          } catch (e) {
            _logger.e("Failed to complete flexible update: $e");
          }
        },
      ),
      duration: const Duration(
        days: 365,
      ), // Keep open until user explicitly actions it
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
