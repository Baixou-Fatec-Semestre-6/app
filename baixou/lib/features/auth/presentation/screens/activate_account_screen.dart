import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../controllers/auth_notifier.dart';

class ActivateAccountScreen extends StatefulWidget {
  final String email;

  const ActivateAccountScreen({super.key, required this.email});

  @override
  State<ActivateAccountScreen> createState() => _ActivateAccountScreenState();
}

class _ActivateAccountScreenState extends State<ActivateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit(AuthNotifier authNotifier) async {
    if (!_formKey.currentState!.validate()) return;

    final code = _codeController.text.trim();
    final success = await authNotifier.activateAccount(widget.email, code);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta ativada com sucesso! Faça login para continuar.'),
          backgroundColor: AppTheme.statusScraped,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ativação de Conta'),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.mark_email_read_outlined,
            size: 64,
            color: AppTheme.primaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Verifique seu E-mail',
            textAlign: TextAlign.center,
            style: GoogleFonts.barlowCondensed(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enviamos um código de ativação de 4 dígitos para:\n${widget.email}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),

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
          const SizedBox(height: 24),

          if (authNotifier.errorMessage != null) ...[
            Text(
              authNotifier.errorMessage!,
              style: const TextStyle(color: AppTheme.statusFailed, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],

          ElevatedButton(
            onPressed: authNotifier.isLoading ? null : () => _submit(authNotifier),
            child: authNotifier.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Ativar Conta'),
          ),
        ],
      ),
    );
  }
}
