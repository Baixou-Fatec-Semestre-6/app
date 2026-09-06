import 'package:flutter/material.dart';
import '../../../../core/config/env_config.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthRepository _repository;

  User? _currentUser;
  bool _isLoading = false;
  bool _isCheckingAutoLogin = true;
  String? _errorMessage;
  String? _successMessage;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isCheckingAutoLogin => _isCheckingAutoLogin;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  AuthNotifier({AuthRepository? repository})
      : _repository = repository ?? AuthRepositoryImpl() {
    tryAutoLogin();
  }

  /// Attempts to automatically log in the user on app startup if a valid token is stored
  Future<void> tryAutoLogin() async {
    _isCheckingAutoLogin = true;
    notifyListeners();

    if (EnvConfig.enableMockData) {
      _isCheckingAutoLogin = false;
      notifyListeners();
      return;
    }

    try {
      final user = await _repository.getMe();
      _currentUser = user;
    } catch (_) {
      _currentUser = null;
    } finally {
      _isCheckingAutoLogin = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    if (EnvConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (email.contains('@') && password.length >= 6) {
        _currentUser = User(
          id: 1,
          email: email,
          name: email.split('@')[0],
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Credenciais inválidas.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    try {
      final user = await _repository.login(email: email, password: password);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, {String? name}) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    if (EnvConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      _isLoading = false;
      _successMessage = 'Conta criada com sucesso! Digite o código de 4 dígitos.';
      notifyListeners();
      return true;
    }

    try {
      final message = await _repository.register(
        email: email,
        password: password,
        name: name,
      );
      _successMessage = message;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> activateAccount(String email, String code) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    if (EnvConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      _isLoading = false;
      _successMessage = 'Conta ativada com sucesso!';
      notifyListeners();
      return true;
    }

    try {
      await _repository.activateAccount(email: email, code: code);
      _successMessage = 'Conta ativada com sucesso!';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    if (EnvConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      _isLoading = false;
      _successMessage = 'Código enviado para seu e-mail.';
      notifyListeners();
      return true;
    }

    try {
      await _repository.forgotPassword(email: email);
      _successMessage = 'Se a conta existir, um código foi enviado para seu e-mail.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> verifyResetCode(String email, String code) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    if (EnvConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      _isLoading = false;
      notifyListeners();
      return 'mock_reset_token';
    }

    try {
      final resetToken = await _repository.verifyResetCode(
        email: email,
        code: code,
      );
      _isLoading = false;
      notifyListeners();
      return resetToken;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> resetPassword(String resetToken, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    if (EnvConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      _isLoading = false;
      _successMessage = 'Senha redefinida com sucesso!';
      notifyListeners();
      return true;
    }

    try {
      await _repository.resetPassword(
        resetToken: resetToken,
        password: password,
        passwordConfirmation: password,
      );
      _successMessage = 'Senha redefinida com sucesso! Faça login.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    if (!EnvConfig.enableMockData) {
      await _repository.logout();
    }

    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }
}
