import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baixou/core/theme/app_theme.dart';
import 'package:baixou/core/utils/responsive_layout.dart';
import 'package:baixou/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:baixou/features/auth/presentation/screens/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(AuthNotifier authNotifier) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    bool success;

    if (_isLoginMode) {
      success = await authNotifier.login(email, password);
    } else {
      success = await authNotifier.register(email, password);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLoginMode
                ? 'Login realizado com sucesso!'
                : 'Cadastro realizado com sucesso!',
          ),
          backgroundColor: AppTheme.statusScraped,
        ),
      );
      // Navigation is handled automatically since state change triggers main.dart's screen switcher
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context);

    return Scaffold(
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
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
          // Logo & Branding
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primary, width: 3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'BAIXOU',
                style: TextStyle(
                  fontFamily: 'Barlow Condensed',
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isLoginMode
                ? 'Monitore os menores preços de produtos'
                : 'Crie sua conta para começar',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 40),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppTheme.textSecondary,
              ),
              hintText: 'exemplo@email.com',
            ),
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Insira um endereço de email válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha',
              prefixIcon: Icon(
                Icons.lock_outlined,
                color: AppTheme.textSecondary,
              ),
              hintText: 'Mínimo 6 caracteres',
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 6) {
                return 'A senha deve conter pelo menos 6 caracteres';
              }
              return null;
            },
          ),
          if (_isLoginMode)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  authNotifier.clearError();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Esqueceu sua senha?',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ),
            ),
          const SizedBox(height: 10),

          // Error Message Display
          if (authNotifier.errorMessage != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                authNotifier.errorMessage!,
                style: const TextStyle(
                  color: AppTheme.statusFailed,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Submit Button
          ElevatedButton(
            onPressed: authNotifier.isLoading
                ? null
                : () => _submit(authNotifier),
            child: authNotifier.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_isLoginMode ? 'Entrar' : 'Cadastrar'),
          ),
          const SizedBox(height: 20),

          // Switch Mode Button
          TextButton(
            onPressed: () {
              setState(() {
                _isLoginMode = !_isLoginMode;
              });
              authNotifier.clearError();
            },
            child: Text(
              _isLoginMode
                  ? 'Não tem uma conta? Cadastre-se'
                  : 'Já possui uma conta? Faça Login',
              style: const TextStyle(color: AppTheme.primaryLight),
            ),
          ),
        ],
      ),
    );
  }
}
