import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promkin_app/features/auth/presentation/screens/forgot_password_screen.dart';

void main() {
  testWidgets('ForgotPasswordScreen renders form and handles submit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Forgot Password'), findsOneWidget);
    expect(find.text('ลืมรหัสผ่าน?'), findsOneWidget);
    expect(find.text('ส่งลิงก์รีเซ็ตรหัสผ่าน'), findsOneWidget);

    // Try submit without entering email (validation error)
    await tester.tap(find.text('ส่งลิงก์รีเซ็ตรหัสผ่าน'));
    await tester.pumpAndSettle();
    expect(find.text('กรอกอีเมลหรือเบอร์โทรศัพท์ก่อน'), findsOneWidget);

    // Enter email and submit
    await tester.enterText(find.byType(TextFormField), 'user@promkin.com');
    await tester.pumpAndSettle();

    await tester.tap(find.text('ส่งลิงก์รีเซ็ตรหัสผ่าน'));
    await tester.pumpAndSettle();

    // Success card appears
    expect(find.text('ตรวจสอบอีเมลของคุณ'), findsOneWidget);
  });
}
