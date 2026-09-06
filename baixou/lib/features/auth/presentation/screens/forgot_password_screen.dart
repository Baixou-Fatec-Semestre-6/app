import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baixou/core/theme/app_theme.dart';
import 'package:baixou/core/utils/responsive_layout.dart';
import '../controllers/auth_notifier.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

enum ResetStep { enterEmail, enterCode, newPassword }

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  ResetStep _currentStep = ResetStep.enterEmail;
  String? _resetToken;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(AuthNotifier authNotifier) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    if (_currentStep == ResetStep.enterEmail) {
      final success = await authNotifier.forgotPassword(email);
      if (success && mounted) {
        setState(() {
          _currentStep = ResetStep.enterCode;
        });
      }
    } else if (_currentStep == ResetStep.enterCode) {
      final code = _codeController.text.trim();
      final token = await authNotifier.verifyResetCode(email, code);
      if (token != null && mounted) {
        setState(() {
          _resetToken = token;
          _currentStep = ResetStep.newPassword;
        });
      }
    } else if (_currentStep == ResetStep.newPassword && _resetToken != null) {
      final newPassword = _passwordController.text.trim();
      final success = await authNotifier.resetPassword(_resetToken!, newPassword);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senha redefinida com sucesso! Faça login com a nova senha.'),
            backgroundColor: AppTheme.statusScraped,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            authNotifier.clearError();
            authNotifier.clearSuccess();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          mobileBody: _buildMobileLayout(authNotifier),
          desktopBody: _buildDesktopLayout(authNotifier),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(AuthNotifier authNotifier) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: _buildFormContent(authNotifier),
      ),
    );
  }

  Widget _buildDesktopLayout(AuthNotifier authNotifier) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        padding: const EdgeInsets.all(40.0),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: SingleChildScrollView(child: _buildFormContent(authNotifier)),
      ),
    );
  }

  Widget _buildFormContent(AuthNotifier authNotifier) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primary,
              child: Icon(
                Icons.lock_reset_outlined,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _getStepTitle(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getStepSubtitle(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),

          if (_currentStep == ResetStep.enterEmail) ...[
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary),
                hintText: 'exemplo@email.com',
              ),
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Insira um endereço de email válido';
                }
                return null;
              },
            ),
          ] else if (_currentStep == ResetStep.enterCode) ...[
            TextFormField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelText: 'Código de 4 dígitos',
                hintText: '1234',
                counterText: '',
              ),
              validator: (value) {
                if (value == null || value.trim().length != 4) {
                  return 'Insira o código de 4 dígitos';
                }
                return null;
              },
            ),
          ] else if (_currentStep == ResetStep.newPassword) ...[
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nova Senha',
                prefixIcon: Icon(Icons.lock_outlined, color: AppTheme.textSecondary),
                hintText: 'Mínimo 8 caracteres',
              ),
              validator: (value) {
                if (value == null || value.length < 8) {
                  return 'A senha deve conter pelo menos 8 caracteres';
                }
                return null;
              },
            ),
          ],

          const SizedBox(height: 16),

          if (authNotifier.errorMessage != null) ...[
            Text(
              authNotifier.errorMessage!,
              style: const TextStyle(color: AppTheme.statusFailed, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],

          if (authNotifier.successMessage != null) ...[
            Text(
              authNotifier.successMessage!,
              style: const TextStyle(color: AppTheme.statusScraped, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],

          ElevatedButton(
            onPressed: authNotifier.isLoading ? null : () => _submit(authNotifier),
            child: authNotifier.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(_getButtonLabel()),
          ),
          const SizedBox(height: 20),

          TextButton(
            onPressed: () {
              authNotifier.clearError();
              authNotifier.clearSuccess();
              Navigator.pop(context);
            },
            child: const Text(
              'Voltar para o Login',
              style: TextStyle(color: AppTheme.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case ResetStep.enterEmail:
        return 'Esqueceu sua senha?';
      case ResetStep.enterCode:
        return 'Digite o Código de 4 dígitos';
      case ResetStep.newPassword:
        return 'Defina a Nova Senha';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case ResetStep.enterEmail:
        return 'Digite seu e-mail para receber o código de recuperação.';
      case ResetStep.enterCode:
        return 'Enviamos o código para ${_emailController.text}.';
      case ResetStep.newPassword:
        return 'Escolha uma nova senha com no mínimo 8 caracteres.';
    }
  }

  String _getButtonLabel() {
    switch (_currentStep) {
      case ResetStep.enterEmail:
        return 'Enviar código';
      case ResetStep.enterCode:
        return 'Verificar código';
      case ResetStep.newPassword:
        return 'Redefinir Senha';
    }
  }
}
