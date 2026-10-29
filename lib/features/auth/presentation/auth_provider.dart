import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:promkin_app/core/services/firebase_service.dart';
import 'package:promkin_app/features/auth/data/user_model.dart';

class AuthProvider extends ChangeNotifier {
  static Future<void>? _googleSignInInitialization;

  FirebaseAuth? _auth;
  StreamSubscription<User?>? _authSubscription;
  int _authStateRevision = 0;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider({FirebaseAuth? auth}) {
    // Graceful initialization: check if Firebase was successfully initialized
    if (FirebaseService.instance.isInitialized) {
      try {
        _auth = auth ?? FirebaseAuth.instance;
        _authSubscription = _auth!.authStateChanges().listen(
          _handleAuthStateChanged,
          onError: (Object error) {
            debugPrint('Firebase auth state error: $error');
            _errorMessage = 'ไม่สามารถตรวจสอบสถานะการเข้าสู่ระบบได้';
            notifyListeners();
          },
        );
      } catch (e) {
        debugPrint('Firebase Auth initialization error: $e');
        _setupDemoUser();
      }
    } else {
      _setupDemoUser();
    }
  }

  void _setupDemoUser() {
    _currentUser = UserModel(
      id: 'usr_001',
      name: 'Promkin User',
      email: 'user@promkin.app',
    );
  }

