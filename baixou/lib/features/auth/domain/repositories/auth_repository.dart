import '../entities/user.dart';

abstract class AuthRepository {
  Future<String> register({
    required String email,
    required String password,
    String? name,
  });

  Future<void> activateAccount({
    required String email,
    required String code,
  });

  Future<User> login({
    required String email,
    required String password,
  });

  Future<User?> getMe();

  Future<void> forgotPassword({
    required String email,
  });

  Future<String> verifyResetCode({
    required String email,
    required String code,
  });

  Future<void> resetPassword({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  });

  Future<void> logout();
}
