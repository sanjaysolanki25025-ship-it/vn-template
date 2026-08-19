part of 'qr_bloc.dart';

abstract class QrCodeEvent {}

class CheckInternetConnectivityEvent extends QrCodeEvent {}

class DownloadImageEvent extends QrCodeEvent {}
