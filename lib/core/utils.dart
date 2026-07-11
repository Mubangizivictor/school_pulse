import 'dart:math';
import 'package:intl/intl.dart';

/// Prefix for parent family access codes, e.g. "KHA1234".
const String kSchoolAccessCodePrefix = 'KHA';

class AccessCodeGenerator {
  /// Format: {prefix}{4 random digits}, no separators - e.g. "KHA1234".
  static String generate() {
    final random = Random.secure();
    final digits = List.generate(4, (_) => random.nextInt(10)).join();
    return '$kSchoolAccessCodePrefix$digits';
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