  Future<void> _handleAuthStateChanged(User? firebaseUser) async {
    final revision = ++_authStateRevision;
    if (firebaseUser == null) {
      // The stream's initial signed-out event can be delivered after an
      // interactive sign-in has already completed. Trust Firebase's live
      // session in that case instead of clearing the newly signed-in user.
      final activeUser = _auth?.currentUser;
      if (activeUser != null) {
        _currentUser = _createUserModel(activeUser);
        notifyListeners();
        return;
      }
      _currentUser = null;
      notifyListeners();
      return;
    }

    // Update the app gate from Firebase Auth immediately. Profile lookup may
    // fail or finish after sign-out, so it must never control authentication.
    _currentUser = _createUserModel(firebaseUser);
    notifyListeners();

    Map<String, dynamic>? profile;
    try {
      profile = await FirebaseService.instance.getUserProfile(firebaseUser.uid);
    } catch (e) {
      debugPrint('Could not load user profile: $e');
    }

    if (revision != _authStateRevision ||
        _auth?.currentUser?.uid != firebaseUser.uid) {
      return;
    }
    _currentUser = _createUserModel(firebaseUser, profile: profile);
    notifyListeners();
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

    // Offline / Demo / Test fallback
    if (_auth == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      _currentUser = UserModel(
        id: 'usr_001',
        name: normalizedEmail.contains('@')
            ? normalizedEmail.split('@').first
            : 'ผู้ใช้',
        email: normalizedEmail,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }

    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        _errorMessage = 'ไม่สามารถเข้าสู่ระบบได้ กรุณาลองอีกครั้ง';
        return false;
      }

      // Switch to the authenticated app as soon as Firebase accepts the
      // credentials. Profile and Firestore work must not block navigation.
      _currentUser = _createUserModel(firebaseUser);
      notifyListeners();

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
          _errorMessage =
              'อีเมลหรือรหัสผ่านไม่ถูกต้อง หากลืมรหัสให้กด “ลืมรหัสผ่าน?”';
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

  Future<bool> resetPassword(String email) async {
    _errorMessage = null;
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      _errorMessage = 'กรอกอีเมลที่ใช้สมัครก่อนรีเซ็ตรหัสผ่าน';
      notifyListeners();
      return false;
    }
    if (_auth == null) {
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = true;
    notifyListeners();
    try {
      await _auth!.sendPasswordResetEmail(email: normalizedEmail);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = switch (e.code) {
        'invalid-email' => 'รูปแบบอีเมลไม่ถูกต้อง',
        'network-request-failed' => 'เชื่อมต่ออินเทอร์เน็ตไม่ได้',
        'too-many-requests' => 'ส่งคำขอหลายครั้งเกินไป กรุณารอสักครู่',
        _ => 'ส่งลิงก์รีเซ็ตรหัสผ่านไม่สำเร็จ กรุณาลองอีกครั้ง',
      };
      return false;
    } catch (e) {
      debugPrint('Password reset failed: $e');
      _errorMessage = 'ส่งลิงก์รีเซ็ตรหัสผ่านไม่สำเร็จ กรุณาลองอีกครั้ง';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    if (_auth == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      _currentUser = UserModel(
        id: 'usr_google_demo',
        name: 'Promkin User',
        email: 'user@promkin.app',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }

    try {
      _googleSignInInitialization ??= GoogleSignIn.instance.initialize();
      await _googleSignInInitialization;

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        _errorMessage = 'อุปกรณ์นี้ยังไม่รองรับการเข้าสู่ระบบด้วย Google';
        return false;
      }

      final googleUser = await GoogleSignIn.instance.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        _errorMessage = 'Google ไม่ส่งข้อมูลยืนยันตัวตน กรุณาตรวจสอบ OAuth';
        return false;
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth!.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        _errorMessage = 'เข้าสู่ระบบด้วย Google ไม่สำเร็จ';
        return false;
      }

      // Firebase has a persisted session now. Enter the app immediately and
      // enrich the user profile asynchronously below.
      _currentUser = _createUserModel(firebaseUser);
      notifyListeners();

      Map<String, dynamic>? profile;
      try {
        profile = await FirebaseService.instance.getUserProfile(
          firebaseUser.uid,
        );
      } catch (e) {
        debugPrint('Read Google user profile failed: $e');
      }

      final user = _createUserModel(firebaseUser, profile: profile);
      _currentUser = user;
      try {
        await FirebaseService.instance.syncUserProfile(
          firebaseUser.uid,
          user.toJson(),
        );
      } catch (e) {
        debugPrint('Sync Google user profile failed: $e');
      }
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Google sign-in error: ${e.code}');
      _errorMessage = switch (e.code) {
        'account-exists-with-different-credential' =>
          'อีเมลนี้ผูกกับวิธีเข้าสู่ระบบอื่นอยู่แล้ว',
        'network-request-failed' => 'เชื่อมต่ออินเทอร์เน็ตไม่ได้',
        'operation-not-allowed' => 'ยังไม่ได้เปิด Google ใน Firebase Console',
        _ => 'Firebase ปฏิเสธการเข้าสู่ระบบด้วย Google (${e.code})',
      };
      return false;
    } catch (e) {
      final details = e.toString();
      debugPrint('Google sign-in failed: $details');
      if (details.toLowerCase().contains('cancel')) {
        _errorMessage = 'ยกเลิกการเข้าสู่ระบบด้วย Google';
      } else if (details.contains('serverClientId') ||
          details.contains('clientConfigurationError')) {
        _errorMessage =
            'Android Google OAuth ยังตั้งค่าไม่ครบ: เพิ่ม SHA-1 ใน Firebase แล้วดาวน์โหลด google-services.json ใหม่';
      } else {
        _errorMessage = 'เข้าสู่ระบบด้วย Google ไม่สำเร็จ กรุณาตรวจสอบ OAuth';
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAccount(String name, String email, String password) async {
    _errorMessage = null;
    final normalizedName = name.trim();
    final normalizedEmail = email.trim();

    if (normalizedName.isEmpty || normalizedEmail.isEmpty || password.isEmpty) {
      _errorMessage = 'กรุณากรอกชื่อ อีเมล และรหัสผ่าน';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    if (_auth == null) {
      await Future.delayed(const Duration(milliseconds: 400));
      _currentUser = UserModel(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: normalizedName,
        email: normalizedEmail,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }

    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        _errorMessage = 'สร้างบัญชีไม่สำเร็จ กรุณาลองอีกครั้ง';
        return false;
      }

      try {
        await firebaseUser.updateDisplayName(normalizedName);
      } catch (e) {
        debugPrint('Could not update Firebase display name: $e');
      }
      final user = _createUserModel(
        _auth!.currentUser ?? firebaseUser,
        profile: {'name': normalizedName},
      );
      _currentUser = user;
      // Firebase signs the user in during account creation. Switch to the app
      // immediately; profile sync should not make the user sign in again.
      notifyListeners();

      // Account creation succeeds even if profile sync is temporarily offline.
      try {
        await FirebaseService.instance.syncUserProfile(user.id, {
          ...user.toJson(),
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Sync new user profile failed: $e');
      }

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        try {
          final existingCredential = await _auth!.signInWithEmailAndPassword(
            email: normalizedEmail,
            password: password,
          );
          final existingUser = existingCredential.user;
          if (existingUser == null) {
            _errorMessage = 'เข้าสู่ระบบไม่สำเร็จ กรุณาลองอีกครั้ง';
            return false;
          }

          _currentUser = _createUserModel(existingUser);
          notifyListeners();
          return true;
        } on FirebaseAuthException catch (signInError) {
          _errorMessage = switch (signInError.code) {
            'invalid-credential' || 'wrong-password' || 'user-not-found' =>
              'อีเมลนี้มีบัญชีแล้ว แต่รหัสผ่านไม่ตรง ลองเข้าสู่ระบบหรือกด “ลืมรหัสผ่าน?”',
            'network-request-failed' => 'เชื่อมต่ออินเทอร์เน็ตไม่ได้',
            _ => 'อีเมลนี้มีบัญชีแล้ว ลองเข้าสู่ระบบหรือกด “ลืมรหัสผ่าน?”',
          };
          return false;
        }
      }

      _errorMessage = switch (e.code) {
        'email-already-in-use' => 'อีเมลนี้มีบัญชีอยู่แล้ว',
        'invalid-email' => 'รูปแบบอีเมลไม่ถูกต้อง',
        'weak-password' => 'รหัสผ่านไม่ปลอดภัยพอ',
        'operation-not-allowed' => 'ยังไม่ได้เปิดสมัครด้วยอีเมลใน Firebase',
        'network-request-failed' => 'เชื่อมต่ออินเทอร์เน็ตไม่ได้',
        _ => 'สร้างบัญชีไม่สำเร็จ กรุณาลองอีกครั้ง',
      };
      return false;
    } catch (e) {
      debugPrint('Create account failed: $e');
      _errorMessage = 'เกิดข้อผิดพลาดขณะสร้างบัญชี';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    _errorMessage = null;
    ++_authStateRevision;

    if (_auth == null) {
      _currentUser = null;
      notifyListeners();
      return true;
    }

    _isLoading = true;
    _currentUser = null;
    notifyListeners();
    try {
      await _auth!.signOut();
      try {
        await GoogleSignIn.instance.signOut();
      } catch (e) {
        debugPrint('Google sign-out cleanup failed: $e');
      }
      _currentUser = null;
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase logout error: ${e.code}');
      final remainingUser = _auth!.currentUser;
      _currentUser = remainingUser == null
          ? null
          : _createUserModel(remainingUser);
      _errorMessage = 'ออกจากระบบไม่สำเร็จ กรุณาลองอีกครั้ง';
      return false;
    } catch (e) {
      debugPrint('Logout failed: $e');
      final remainingUser = _auth!.currentUser;
      _currentUser = remainingUser == null
          ? null
          : _createUserModel(remainingUser);
      _errorMessage = 'เกิดข้อผิดพลาดขณะออกจากระบบ';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
