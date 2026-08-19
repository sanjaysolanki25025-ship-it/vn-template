part of 'qr_bloc.dart';

enum QrCodeStatus { initial, loading, loaded, error, hasInternetError }

class QrCodeState {
  final QrCodeStatus status;
  final String? errorMessage;

  const QrCodeState({
    this.status = QrCodeStatus.initial,
    this.errorMessage,
  });

  QrCodeState copyWith({
    QrCodeStatus? status,
    String? errorMessage,
  }) {
    return QrCodeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
