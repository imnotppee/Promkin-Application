import 'package:flutter_test/flutter_test.dart';
import 'package:promkin_app/features/auth/presentation/auth_provider.dart';

void main() {
  group('AuthProvider Unit Tests', () {
    test('initializes with default demo user', () {
      final auth = AuthProvider();
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser?.email, 'user@promkin.app');
      expect(auth.isLoading, isFalse);
    });

    test('login updates currentUser and notifies listeners', () async {
      final auth = AuthProvider();
      final success = await auth.login('somchai@test.com', 'password123');
      expect(success, isTrue);
      expect(auth.currentUser?.name, 'somchai');
      expect(auth.currentUser?.email, 'somchai@test.com');
      expect(auth.isLoading, isFalse);
    });

    test('logout clears currentUser', () async {
      final auth = AuthProvider();
      await auth.logout();
      expect(auth.isAuthenticated, isFalse);
      expect(auth.currentUser, isNull);
    });
  });
}

