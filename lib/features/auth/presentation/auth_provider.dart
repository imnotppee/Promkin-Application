import 'package:flutter/material.dart';
import 'package:promkin_app/features/auth/data/user_model.dart';
import 'package:promkin_app/core/services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    // Default demo user so app is immediately usable
    _currentUser = UserModel(
      id: 'usr_001',
      name: 'Promkin User',
      email: 'user@promkin.app',
    );
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      _currentUser = UserModel(
        id: 'usr_001',
        name: email.split('@').first,
        email: email,
      );
      await FirebaseService.instance.syncUserProfile(
        _currentUser!.id,
        _currentUser!.toJson(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }
}
