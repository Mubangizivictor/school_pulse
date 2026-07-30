import 'dart:math';
import 'package:intl/intl.dart';

/// Prefix for parent family access codes, e.g. "KHA1234".
/// DEPRECATED: Use IdentityService for code generation.
const String kSchoolAccessCodePrefix = 'KHA';

class AccessCodeGenerator {
  /// Format: {prefix}{4 random digits}, no separators - e.g. "KHA1234".
  /// DEPRECATED: Use IdentityService.generateParentCode instead.
  static String generate() {
    final random = Random.secure();
    final digits = List.generate(4, (_) => random.nextInt(10)).join();
    return '$kSchoolAccessCodePrefix$digits';
  }
}

/// Shared by the admin's "Generate Parent Access Code" form and the parent
/// login flow's phone-verification step - both must normalize a phone
/// number identically, or a correctly-typed number will never match what
/// was stored at registration.
class PhoneFormatter {
  /// Converts a Ugandan local number (07xxxxxxxx) into E.164 (+256xxxxxxxxx).
  static String toE164(String localPhone) {
    final digits = localPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('256')) return '+$digits';
    if (digits.startsWith('0')) return '+256${digits.substring(1)}';
    return '+256$digits';
  }
}

class CurrencyFormatter {
  static String format(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_UG',
      symbol: 'UGX ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String ugx(double amount) => format(amount);
}

class DateFormatter {
  static String format(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String relative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return format(date);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
