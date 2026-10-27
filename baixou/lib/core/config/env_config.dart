import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Class responsible for providing typed access to environment variables loaded via flutter_dotenv.
class EnvConfig {
  /// Base API URL for the Core Laravel Backend
  static String get apiBaseUrl {
    const buildTimeUrl = String.fromEnvironment('API_BASE_URL');
    if (buildTimeUrl.isNotEmpty) return buildTimeUrl;
    return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api';
  }

  /// Application Name
  static String get appName =>
      dotenv.env['APP_NAME'] ?? 'BAIXOU - Price Tracker';

  /// Current Environment Name ('development', 'staging', 'production')
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';

  /// Timeout duration for HTTP requests in milliseconds
  static int get apiTimeoutMs =>
      int.tryParse(dotenv.env['API_TIMEOUT_MS'] ?? '10000') ?? 10000;

  /// Duration object for HTTP timeouts
  static Duration get apiTimeout => Duration(milliseconds: apiTimeoutMs);

  /// Toggle whether to use local mock data instead of real API calls
  static bool get enableMockData =>
      (dotenv.env['ENABLE_MOCK_DATA'] ?? 'false').toLowerCase() == 'true';

  /// Toggle verbose debug logs for network calls
  static bool get enableDebugLogs =>
      (dotenv.env['ENABLE_DEBUG_LOGS'] ?? 'true').toLowerCase() == 'true';

  /// Código exibido somente em builds de demonstração com API simulada.
  static String get demoAuthCode {
    const buildTimeCode = String.fromEnvironment('DEMO_AUTH_CODE');
    if (buildTimeCode.isNotEmpty) return buildTimeCode;
    return dotenv.env['DEMO_AUTH_CODE'] ?? '';
  }

  static bool get showDemoAuthCode => demoAuthCode.isNotEmpty;

  /// Helper boolean to check if app is running in production environment
  static bool get isProduction => appEnv.toLowerCase() == 'production';
}
