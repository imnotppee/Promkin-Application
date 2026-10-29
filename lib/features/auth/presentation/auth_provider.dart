import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:promkin_app/core/services/firebase_service.dart';
import 'package:promkin_app/features/auth/data/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final StreamSubscription<User?> _authSubscription;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    // ตรวจสอบสถานะการเข้าสู่ระบบจริงจาก Firebase
    _authSubscription = _auth.authStateChanges().listen(
      _handleAuthStateChanged,
      onError: (Object error) {
        debugPrint('Firebase auth state error: $error');
        _errorMessage = 'ไม่สามารถตรวจสอบสถานะการเข้าสู่ระบบได้';
        notifyListeners();
      },
    );
  }

  Future<void> _handleAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    try {
      await _loadUserProfile(firebaseUser);
    } catch (e) {
      debugPrint('Load user profile failed: $e');

      // หากอ่านโปรไฟล์จาก Firestore ไม่ได้
      // ยังใช้ข้อมูลพื้นฐานจาก Firebase Authentication ได้
      _currentUser = _createUserModel(firebaseUser);
      notifyListeners();
    }
  }

  UserModel _createUserModel(
    User firebaseUser, {
    Map<String, dynamic>? profile,
  }) {
    final email = firebaseUser.email ?? '';
    final savedName = profile?['name']?.toString().trim() ?? '';

    final name = savedName.isNotEmpty
        ? savedName
        : (firebaseUser.displayName?.trim().isNotEmpty == true
              ? firebaseUser.displayName!.trim()
              : (email.contains('@') ? email.split('@').first : 'ผู้ใช้'));

    final savedAvatar = profile?['avatarUrl']?.toString();
    final avatarUrl = savedAvatar?.isNotEmpty == true
        ? savedAvatar
        : firebaseUser.photoURL;

    return UserModel(
      id: firebaseUser.uid,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );
  }

  Future<void> _loadUserProfile(User firebaseUser) async {
    Map<String, dynamic>? profile;

    try {
      profile = await FirebaseService.instance.getUserProfile(firebaseUser.uid);
    } catch (e) {
      debugPrint('Could not read Firestore profile: $e');
    }

    _currentUser = _createUserModel(firebaseUser, profile: profile);

    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = null;

    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty || password.isEmpty) {
      _errorMessage = 'กรุณากรอกอีเมลและรหัสผ่าน';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        _errorMessage = 'ไม่สามารถเข้าสู่ระบบได้ กรุณาลองอีกครั้ง';
        return false;
      }

      // อ่านข้อมูลโปรไฟล์เดิม และใช้ Firebase UID เป็นรหัสผู้ใช้
      Map<String, dynamic>? profile;

      try {
        profile = await FirebaseService.instance.getUserProfile(
          firebaseUser.uid,
        );
      } catch (e) {
        debugPrint('Read profile failed: $e');
      }

      final user = _createUserModel(firebaseUser, profile: profile);

      _currentUser = user;

      // บันทึกข้อมูลพื้นฐานโดยไม่ลบฟิลด์อื่นในเอกสารเดิม
      try {
        await FirebaseService.instance.syncUserProfile(
          firebaseUser.uid,
          user.toJson(),
        );
      } catch (e) {
        // หาก Firestore มีปัญหา ไม่ถือว่าการยืนยันตัวตนล้มเหลว
        debugPrint('Sync user profile failed: $e');
      }

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase login error: ${e.code}');

      switch (e.code) {
        case 'invalid-email':
          _errorMessage = 'รูปแบบอีเมลไม่ถูกต้อง';
          break;
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          _errorMessage = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
          break;
        case 'user-disabled':
          _errorMessage = 'บัญชีนี้ถูกระงับการใช้งาน';
          break;
        case 'too-many-requests':
          _errorMessage = 'มีการลองเข้าสู่ระบบหลายครั้งเกินไป กรุณารอสักครู่';
          break;
        case 'network-request-failed':
          _errorMessage = 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'ยังไม่ได้เปิดใช้งานการเข้าสู่ระบบด้วยอีเมล';
          break;
        default:
          _errorMessage = 'เข้าสู่ระบบไม่สำเร็จ กรุณาตรวจสอบข้อมูลอีกครั้ง';
      }

      return false;
    } catch (e) {
      debugPrint('Login failed: $e');
      _errorMessage = 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _errorMessage = null;

    try {
      await _auth.signOut();

      // authStateChanges() จะอัปเดต currentUser เป็น null
      // เมื่อออกจากระบบสำเร็จ
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase logout error: ${e.code}');
      _errorMessage = 'ออกจากระบบไม่สำเร็จ กรุณาลองอีกครั้ง';
      notifyListeners();
    } catch (e) {
      debugPrint('Logout failed: $e');
      _errorMessage = 'เกิดข้อผิดพลาดขณะออกจากระบบ';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
