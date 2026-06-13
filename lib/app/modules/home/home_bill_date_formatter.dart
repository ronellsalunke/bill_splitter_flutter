import 'package:intl/intl.dart';

String formatHomeBillCreatedAt(DateTime createdAt, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final today = DateTime(current.year, current.month, current.day);
  final createdDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
  final dayDifference = today.difference(createdDate).inDays;

  if (dayDifference <= 0) {
    return 'today';
  }

  if (dayDifference == 1) {
    return 'yesterday';
  }

  return DateFormat('d MMMM').format(createdAt);
}
