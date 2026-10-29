import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:promkin_app/core/utils/date_formatter.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('th_TH', null);
  });

  group('DateFormatter Unit Tests', () {
    final date = DateTime(2026, 10, 29);

    test('toIso formats to yyyy-MM-dd', () {
      expect(DateFormatter.toIso(date), '2026-10-29');
    });

    test('fromIso parses yyyy-MM-dd correctly', () {
      final parsed = DateFormatter.fromIso('2026-10-29');
      expect(parsed.year, 2026);
      expect(parsed.month, 10);
      expect(parsed.day, 29);
    });

    test('formatFull formats with Thai locale', () {
      expect(DateFormatter.formatFull(date), contains('2026'));
    });

    test('formatDayOfWeek returns day name', () {
      expect(DateFormatter.formatDayOfWeek(date).isNotEmpty, isTrue);
    });

    test('formatShort returns short day and month', () {
      expect(DateFormatter.formatShort(date), contains('29'));
    });
  });
}
