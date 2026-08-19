import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  static void log(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final tagStr = tag != null ? '[$tag] ' : '';
    if (error != null) {
      _logger.e('$tagStr$message', error: error, stackTrace: stackTrace);
    } else {
      _logger.i('$tagStr$message', stackTrace: stackTrace);
    }
  }
}
