import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/features/auth/presentation/auth_provider.dart';
import 'package:promkin_app/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders email, password fields and performs login', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final authProvider = AuthProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('พร้อมกิน | มื้อดีคุมงบได้'), findsOneWidget);
    expect(find.text('เข้าสู่ระบบ'), findsWidgets);

    // Enter email and password
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'test@promkin.com');
    await tester.enterText(textFields.at(1), 'password123');
    await tester.pumpAndSettle();

    final submitBtn = find.widgetWithText(ElevatedButton, 'เข้าสู่ระบบ');
    await tester.tap(submitBtn);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(authProvider.isAuthenticated, isTrue);
  });
}
