import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baixou/core/theme/app_theme.dart';
import 'package:baixou/core/utils/responsive_layout.dart';
import 'package:baixou/features/products/domain/entities/product.dart';
import 'package:baixou/features/products/presentation/controllers/products_notifier.dart';
import 'package:baixou/features/products/presentation/widgets/price_history_chart.dart';
import 'package:baixou/features/notifications/presentation/controllers/notifications_notifier.dart';

class ProductDetailsScreen extends StatefulWidget {
  final int productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _alertPriceController = TextEditingController();
  final _alertFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _alertPriceController.dispose();
    super.dispose();
  }

  void _addAlert(ProductsNotifier notifier, Product product) {
    if (!_alertFormKey.currentState!.validate()) return;
    final price = double.tryParse(_alertPriceController.text.trim());
    if (price != null) {
      notifier.createAlert(product.id, price);
      _alertPriceController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alerta criado! Notificaremos quando baixar de R\$ ${price.toStringAsFixed(2)}.'),
          backgroundColor: AppTheme.statusScraped,
        ),
      );
    }
  }

  void _stopTracking(ProductsNotifier notifier, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Parar de Rastrear?'),
        content: Text('Deseja realmente remover "${product.title ?? product.url}" dos produtos monitorados?'),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusFailed),
            child: const Text('Remover'),
            onPressed: () {
              notifier.stopTracking(product.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to dashboard
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Produto removido!')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsNotifier = Provider.of<ProductsNotifier>(context);

    // Find the product (it might have been deleted, so handle null safely)
    final productIndex = productsNotifier.products.indexWhere((p) => p.id == widget.productId);
    if (productIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes')),
        body: const Center(child: Text('Produto não encontrado.')),
      );
    }

    final product = productsNotifier.products[productIndex];
    final history = productsNotifier.getPriceHistoryForProduct(product.id);
    final alerts = productsNotifier.getAlertsForProduct(product.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.statusFailed),
            tooltip: 'Parar de rastrear',
            onPressed: () => _stopTracking(productsNotifier, product),
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobileBody: _buildMobileLayout(productsNotifier, product, history, alerts),
        desktopBody: _buildDesktopLayout(productsNotifier, product, history, alerts),
      ),
    );
  }

  Widget _buildMobileLayout(
    ProductsNotifier notifier,
    Product product,
    List history,
    List alerts,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoPanel(notifier, product),
          const SizedBox(height: 20),
          const Text('Histórico de Preços', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          PriceHistoryChart(history: history.cast()),
          const SizedBox(height: 20),
          _buildAlertsSection(notifier, product, alerts.cast()),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    ProductsNotifier notifier,
    Product product,
    List history,
    List alerts,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Product Info & Actions
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: _buildInfoPanel(notifier, product),
            ),
          ),
          const SizedBox(width: 24),
          // Right Column: Price History Chart & Alerts management
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Histórico de Preços', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  PriceHistoryChart(history: history.cast()),
                  const SizedBox(height: 24),
                  _buildAlertsSection(notifier, product, alerts.cast()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(ProductsNotifier notifier, Product product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.darkBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: product.status == ProductStatus.scraped && product.imageUrl != null
                    ? Image.network(product.imageUrl!, fit: BoxFit.contain)
                    : const Icon(Icons.shopping_bag_outlined, size: 64, color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 20),

            // Status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildStatusLabel(product),
                    const SizedBox(width: 8),
                    _buildStoreBadge(product.store),
                  ],
                ),
                if (product.lastScrapedAt != null)
                  Text(
                    'Atualizado: ${_formatTime(product.lastScrapedAt!)}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              product.title ?? 'Aguardando raspagem de dados...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Current Price
            if (product.status == ProductStatus.scraped && product.currentPrice != null) ...[
              const Text('Preço Atual', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                'R\$ ${product.currentPrice!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.statusScraped),
              ),
            ],

            // Failure reason
            if (product.status == ProductStatus.failed && product.lastErrorReason != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.statusFailed.withOpacity(0.1),
                  border: Border.all(color: AppTheme.statusFailed.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.statusFailed),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Falha no scraper: ${_getFriendlyError(product.lastErrorReason!)}',
                        style: const TextStyle(color: AppTheme.statusFailed, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Links / Actions
            const Text('Link do Produto', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              product.url,
              style: const TextStyle(fontSize: 12, color: AppTheme.primaryLight),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),

            // Simulate Actions (Testing helpers)
            if (product.status == ProductStatus.scraped) ...[
              OutlinedButton.icon(
                icon: const Icon(Icons.offline_bolt_outlined, color: AppTheme.primaryLight),
                label: const Text('Simular Queda de Preço'),
                onPressed: () {
                  final notificationsNotifier = Provider.of<NotificationsNotifier>(context, listen: false);
                  notifier.simulatePriceDrop(product.id, notificationsNotifier);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Queda simulada com sucesso! Verifique notificações.')),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection(ProductsNotifier notifier, Product product, List alerts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Alertas de Preço',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Alert Setting Form
            if (product.status == ProductStatus.scraped) ...[
              Form(
                key: _alertFormKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _alertPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: 'Preço alvo (Ex: 450.00)',
                          prefixText: 'R\$ ',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Digite um valor';
                          if (double.tryParse(value) == null) return 'Valor inválido';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => _addAlert(notifier, product),
                      child: const Text('Criar Alerta'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ] else ...[
              const Text(
                'Os alertas de preço só podem ser configurados quando o produto for raspado com sucesso.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 10),
            ],

            // Active Alerts List
            if (alerts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Nenhum alerta de preço ativo.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alerts.length,
                separatorBuilder: (context, index) => const Divider(color: AppTheme.border),
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active_outlined, color: AppTheme.statusPending),
                          const SizedBox(width: 12),
                          Text(
                            'Alerta definido em R\$ ${alert.targetPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppTheme.statusFailed, size: 20),
                        onPressed: () => notifier.deleteAlert(alert.id),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLabel(Product product) {
    Color color;
    String text;

    switch (product.status) {
      case ProductStatus.pending:
        color = AppTheme.statusPending;
        text = 'PENDING / SCRAPING';
        break;
      case ProductStatus.scraped:
        color = AppTheme.statusScraped;
        text = 'MONITORANDO';
        break;
      case ProductStatus.failed:
        color = AppTheme.statusFailed;
        text = 'ERRO';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildStoreBadge(String storeName) {
    Color badgeColor;
    Color textColor = Colors.white;

    switch (storeName.toLowerCase()) {
      case 'amazon':
        badgeColor = const Color(0xFFFF9900);
        textColor = Colors.black87;
        break;
      case 'mercado livre':
        badgeColor = const Color(0xFFFFF159);
        textColor = Colors.black87;
        break;
      case 'magalu':
        badgeColor = const Color(0xFF0086FF);
        break;
      case 'kabum':
        badgeColor = const Color(0xFF0060EE);
        break;
      case 'shopee':
        badgeColor = const Color(0xFFEE4D2D);
        break;
      case 'americanas':
        badgeColor = const Color(0xFFE60014);
        break;
      default:
        badgeColor = AppTheme.border;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        storeName,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getFriendlyError(String reason) {
    if (reason == 'blocked') return 'O site bloqueou o acesso (CAPTCHA / Bloqueio).';
    if (reason == 'timeout') return 'Tempo limite esgotado ao acessar o servidor.';
    if (reason == 'not_found') return 'Produto não encontrado na loja (Erro 404).';
    return 'Erro desconhecido.';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
