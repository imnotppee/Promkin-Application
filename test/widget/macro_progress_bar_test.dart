import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promkin_app/features/nutrition/presentation/widgets/macro_progress_bar.dart';

void main() {
  group('MacroProgressBar Widget Tests', () {
    testWidgets('displays label, values and unit correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MacroProgressBar(
              label: 'โปรตีน (Protein)',
              current: 45.0,
              target: 60.0,
              unit: 'g',
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('โปรตีน (Protein)'), findsOneWidget);
      expect(find.text('45.0 / 60 g (75%)'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
