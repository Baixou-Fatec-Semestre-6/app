import '../../../../core/network/api_client.dart';
import '../../domain/entities/price_alert.dart';
import '../../domain/entities/price_history_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ApiClient _api;

  ProductsRepositoryImpl({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  List<Map<String, dynamic>> _rows(Map<String, dynamic> response) =>
      (response['data'] as List? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

  @override
  Future<List<Product>> getTrackedProducts() async {
    return _loadCatalog('/products/catalog?scope=tracked');
  }

  @override
  Future<List<Product>> searchProductsInCatalog(String query) async {
    return _loadCatalog(
      '/products/catalog?q=${Uri.encodeQueryComponent(query)}',
    );
  }

  Future<List<Product>> _loadCatalog(String path) async {
    final separator = path.contains('?') ? '&' : '?';
    final products = <Product>[];
    var page = 1;
    while (true) {
      final response = await _api.get('$path${separator}per_page=100&page=$page');
      products.addAll(_rows(response).map(Product.fromJson));
      final meta = response['meta'] as Map?;
      final lastPage = (meta?['last_page'] as num?)?.toInt() ?? page;
      if (page >= lastPage) break;
      page++;
    }
    return products;
  }

  @override
  Future<Product> trackNewProduct({required int baseProductId}) async {
    final response = await _api.post(
      '/products',
      body: {'base_product_id': baseProductId},
      requiresAuth: true,
    );
    return Product.fromJson(Map<String, dynamic>.from(response['data'] as Map));
  }

  @override
  Future<Product> getProductDetails(int productId) async {
    final response = await _api.get('/products/$productId');
    return Product.fromJson(Map<String, dynamic>.from(response['data'] as Map));
  }

  @override
  Future<void> stopTrackingProduct(int productId) => _api.delete('/products/$productId');

  @override
  Future<Map<int, List<PriceHistoryItem>>> getPriceHistory(int productId) async {
    final response = await _api.get('/products/$productId/price-history?period=365');
    final product = Product.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
    return {
      for (final listing in product.listings) listing.id: listing.history,
    };
  }

  @override
  Future<PriceAlert> createPriceAlert({
    required int productId,
    required double targetPrice,
  }) async {
    final response = await _api.post(
      '/alerts',
      body: {'product_id': productId, 'target_price': targetPrice},
      requiresAuth: true,
    );
    return PriceAlert.fromJson(Map<String, dynamic>.from(response['data'] as Map));
  }

  @override
  Future<void> removePriceAlert(int alertId) => _api.delete('/alerts/$alertId');

  @override
  Future<List<PriceAlert>> getActiveAlerts() async {
    final response = await _api.get('/alerts');
    return _rows(response).map(PriceAlert.fromJson).toList();
  }

  Future<Product> simulatePriceDrop(int productId) async {
    final response = await _api.post(
      '/products/$productId/simulate-price-drop',
      requiresAuth: true,
    );
    return Product.fromJson(Map<String, dynamic>.from(response['data'] as Map));
  }
}
