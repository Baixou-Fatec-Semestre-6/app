import '../../../../core/network/api_client.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<String> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      body: {
        'email': email,
        'password': password,
        'password_confirmation': password,
        if (name != null && name.isNotEmpty) 'name': name,
      },
    );

    return response['message'] ?? 'Conta criada com sucesso. Verifique seu e-mail.';
  }

  @override
  Future<void> activateAccount({
    required String email,
    required String code,
  }) async {
    await _apiClient.post(
      '/auth/activate',
      body: {
        'email': email,
        'code': code,
      },
    );
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    final token = response['token'] as String;
    final userData = response['data'] as Map<String, dynamic>;
    final user = User.fromJson(userData);

    // Save token and user data locally
    await AuthStorage.saveToken(token);
    await AuthStorage.saveUserData(user.toJson());

    return user;
  }

  @override
  Future<User?> getMe() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) return null;

    try {
      final response = await _apiClient.get(
        '/auth/me',
        requiresAuth: true,
      );

      final userData = response['data'] as Map<String, dynamic>;
      final user = User.fromJson(userData);
      await AuthStorage.saveUserData(user.toJson());
      return user;
    } catch (_) {
      // Token expired or invalid
      await AuthStorage.clearAll();
      return null;
    }
  }

  @override
  Future<void> forgotPassword({
    required String email,
  }) async {
    await _apiClient.post(
      '/auth/forgot-password',
      body: {
        'email': email,
      },
    );
  }

  @override
  Future<String> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final response = await _apiClient.post(
      '/auth/verify-reset-code',
      body: {
        'email': email,
        'code': code,
      },
    );

    return response['reset_token'] as String;
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _apiClient.post(
      '/auth/reset-password',
      body: {
        'reset_token': resetToken,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post(
        '/auth/logout',
        requiresAuth: true,
      );
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      await AuthStorage.clearAll();
    }
  }
}
