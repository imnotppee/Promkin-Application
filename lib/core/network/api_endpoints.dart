/// Centralized API Endpoints for REST API and AI Services
class ApiEndpoints {
  static const String _backendOverride = String.fromEnvironment(
    'BACKEND_BASE_URL',
  );

  // Hosted Express backend. Local development can override this at build time:
  // --dart-define=BACKEND_BASE_URL=http://10.0.2.2:5000/api
  static String get localBackendBase {
    if (_backendOverride.trim().isNotEmpty) return _backendOverride.trim();
    return 'https://promkin-api.onrender.com/api';
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
