import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/features/auth/presentation/auth_provider.dart';
import 'package:promkin_app/features/auth/presentation/screens/profile_screen.dart';

void main() {
  testWidgets('ProfileScreen renders user details and handles logout', (
    tester,
  ) async {
    final authProvider = AuthProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('โปรไฟล์ผู้ใช้'), findsOneWidget);
    expect(find.text('Promkin User'), findsOneWidget);
    expect(find.text('user@promkin.app'), findsOneWidget);

    // Tap logout button
    await tester.tap(find.text('ออกจากระบบ'));
    await tester.pumpAndSettle();

    expect(find.text('กลับไปหน้าเข้าสู่ระบบ'), findsOneWidget);
  });
}
