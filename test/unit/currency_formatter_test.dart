import 'package:flutter_test/flutter_test.dart';
import 'package:promkin_app/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Unit Tests', () {
    test('formats standard amount correctly with baht symbol and decimals', () {
      expect(CurrencyFormatter.format(150.0), '฿150.00');
      expect(CurrencyFormatter.format(1250.50), '฿1,250.50');
      expect(CurrencyFormatter.format(0.0), '฿0.00');
    });

    test('formats compact amount correctly without decimals', () {
      expect(CurrencyFormatter.formatCompact(300.0), '฿300');
      expect(CurrencyFormatter.formatCompact(1500.0), '฿1,500');
    });
  });
}
