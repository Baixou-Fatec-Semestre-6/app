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

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _alertPriceController = TextEditingController();
  final _alertFormKey = GlobalKey<FormState>();
  String _selectedTimeRange = '30d'; // '30d' | '90d' | '1y'
  double? _targetPriceValue;
  bool _notifyApp = true;
  bool _notifyEmail = true;

  @override
  void dispose() {
    _alertPriceController.dispose();
    super.dispose();
  }

  void _addAlert(ProductsNotifier notifier, Product product) {
    if (!_alertFormKey.currentState!.validate()) return;
    final price =
        double.tryParse(_alertPriceController.text.trim()) ?? _targetPriceValue;
    if (price != null) {
      if (!_notifyApp && !_notifyEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Selecione ao menos um canal para ser avisado (App ou E-mail).',
            ),
            backgroundColor: AppTheme.statusPending,
          ),
        );
        return;
      }
      notifier.createAlert(product.id, price);

      final channels = <String>[];
      if (_notifyApp) channels.add('Notificação no App');
      if (_notifyEmail) channels.add('E-mail');
      final channelsText = channels.join(' e ');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Alerta de R\$ ${price.toStringAsFixed(2)} criado! Avisaremos por $channelsText.',
          ),
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
        content: Text(
          'Deseja realmente remover "${product.title ?? product.url}" dos produtos monitorados?',
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusFailed,
            ),
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
    final productIndex = productsNotifier.products.indexWhere(
      (p) => p.id == widget.productId,
    );
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
            icon: const Icon(
              Icons.delete_outline,
              color: AppTheme.statusFailed,
            ),
            tooltip: 'Parar de rastrear',
            onPressed: () => _stopTracking(productsNotifier, product),
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobileBody: _buildMobileLayout(
          productsNotifier,
          product,
          history,
          alerts,
        ),
        desktopBody: _buildDesktopLayout(
          productsNotifier,
          product,
          history,
          alerts,
        ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Histórico de Preços',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildTimeRangeSelector(),
            ],
          ),
          const SizedBox(height: 12),
          PriceHistoryChart(
            history: history.cast(),
            timeRange: _selectedTimeRange,
          ),
          const SizedBox(height: 20),
          _buildStoreComparisonTable(product),
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
          // Left Column: Product Info & Store Comparison Table
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildInfoPanel(notifier, product),
                  const SizedBox(height: 20),
                  _buildStoreComparisonTable(product),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Right Column: Price History Chart with time range & Alerts management
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Histórico de Preços',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildTimeRangeSelector(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PriceHistoryChart(
                    history: history.cast(),
                    timeRange: _selectedTimeRange,
                  ),
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
                child:
                    product.status == ProductStatus.scraped &&
                        product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.image_not_supported_outlined,
                              size: 64,
                              color: AppTheme.textSecondary,
                            ),
                      )
                    : const Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: AppTheme.textSecondary,
                      ),
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
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
            if (product.status == ProductStatus.scraped &&
                product.currentPrice != null) ...[
              const Text(
                'Preço Atual',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'R\$ ${product.currentPrice!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.statusScraped,
                ),
              ),
            ],

            // Failure reason
            if (product.status == ProductStatus.failed &&
                product.lastErrorReason != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.statusFailed.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppTheme.statusFailed.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppTheme.statusFailed,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Falha no scraper: ${_getFriendlyError(product.lastErrorReason!)}',
                        style: const TextStyle(
                          color: AppTheme.statusFailed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Links / Actions
            const Text(
              'Link do Produto',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              product.url,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),

            // Simulate Actions (Testing helpers)
            if (product.status == ProductStatus.scraped) ...[
              OutlinedButton.icon(
                icon: const Icon(
                  Icons.offline_bolt_outlined,
                  color: AppTheme.primaryLight,
                ),
                label: const Text('Simular Queda de Preço'),
                onPressed: () {
                  final notificationsNotifier =
                      Provider.of<NotificationsNotifier>(
                        context,
                        listen: false,
                      );
                  notifier.simulatePriceDrop(product.id, notificationsNotifier);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Queda simulada com sucesso! Verifique notificações.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection(
    ProductsNotifier notifier,
    Product product,
    List alerts,
  ) {
    if (product.status == ProductStatus.scraped &&
        product.currentPrice != null) {
      _targetPriceValue ??= (product.currentPrice! * 0.9).roundToDouble();
      if (_alertPriceController.text.isEmpty) {
        _alertPriceController.text = _targetPriceValue!.toStringAsFixed(2);
      }
    }

    final currentPrice = product.currentPrice ?? 100.0;
    final minSlider = (currentPrice * 0.4).roundToDouble().clamp(
      10.0,
      currentPrice,
    );
    final maxSlider = (currentPrice * 1.1).roundToDouble();
    final sliderVal = (_targetPriceValue ?? currentPrice * 0.9).clamp(
      minSlider,
      maxSlider,
    );

    return Card(
      color: AppTheme.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: AppTheme.primaryLight,
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  'Configurar Alerta de Preço',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Alert Setting Form
            if (product.status == ProductStatus.scraped &&
                product.currentPrice != null) ...[
              Form(
                key: _alertFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Label: Quanto Pagar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Quanto Pagar (Preço Alvo):',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          'R\$ ${sliderVal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.statusScraped,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppTheme.primary,
                        inactiveTrackColor: AppTheme.border,
                        thumbColor: AppTheme.primaryLight,
                        overlayColor: AppTheme.primary.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: sliderVal,
                        min: minSlider,
                        max: maxSlider,
                        divisions: (maxSlider - minSlider) > 0
                            ? (maxSlider - minSlider).toInt()
                            : 10,
                        label: 'R\$ ${sliderVal.toStringAsFixed(0)}',
                        onChanged: (val) {
                          setState(() {
                            _targetPriceValue = val;
                            _alertPriceController.text = val.toStringAsFixed(2);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Direct input field
                    TextFormField(
                      controller: _alertPriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Ou digite o valor desejado (R\$)',
                        hintText: 'Ex: 450.00',
                        prefixText: 'R\$ ',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed != null) {
                          setState(() {
                            _targetPriceValue = parsed;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite um valor';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Valor inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notification Channel Selector ("Como Avisar")
                    const Text(
                      'Como Avisar:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FilterChip(
                          avatar: Icon(
                            Icons.smartphone,
                            size: 16,
                            color: _notifyApp
                                ? AppTheme.onBrand
                                : AppTheme.textSecondary,
                          ),
                          label: const Text('Notificação no App'),
                          selected: _notifyApp,
                          selectedColor: AppTheme.primary,
                          onSelected: (val) => setState(() => _notifyApp = val),
                        ),
                        const SizedBox(width: 10),
                        FilterChip(
                          avatar: Icon(
                            Icons.email_outlined,
                            size: 16,
                            color: _notifyEmail
                                ? AppTheme.onBrand
                                : AppTheme.textSecondary,
                          ),
                          label: const Text('E-mail'),
                          selected: _notifyEmail,
                          selectedColor: AppTheme.primary,
                          onSelected: (val) =>
                              setState(() => _notifyEmail = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.notifications_active, size: 18),
                      label: const Text('Criar Alerta de Preço'),
                      onPressed: () => _addAlert(notifier, product),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              const Text(
                'Os alertas de preço só podem ser configurados quando o produto for raspado com sucesso.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 10),
            ],

            const Divider(color: AppTheme.border),
            const SizedBox(height: 12),
            const Text(
              'Alertas Ativos neste Produto',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Active Alerts List
            if (alerts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Nenhum alerta configurado.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alerts.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: AppTheme.border),
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.notifications_active,
                            color: AppTheme.statusPending,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meta: R\$ ${alert.targetPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  if (_notifyApp) ...[
                                    const Icon(
                                      Icons.smartphone,
                                      size: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'App',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  if (_notifyEmail) ...[
                                    const Icon(
                                      Icons.email_outlined,
                                      size: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'E-mail',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppTheme.statusFailed,
                          size: 20,
                        ),
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
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStoreBadge(String storeName) {
    Color badgeColor;
    Color textColor = AppTheme.textTertiary;

    switch (storeName.toLowerCase()) {
      case 'amazon':
        badgeColor = AppTheme.brand;
        textColor = AppTheme.onBrand;
        break;
      case 'mercado livre':
        badgeColor = AppTheme.brand;
        textColor = AppTheme.onBrand;
        break;
      case 'magalu':
        badgeColor = AppTheme.bgSurfaceHigh;
        break;
      case 'kabum':
        badgeColor = AppTheme.bgSurfaceHigh;
        break;
      case 'shopee':
        badgeColor = AppTheme.bgSurfaceHigh;
        break;
      case 'americanas':
        badgeColor = AppTheme.bgSurfaceHigh;
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
    if (reason == 'blocked') {
      return 'O site bloqueou o acesso (CAPTCHA / Bloqueio).';
    }

    if (reason == 'timeout') {
      return 'Tempo limite esgotado ao acessar o servidor.';
    }

    if (reason == 'not_found') {
      return 'Produto não encontrado na loja (Erro 404).';
    }

    return 'Erro desconhecido.';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeButton('30d', '30 dias'),
          _buildTimeButton('90d', '90 dias'),
          _buildTimeButton('1y', '1 ano'),
        ],
      ),
    );
  }

  Widget _buildTimeButton(String value, String label) {
    final isSelected = _selectedTimeRange == value;
    return InkWell(
      onTap: () => setState(() => _selectedTimeRange = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppTheme.onBrand : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStoreComparisonTable(Product product) {
    if (product.currentPrice == null) return const SizedBox.shrink();

    final base = product.currentPrice!;
    final stats = [
      _StorePriceStat(
        storeName: product.store,
        minPrice: base,
        maxPrice: (base * 1.08).roundToDouble(),
        avgPrice: (base * 1.04).roundToDouble(),
        isCurrentStore: true,
      ),
      _StorePriceStat(
        storeName: _getSecondaryStore(product.store),
        minPrice: (base * 0.96).roundToDouble(),
        maxPrice: (base * 1.12).roundToDouble(),
        avgPrice: (base * 1.05).roundToDouble(),
      ),
      _StorePriceStat(
        storeName: _getTertiaryStore(product.store),
        minPrice: (base * 0.98).roundToDouble(),
        maxPrice: (base * 1.15).roundToDouble(),
        avgPrice: (base * 1.07).roundToDouble(),
      ),
    ];

    return Card(
      color: AppTheme.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      color: AppTheme.primaryLight,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Comparativo entre Lojas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '30 dias',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 38,
                dataRowMinHeight: 46,
                horizontalMargin: 8,
                columnSpacing: 20,
                headingRowColor: WidgetStateProperty.all(AppTheme.darkBg),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Loja',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Mínimo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Máximo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Média',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                rows: stats.map((stat) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStoreBadge(stat.storeName),
                            if (stat.isCurrentStore) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.check_circle,
                                size: 14,
                                color: AppTheme.statusScraped,
                              ),
                            ],
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          'R\$ ${stat.minPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.statusScraped,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          'R\$ ${stat.maxPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppTheme.statusFailed,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          'R\$ ${stat.avgPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSecondaryStore(String currentStore) {
    if (currentStore.toLowerCase() != 'amazon') return 'Amazon';
    return 'Mercado Livre';
  }

  String _getTertiaryStore(String currentStore) {
    if (currentStore.toLowerCase() != 'magalu') return 'Magalu';
    return 'Kabum';
  }
}

class _StorePriceStat {
  final String storeName;
  final double minPrice;
  final double maxPrice;
  final double avgPrice;
  final bool isCurrentStore;

  _StorePriceStat({
    required this.storeName,
    required this.minPrice,
    required this.maxPrice,
    required this.avgPrice,
    this.isCurrentStore = false,
  });
}
