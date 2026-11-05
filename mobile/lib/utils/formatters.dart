String formatPrice(num value, String currency) {
  final rounded = value.round();
  final digits = rounded.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(' ');
    }
    buffer.write(digits[i]);
  }
  final sign = rounded < 0 ? '-' : '';
  return '$sign${buffer.toString()} $currency';
}

String formatDate(String? iso) {
  if (iso == null || iso.isEmpty) {
    return '';
  }
  final dt = DateTime.tryParse(iso)?.toLocal();
  if (dt == null) {
    return '';
  }
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(dt.day)}.${two(dt.month)}.${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
}

String shortCode(String? code) {
  if (code == null || code.isEmpty) {
    return '';
  }
  return code.length > 8 ? code.substring(0, 8) : code;
}
