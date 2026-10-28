import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dayOfWeekFormat = DateFormat('EEEE', 'th_TH');
  static final DateFormat _fullDateFormat = DateFormat('d MMMM yyyy', 'th_TH');
  static final DateFormat _shortDateFormat = DateFormat('d MMM', 'th_TH');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  static String toIso(DateTime date) {
    return _isoFormat.format(date);
  }

  static DateTime fromIso(String isoString) {
    return DateTime.parse(isoString);
  }

  static String formatFull(DateTime date) {
    return _fullDateFormat.format(date);
  }

  static String formatDayOfWeek(DateTime date) {
    return _dayOfWeekFormat.format(date);
  }

  static String formatShort(DateTime date) {
    return _shortDateFormat.format(date);
  }
}
