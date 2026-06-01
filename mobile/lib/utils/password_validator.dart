class PasswordValidator {
  static final RegExp _hasUppercase = RegExp(r'[A-Z]');
  static final RegExp _hasLowercase = RegExp(r'[a-z]');
  static final RegExp _hasNumber = RegExp(r'\d');

  static const String requirementsMessage =
      'Use 8+ characters, one uppercase, one lowercase and one number';

  static String? validate(String? value, {String emptyMessage = 'Enter a password'}) {
    final password = value ?? '';

    if (password.isEmpty) {
      return emptyMessage;
    }

    if (password.length < 8 ||
        !_hasUppercase.hasMatch(password) ||
        !_hasLowercase.hasMatch(password) ||
        !_hasNumber.hasMatch(password)) {
      return requirementsMessage;
    }

    return null;
  }
}
