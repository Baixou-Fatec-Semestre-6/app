import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> register({required String email, required String password});
  Future<User> login({required String email, required String password});
  Future<void> logout();
  Future<String> refreshToken();
  Future<void> recoverPassword({required String email});
}
