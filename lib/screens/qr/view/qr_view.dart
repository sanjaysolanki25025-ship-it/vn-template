import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/bloc/banner_ad_bloc.dart';
import 'package:vn_template/common_widgets/ad_widgets/banner_ad/view/banner_ad_widget.dart';
import 'package:vn_template/common_widgets/common_app_bar.dart';
import 'package:vn_template/common_widgets/common_button.dart';
import 'package:vn_template/common_widgets/common_dialog.dart';
import 'package:vn_template/common_widgets/common_image.dart';
import 'package:vn_template/common_widgets/common_sizedbox.dart';
import 'package:vn_template/common_widgets/common_text_widget.dart';
import 'package:vn_template/common_widgets/common_toast.dart';
import 'package:vn_template/core/constant/app_ad_id_string.dart';
import 'package:vn_template/core/constant/app_colors.dart';
import 'package:vn_template/core/constant/app_image_string.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_text_style.dart';
import 'package:vn_template/screens/qr/bloc/qr_bloc.dart';

class QrCodeView extends StatefulWidget {
  final String qrLink;
  final String title;

  const QrCodeView({super.key, required this.qrLink, required this.title});

  @override
  State<QrCodeView> createState() => _QrCodeViewState();
}

class _QrCodeViewState extends State<QrCodeView> {
  @override
  void initState() {
    context.read<QrCodeBloc>().add(CheckInternetConnectivityEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CommonAppBar(title: AppStrings.txtQrCode),
      ),
      body: BlocListener<QrCodeBloc, QrCodeState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == QrCodeStatus.loading) {
            CommonDialog.loaderDialog(context: context);
          } else if (state.status == QrCodeStatus.loaded) {
            CommonDialog.closeDialog(context: context);
            CommonToast.showToast(
              context: context,
              message: AppStrings.txtSavedToGallery,
              isError: false,
            );
          } else if (state.status == QrCodeStatus.error) {
            CommonDialog.closeDialog(context: context);
            CommonToast.showToast(
              context: context,
              message:
                  state.errorMessage ??
                  AppStrings.txtSomethingWentWrong.getString(context),
              isError: true,
            );
          }
        },
        child: BlocBuilder<QrCodeBloc, QrCodeState>(
          builder: (context, state) {
            if (state.status == QrCodeStatus.hasInternetError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 60,
                        color: AppColors.whiteColor,
                      ),
                      const SBH10(),
                      CommonTextWidget(
                        text: AppStrings.txtNoInternetConnection.getString(
                          context,
                        ),
                        textStyle: size16TextStyle(
                          textColor: AppColors.whiteColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RepaintBoundary(
                      key: context.read<QrCodeBloc>().qrCardKey,
                      child: Stack(
                        children: [
                          ClipPath(
                            clipper: TicketClipper(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: 25,
                              ),
                              width: 350,
                              height: 500,
                              decoration: BoxDecoration(
                                color: AppColors.lightPrimaryColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  const SBH10(),
                                  Row(
                                    children: [
                                      Card(
                                        elevation: 2,
                                        color: AppColors.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: SizedBox(
                                            height: 55,
                                            width: 55,
                                            child: Center(
                                              child: CommonImage(
                                                height: 50,
                                                width: 50,
                                                assetName: AppImagesString
                                                    .imgAppLogo,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SBW10(),
                                      Expanded(
                                        child: CommonTextWidget(
                                          text: AppStrings
                                              .txtVNTemplateQrVideoEditorReels,
                                          textStyle: size18TextStyle(
                                            textColor: AppColors.whiteColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SBH30(),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteColor,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.blackColor
                                              .withValues(alpha: 0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: QrImageView(
                                      data: widget.qrLink,
                                      size: 160,
                                      backgroundColor: AppColors.whiteColor,
                                      eyeStyle: const QrEyeStyle(
                                        eyeShape: QrEyeShape.square,
                                        color: AppColors.primaryColor,
                                      ),
                                      dataModuleStyle: QrDataModuleStyle(
                                        dataModuleShape:
                                            QrDataModuleShape.square,
                                        color: AppColors.blackColor
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),
                                  const SBH20(),
                                  CommonTextWidget(
                                    text: AppStrings.txtScanInVNApp,
                                    textStyle: size16TextStyle(
                                      textColor: AppColors.whiteColor.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SBH10(),
                                  SizedBox(
                                    height: 1,
                                    width: double.infinity,
                                    child: CustomPaint(
                                      painter: TopDashedBorderPainter(
                                        color: AppColors.whiteColor.withValues(alpha: 0.4),
                                        strokeWidth: 1,
                                        dashPattern: const [6, 4],
                                      ),
                                    ),
                                  ),
                                  const SBH10(),
                                  CommonTextWidget(
                                    text: widget.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textStyle: size18TextStyle(
                                      textColor: AppColors.whiteColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Positioned.fill(
                            child: CustomPaint(
                              painter: TicketBorderPainter(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SBH15(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: CommonButton(
                        text: AppStrings.txtDownload.getString(context),
                        onTap: () async {
                          context.read<QrCodeBloc>().add(DownloadImageEvent());
                        },
                      ),
                    ),
                    const SBH10(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BlocProvider(
        create: (_) => BannerAdBloc(),
        child: BannerAdWidget(adId: AppAdIdString.qrBannerAd),
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 15;
    double cornerRadius = 16;
    double verticalPosition = size.height - 75;

    Path path = Path();

    // Top-left rounded corner
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    // Top edge
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    // Right notch
    path.lineTo(size.width, verticalPosition - radius);
    path.arcToPoint(
      Offset(size.width, verticalPosition + radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height - cornerRadius);

    // Bottom-right rounded corner
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );

    // Bottom edge
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);

    // Left notch
    path.lineTo(0, verticalPosition + radius);
    path.arcToPoint(
      Offset(0, verticalPosition - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(0, cornerRadius);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class TicketBorderPainter extends CustomPainter {
  const TicketBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.greyColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final Path path = TicketClipper().getClip(size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TopDashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;

  TopDashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double dashWidth = dashPattern[0];
    double dashSpace = dashPattern[1];
    double startX = 0;
    final maxX = size.width;
    const y = 0.0; // Top position

    while (startX < maxX) {
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
