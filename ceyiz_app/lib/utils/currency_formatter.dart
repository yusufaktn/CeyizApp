import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Statik para birimi formatı - 1.234,56 ₺ (Türkiye formatı)
  static final NumberFormat turkishLiraFormat = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  // Double değeri formatlanmış para birimi string'ine dönüştürür
  static String format(double value) {
    return turkishLiraFormat.format(value);
  }

  // String'i double değere dönüştürür (girdi 1.234,56 formatında olabilir)
  static double parse(String value) {
    if (value.isEmpty) return 0;

    // Tüm para birimi sembollerini ve boşlukları temizle
    final cleanValue = value.replaceAll('₺', '').replaceAll(' ', '').trim();

    try {
      // Noktaları kaldır, virgülü nokta yap (double.parse için)
      String normalized = cleanValue.replaceAll('.', '');
      normalized = normalized.replaceAll(',', '.');
      return double.parse(normalized);
    } catch (e) {
      return 0;
    }
  }
}

// Para birimi için kullanılabilecek input formatter
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _numberFormat = NumberFormat('#,##0.##', 'tr_TR');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    // Sadece rakam ve virgül kalsın
    String clean = text.replaceAll(RegExp(r'[^0-9,]'), '');

    // Eğer sadece virgül girildiyse "0," yap
    if (clean == ',') {
      return TextEditingValue(
        text: '0,',
        selection: const TextSelection.collapsed(offset: 2),
      );
    }

    // Virgülden sonra en fazla 2 basamak
    List<String> parts = clean.split(',');
    String whole = parts[0];
    String decimal = parts.length > 1 ? parts[1] : '';
    if (decimal.length > 2) decimal = decimal.substring(0, 2);

    // Tam kısmı double'a çevirip formatla
    String formattedWhole = '';
    if (whole.isNotEmpty) {
      formattedWhole = _numberFormat.format(int.parse(whole));
    }

    String result = decimal.isNotEmpty ? '$formattedWhole,$decimal' : formattedWhole;

    // İmleç pozisyonunu koru
    int selectionIndex = result.length - (text.length - newValue.selection.end);
    if (selectionIndex < 0) selectionIndex = 0;

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
