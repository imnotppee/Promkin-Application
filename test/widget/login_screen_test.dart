import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/features/auth/presentation/auth_provider.dart';
import 'package:promkin_app/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders email, password fields and performs login', (
    tester,
  ) async {
    final authProvider = AuthProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('เข้าสู่ระบบ Promkin'), findsOneWidget);
    expect(find.text('ยินดีต้อนรับสู่ Promkin'), findsOneWidget);
    expect(find.text('เข้าสู่ระบบ'), findsOneWidget);

    await tester.tap(find.text('เข้าสู่ระบบ'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(authProvider.isAuthenticated, isTrue);
  });
}
