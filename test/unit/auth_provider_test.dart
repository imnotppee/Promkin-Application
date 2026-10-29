import 'package:flutter_test/flutter_test.dart';
import 'package:promkin_app/features/auth/data/user_model.dart';
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

    test('login with empty credentials fails and sets errorMessage', () async {
      final auth = AuthProvider();
      final success1 = await auth.login('', '123456');
      expect(success1, isFalse);
      expect(auth.errorMessage, isNotNull);

      final success2 = await auth.login('test@test.com', '');
      expect(success2, isFalse);
      expect(auth.errorMessage, isNotNull);
    });

    test(
      'createAccount creates user in offline mode and validates fields',
      () async {
        final auth = AuthProvider();
        final failEmpty = await auth.createAccount('', '', '');
        expect(failEmpty, isFalse);
        expect(auth.errorMessage, isNotNull);

        final success = await auth.createAccount(
          'น้องพร้อม',
          'promkin@test.com',
          '12345678',
        );
        expect(success, isTrue);
        expect(auth.currentUser?.name, 'น้องพร้อม');
        expect(auth.currentUser?.email, 'promkin@test.com');
        expect(auth.isAuthenticated, isTrue);
      },
    );

    test('signInWithGoogle signs in offline demo user', () async {
      final auth = AuthProvider();
      final success = await auth.signInWithGoogle();
      expect(success, isTrue);
      expect(auth.currentUser?.name, 'Promkin User');
      expect(auth.isAuthenticated, isTrue);
    });

    test('logout clears currentUser', () async {
      final auth = AuthProvider();
      await auth.logout();
      expect(auth.isAuthenticated, isFalse);
      expect(auth.currentUser, isNull);
    });

    test('UserModel serializes and deserializes correctly', () {
      final user = UserModel(
        id: 'u123',
        name: 'สมชาย',
        email: 'somchai@app.com',
        avatarUrl: 'https://avatar.com/1.png',
      );
      final json = user.toJson();
      expect(json['id'], 'u123');
      expect(json['name'], 'สมชาย');
      expect(json['email'], 'somchai@app.com');
      expect(json['avatarUrl'], 'https://avatar.com/1.png');

      final fromJson = UserModel.fromJson(json);
      expect(fromJson.id, 'u123');
      expect(fromJson.name, 'สมชาย');
      expect(fromJson.email, 'somchai@app.com');
      expect(fromJson.avatarUrl, 'https://avatar.com/1.png');

      final fallback = UserModel.fromJson({});
      expect(fallback.id, isEmpty);
      expect(fallback.name, isEmpty);
      expect(fallback.email, isEmpty);
      expect(fallback.avatarUrl, isNull);
    });

    test(
      'resetPassword validates email and handles offline fallback',
      () async {
        final auth = AuthProvider();
        final failEmpty = await auth.resetPassword('');
        expect(failEmpty, isFalse);
        expect(auth.errorMessage, isNotNull);

        final success = await auth.resetPassword('user@promkin.com');
        expect(success, isTrue);
      },
    );
  });
}
