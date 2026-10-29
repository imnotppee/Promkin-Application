import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promkin_app/core/widgets/motion_widgets.dart';
import 'package:promkin_app/core/widgets/promkin_header.dart';

void main() {
  testWidgets('FadeSlideIn and AnimatedPressable work correctly', (
    tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FadeSlideIn(
            delay: const Duration(milliseconds: 50),
            child: AnimatedPressable(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Tap Me'), findsOneWidget);

    await tester.tap(find.text('Tap Me'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('PromkinHeader triggers callbacks', (tester) async {
    bool tuned = false;
    bool profiled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PromkinHeader(
            onTune: () => tuned = true,
            onProfile: () => profiled = true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('PromKin'), findsOneWidget);
    expect(find.text('พร้อมกิน'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(tuned, isTrue);

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    expect(profiled, isTrue);
  });
}
