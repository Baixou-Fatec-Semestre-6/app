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

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit(AuthNotifier authNotifier) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final success = await authNotifier.recoverPassword(email);

    if (success && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.darkCard,
          title: const Text('Email Enviado!'),
          content: Text(
            'Um código foi enviado para $email. Verifique sua caixa de entrada e spam.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to login screen
              },
              child: const Text('Voltar para o Login'),
            ),
          ],
        ),
      );
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
          // Icon branding
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
          const Text(
            'Esqueceu sua senha?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Digite seu endereço de email cadastrado e um código para recuperar seu acesso.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),

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
          const SizedBox(height: 12),

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
                : const Text('Enviar código'),
          ),
          const SizedBox(height: 20),

          // Go back button
          TextButton(
            onPressed: () {
              authNotifier.clearError();
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
}
