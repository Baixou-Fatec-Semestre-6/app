import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baixou/core/theme/app_theme.dart';
import 'package:baixou/features/products/domain/entities/product.dart';
import 'package:baixou/features/products/presentation/controllers/products_notifier.dart';
import 'package:baixou/features/products/presentation/screens/product_details_screen.dart';
import 'package:baixou/features/notifications/presentation/controllers/notifications_notifier.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final productsNotifier = Provider.of<ProductsNotifier>(context, listen: false);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(productId: product.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image / Visual Placeholder
              Expanded(
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.darkBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: product.status == ProductStatus.scraped && product.imageUrl != null
                              ? Image.network(
                                  product.imageUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported_outlined, size: 40, color: AppTheme.textSecondary),
                                )
                              : const Icon(Icons.shopping_bag_outlined, size: 48, color: AppTheme.textSecondary),
                        ),
                      ),
                      // Status Badge
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _buildStatusBadge(),
                      ),
                      // Store Badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _buildStoreBadge(product.store),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                _getTitleText(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // Price & Simulator Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price
                  product.status == ProductStatus.scraped && product.currentPrice != null
                      ? Text(
                          'R\$ ${product.currentPrice!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.statusScraped,
                          ),
                        )
                      : Text(
                          product.status == ProductStatus.pending ? 'Calculando...' : 'Indisponível',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),

                  // Testing drop price simulator
                  if (product.status == ProductStatus.scraped)
                    IconButton(
                      icon: const Icon(Icons.trending_down, color: AppTheme.primaryLight),
                      tooltip: 'Simular queda de preço (Para testes)',
                      onPressed: () {
                        final notificationsNotifier = Provider.of<NotificationsNotifier>(context, listen: false);
                        productsNotifier.simulatePriceDrop(product.id, notificationsNotifier);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Simulando queda de preço! Verifique notificações.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitleText() {
    switch (product.status) {
      case ProductStatus.pending:
        return 'Iniciando rastreamento...';
      case ProductStatus.failed:
        return 'Erro ao obter dados: ${product.url}';
      case ProductStatus.scraped:
        return product.title ?? 'Produto';
    }
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String label;
    Widget leading = const SizedBox.shrink();

    switch (product.status) {
      case ProductStatus.pending:
        badgeColor = AppTheme.statusPending;
        label = 'Pending';
        leading = const Padding(
          padding: EdgeInsets.only(right: 4.0),
          child: SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
            ),
          ),
        );
        break;
      case ProductStatus.scraped:
        badgeColor = AppTheme.statusScraped;
        label = 'Scraped';
        break;
      case ProductStatus.failed:
        badgeColor = AppTheme.statusFailed;
        label = 'Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
