import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baixou/core/theme/app_theme.dart';
import 'package:baixou/core/utils/responsive_layout.dart';
import 'package:baixou/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:baixou/features/products/presentation/controllers/products_notifier.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _emailAlerts = true;
  bool _pushNotifications = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    _nameController.text = authNotifier.currentUser?.name ?? 'Gabriel';
    _emailController.text = authNotifier.currentUser?.email ?? 'gabriel@email.com';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil atualizado com sucesso!'),
        backgroundColor: AppTheme.statusScraped,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context);
    final productsNotifier = Provider.of<ProductsNotifier>(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    final content = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 40.0,
        vertical: 24.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileHeader(isMobile),
          const SizedBox(height: 24),
          _buildStatsRow(productsNotifier, isMobile),
          const SizedBox(height: 24),
          _buildAccountInfoCard(),
          const SizedBox(height: 24),
          _buildSettingsCard(),
          const SizedBox(height: 32),
          _buildDangerZone(authNotifier),
        ],
      ),
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: SafeArea(child: content),
      );
    } else {
      return Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: content,
          ),
        ),
      );
    }
  }

  Widget _buildProfileHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isMobile ? 36 : 48,
            backgroundColor: AppTheme.primary,
            child: Text(
              _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'G',
              style: TextStyle(
                fontSize: isMobile ? 32 : 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _emailController.text,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
                  ),
                  child: const Text(
                    'Membro Premium',
                    style: TextStyle(
                      color: AppTheme.primaryLight,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ProductsNotifier notifier, bool isMobile) {
    final stats = [
      _StatItem(
        icon: Icons.shopping_bag_outlined,
        value: '${notifier.products.length}',
        label: 'Produtos Monitorados',
        color: AppTheme.primaryLight,
      ),
      _StatItem(
        icon: Icons.notifications_active_outlined,
        value: '${notifier.alerts.length}',
        label: 'Alertas Configurados',
        color: AppTheme.statusPending,
      ),
    ];

    if (isMobile) {
      return Column(
        children: stats.map((s) => _buildStatCard(s, true)).toList(),
      );
    }

    return Row(
      children: stats.map((s) => Expanded(child: _buildStatCard(s, false))).toList(),
    );
  }

  Widget _buildStatCard(_StatItem stat, bool isMobile) {
    return Card(
      margin: isMobile ? const EdgeInsets.only(bottom: 12) : const EdgeInsets.symmetric(horizontal: 6),
      color: AppTheme.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(stat.icon, color: stat.color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat.label,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Informações Pessoais',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton.icon(
                icon: Icon(_isEditing ? Icons.check : Icons.edit, size: 18),
                label: Text(_isEditing ? 'Salvar' : 'Editar'),
                onPressed: _isEditing ? _saveProfile : () => setState(() => _isEditing = true),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            enabled: _isEditing,
            decoration: const InputDecoration(
              labelText: 'Nome Completo',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            enabled: _isEditing,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configurações de Alertas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Notificações no Dispositivo', style: TextStyle(color: AppTheme.textPrimary)),
            subtitle: const Text('Receba avisos instantâneos quando um preço cair', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            value: _pushNotifications,
            onChanged: (val) => setState(() => _pushNotifications = val),
            activeColor: AppTheme.primary,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(color: AppTheme.border),
          SwitchListTile(
            title: const Text('Alertas por E-mail', style: TextStyle(color: AppTheme.textPrimary)),
            subtitle: const Text('Enviaremos relatórios detalhados com links de compra', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            value: _emailAlerts,
            onChanged: (val) => setState(() => _emailAlerts = val),
            activeColor: AppTheme.primary,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(AuthNotifier authNotifier) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.statusFailed.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Zona de Perigo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.statusFailed,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'A exclusão da conta é permanente e removerá todos os seus alertas salvos e produtos monitorados.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.statusFailed,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppTheme.darkCard,
                      title: const Text('Excluir Conta?'),
                      content: const Text('Esta ação não pode ser desfeita. Todos os seus dados serão apagados permanentemente.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusFailed),
                          onPressed: () {
                            Navigator.pop(context);
                            authNotifier.logout();
                          },
                          child: const Text('Excluir Definitivamente'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Excluir Conta'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}
