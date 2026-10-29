import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Centralized API Endpoints for REST API and AI Services
class ApiEndpoints {
  static const String _backendOverride = String.fromEnvironment(
    'BACKEND_BASE_URL',
  );

  // Local Express Backend server
  // Physical Android devices reach the development backend over the same Wi-Fi.
  // Use BACKEND_BASE_URL=http://10.0.2.2:5000/api for Android Emulator builds.
  // On iOS Simulator or Web/Desktop, localhost is 127.0.0.1 / localhost.
  static String get localBackendBase {
    if (_backendOverride.trim().isNotEmpty) return _backendOverride.trim();
    if (kIsWeb) return 'http://localhost:5000/api';
    if (Platform.isAndroid) return 'http://10.111.2.65:5000/api';
    return 'http://localhost:5000/api';
  }

  // REST API Routes (Node.js / Express backend)
  static String get meals => '$localBackendBase/meals';
  static String get recipes => '$localBackendBase/recipes';
  static String get aiRecommend => '$localBackendBase/ai/recommend';
  static String get authLogin => '$localBackendBase/auth/login';
  static String get authRegister => '$localBackendBase/auth/register';

  // Gemini AI Base URL
  static const String geminiApiBase =
      'https://generativelanguage.googleapis.com/v1beta';

  // Third-party nutrition / recipe database
  static const String foodApiBase = 'https://api.spoonacular.com/recipes';

  // Internal Mock base
  static const String mockApiBase = 'https://promkin-api.mock.internal';
}
