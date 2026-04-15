String formatProfessorPaymentAmount(double value, {String currency = 'EUR'}) {
  final symbol = currency.toUpperCase() == 'EUR' ? '€' : currency;
  final fixed = value
      .toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)
      .replaceAll('.', ',');
  return symbol == '€' ? '$fixed$symbol' : '$fixed $symbol';
}

String formatProfessorPaymentDateTime(DateTime? date) {
  if (date == null) return '—';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/$year · $hour:$minute';
}
