class AppValidations {
  /// empty validation
  static String? validateNotEmpty({
    required String inputValue,
    required String errorMessage,
  }) {
    if (inputValue.isEmpty) {
      return errorMessage;
    }
    return null;
  }
}
