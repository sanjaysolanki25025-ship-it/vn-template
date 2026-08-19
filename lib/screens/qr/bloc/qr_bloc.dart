import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vn_template/core/constant/app_string.dart';

part 'qr_event.dart';
part 'qr_state.dart';

class QrCodeBloc extends Bloc<QrCodeEvent, QrCodeState> {
  final GlobalKey qrCardKey = GlobalKey();

  QrCodeBloc() : super(const QrCodeState()) {
    on<CheckInternetConnectivityEvent>(_onCheckInternetConnectivity);
    on<DownloadImageEvent>(_onDownloadImage);
  }

  Future<void> _onCheckInternetConnectivity(
    CheckInternetConnectivityEvent event,
    Emitter<QrCodeState> emit,
  ) async {
    final hasInternet = await InternetConnection().hasInternetAccess;
    if (!hasInternet) {
      emit(state.copyWith(status: QrCodeStatus.hasInternetError));
    }
  }

  Future<void> _onDownloadImage(
    DownloadImageEvent event,
    Emitter<QrCodeState> emit,
  ) async {
    emit(state.copyWith(status: QrCodeStatus.loading));
    try {
      // Permission request across Android versions (Android 9, 10, 11, 12, 13, 14+)
      if (Platform.isAndroid) {
        PermissionStatus status = PermissionStatus.denied;
        if (await Permission.storage.isGranted ||
            await Permission.photos.isGranted) {
          status = PermissionStatus.granted;
        } else {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            status = await Permission.photos.request();
          }
        }

        if (status.isPermanentlyDenied) {
          openAppSettings();
          emit(state.copyWith(
            status: QrCodeStatus.error,
            errorMessage: AppStrings.txtPleaseEnableStoragePermissionInSettings,
          ));
          return;
        }
      }

      final boundary = qrCardKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        emit(state.copyWith(
          status: QrCodeStatus.error,
          errorMessage: AppStrings.txtFailedToCaptureImage,
        ));
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        emit(state.copyWith(
          status: QrCodeStatus.error,
          errorMessage: AppStrings.txtFailedToProcessImageData,
        ));
        return;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final result = await ImageGallerySaverPlus.saveImage(
        pngBytes,
        quality: 100,
        name: "vn_qr_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result != null &&
          (result['isSuccess'] == true || result['filePath'] != null)) {
        emit(state.copyWith(status: QrCodeStatus.loaded));
      } else {
        emit(state.copyWith(
          status: QrCodeStatus.error,
          errorMessage: AppStrings.txtFailedToSaveImage,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: QrCodeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
