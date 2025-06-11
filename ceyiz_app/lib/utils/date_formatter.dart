import 'package:intl/intl.dart';

/// Tarih formatlamak için yardımcı sınıf
class DateFormatter {
  /// Tarihi gün/ay/yıl formatında döndürür
  static String formatShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Tarihi gün Ay Yıl formatında döndürür (örn: 15 Haziran 2023)
  static String formatMedium(DateTime date) {
    return DateFormat('d MMMM y', 'tr_TR').format(date);
  }

  /// Tarihi gün Ay Yıl, Saat:Dakika formatında döndürür (örn: 15 Haziran 2023, 14:30)
  static String formatLong(DateTime date) {
    return DateFormat('d MMMM y, HH:mm', 'tr_TR').format(date);
  }
}
