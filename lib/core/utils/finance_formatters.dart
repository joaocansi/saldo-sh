DateTime monthStart(DateTime date) => DateTime(date.year, date.month);
DateTime addMonths(DateTime date, int months) {
  final target = DateTime(date.year, date.month + months, 1);
  final lastDay = DateTime(target.year, target.month + 1, 0).day;
  return DateTime(target.year, target.month, mathMin(date.day, lastDay));
}

int mathMin(int a, int b) => a < b ? a : b;
bool sameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;
String money(double value) =>
    'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
String shortDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
String monthLabel(DateTime value) {
  final name = const [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ][value.month - 1];
  return '$name ${value.year}';
}
