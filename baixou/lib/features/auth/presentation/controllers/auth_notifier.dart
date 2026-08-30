import 'package:flutter/material.dart';
import 'package:baixou/features/auth/domain/entities/user.dart';

class AuthNotifier extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate API network delay
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
      _errorMessage = 'Credenciais inválidas. O email deve ser válido e a senha ter no mínimo 6 caracteres.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate API network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    if (email.contains('@') && password.length >= 6) {
      _currentUser = User(
        id: 1,
        email: email,
        name: email.split('@')[0],
        createdAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Erro ao cadastrar. Insira um email válido e senha com 6+ caracteres.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> recoverPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));

    if (email.contains('@')) {
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Por favor, insira um endereço de email válido.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
