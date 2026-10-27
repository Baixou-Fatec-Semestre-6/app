import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baixou/core/theme/app_theme.dart';
import 'package:baixou/features/products/domain/entities/product.dart';
import 'package:baixou/features/products/presentation/controllers/products_notifier.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  static Future<void> show(BuildContext context, {required bool isMobile}) {
    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppTheme.darkCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const SizedBox(height: 550, child: AddProductDialog()),
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (context) => const Dialog(
          backgroundColor: AppTheme.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          child: SizedBox(width: 600, height: 600, child: AddProductDialog()),
        ),
      );
    }
  }

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _searchController = TextEditingController();
  List<Product> _filteredCatalog = [];
  Product? _selectedProduct;
  bool _isSearching = false;
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Load initial catalog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSearch('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
    });

    final productsNotifier = Provider.of<ProductsNotifier>(
      context,
      listen: false,
    );
    final results = await productsNotifier.searchCatalog(query);

    if (mounted) {
      setState(() {
        _filteredCatalog = results;
        _isSearching = false;
      });
    }
  }

  void _submit() async {
    if (_selectedProduct == null) return;

    setState(() {
      _isLoading = true;
    });

    final productsNotifier = Provider.of<ProductsNotifier>(
      context,
      listen: false,
    );

    // Track product selected from base catalog
    await productsNotifier.trackNewProduct(_selectedProduct!);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"${_selectedProduct!.title}" enviado para a fila de monitoramento!',
          ),
          backgroundColor: AppTheme.statusPending,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pesquisar na Base (PostgreSQL)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // Search Input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nome do produto ou loja...',
              prefixIcon: const Icon(
                Icons.search,
                color: AppTheme.textSecondary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: _onSearchChanged,
          ),
        ),

        // Searching loader / Catalog list
        Expanded(
          child: _isSearching
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primary,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Consultando tabela produto...',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : _filteredCatalog.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  itemCount: _filteredCatalog.length,
                  itemBuilder: (context, index) {
                    final product = _filteredCatalog[index];
                    final isSelected = _selectedProduct?.id == product.id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      color: isSelected
                          ? AppTheme.primary.withValues(alpha: 0.08)
                          : AppTheme.darkCard,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            _selectedProduct = product;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Small Image
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.darkBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: product.imageUrl != null
                                      ? Image.network(
                                          product.imageUrl!,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.shopping_bag_outlined,
                                                    color:
                                                        AppTheme.textSecondary,
                                                  ),
                                        )
                                      : const Icon(
                                          Icons.shopping_bag_outlined,
                                          color: AppTheme.textSecondary,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'R\$ ${product.currentPrice?.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: AppTheme.statusScraped,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        _buildStoreBadge(product.store),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Action Button
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: _isLoading || _selectedProduct == null ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.onBrand,
                    ),
                  )
                : const Text('Rastrear Produto Selecionado'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              color: AppTheme.textSecondary,
              size: 48,
            ),
            SizedBox(height: 12),
            Text(
              'Nenhum produto encontrado nesta busca.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
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
}
