class PhilippinePhoneUtils {
  static String? normalizeMobile(String? rawPhone) {
    if (rawPhone == null || rawPhone.trim().isEmpty) {
      return null;
    }

    final digitsOnly = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    String? normalized;

    if (digitsOnly.length == 12 && digitsOnly.startsWith('63')) {
      normalized = '+$digitsOnly';
    } else if (digitsOnly.length == 11 && digitsOnly.startsWith('09')) {
      normalized = '+63${digitsOnly.substring(1)}';
    } else if (digitsOnly.length == 10 && digitsOnly.startsWith('9')) {
      normalized = '+63$digitsOnly';
    }

    if (normalized == null) {
      return null;
    }

    return RegExp(r'^\+639\d{9}$').hasMatch(normalized)
        ? normalized
        : null;
  }
}