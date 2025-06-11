class Validator {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName alanı boş bırakılamaz';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta alanı boş bırakılamaz';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi giriniz';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Şifre alanı boş bırakılamaz';
    }

    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon alanı boş bırakılamaz';
    }

    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
      return 'Geçerli bir telefon numarası giriniz';
    }

    return null;
  }
}
