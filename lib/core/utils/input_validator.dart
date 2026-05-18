class InputValidator {
  static String? validatePasswordConfirmation(
    String password,
    String passwordConfirmation,
  ) {
    if (passwordConfirmation.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (password != passwordConfirmation) {
      return 'Password dan konfirmasi tidak cocok';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password wajib diisi';
    }
    if (password.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password harus mengandung huruf besar';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password harus mengandung huruf kecil';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung angka';
    }
    return null;
  }

  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(r'^[\w-\.+]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String sanitizeInput(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .trim();
  }
}
