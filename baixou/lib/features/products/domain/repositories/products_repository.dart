import '../entities/product.dart';
import '../entities/price_history_item.dart';
import '../entities/price_alert.dart';

abstract class ProductsRepository {
  Future<List<Product>> getTrackedProducts();
  Future<List<Product>> searchProductsInCatalog(String query); // Queries PostgreSQL 'produto' table
  Future<Product> trackNewProduct({required int baseProductId});
  Future<Product> getProductDetails(int productId);
  Future<void> stopTrackingProduct(int productId);

  // Price History
  Future<List<PriceHistoryItem>> getPriceHistory(int productId);

  // Price Alerts
  Future<PriceAlert> createPriceAlert({required int productId, required double targetPrice});
  Future<void> removePriceAlert(int alertId);
  Future<List<PriceAlert>> getActiveAlerts();
}
