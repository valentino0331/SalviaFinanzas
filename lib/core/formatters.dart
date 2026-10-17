
String formatMoney(double value) {
  final negative = value < 0;
  final fixed = value.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final intPart = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    final fromEnd = intPart.length - i;
    buffer.write(intPart[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
  }
  return '${negative ? '-' : ''}$buffer.${parts[1]}';
}

const List<String> _meses = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];


String formatExpenseDate(DateTime date, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final d0 = DateTime(today.year, today.month, today.day);
  final d1 = DateTime(date.year, date.month, date.day);
  final diff = d0.difference(d1).inDays;

  final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minutes = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour >= 12 ? 'PM' : 'AM';
  final time = '$hour12:$minutes $suffix';

  if (diff == 0) return 'Hoy, $time';
  if (diff == 1) return 'Ayer, $time';
  return '${date.day} ${_meses[date.month - 1]}, $time';
}
