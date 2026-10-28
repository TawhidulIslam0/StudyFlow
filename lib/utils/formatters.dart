import 'package:intl/intl.dart';

final dayFormat = DateFormat('EEE, MMM d');
final dateFormat = DateFormat('MMM d, yyyy');
final timeFormat = DateFormat('h:mm a');

String prettyDate(DateTime value) => dateFormat.format(value);
String shortDay(DateTime value) => dayFormat.format(value);
String prettyTime(DateTime value) => timeFormat.format(value);
String dueLabel(DateTime value) {
  final today = DateTime.now();
  final due = DateTime(value.year, value.month, value.day);
  final current = DateTime(today.year, today.month, today.day);
  final diff = due.difference(current).inDays;
  if (diff == 0) return 'Due today';
  if (diff == 1) return 'Due tomorrow';
  if (diff == -1) return 'Overdue by 1 day';
  if (diff < 0) return 'Overdue by ${diff.abs()} days';
  return 'Due in $diff days';
}
