import 'package:flutter/material.dart';
import 'package:baixou/features/notifications/presentation/controllers/notifications_notifier.dart';
import 'package:baixou/features/products/data/repositories/products_repository_impl.dart';
import 'package:baixou/features/products/domain/entities/price_alert.dart';
import 'package:baixou/features/products/domain/entities/price_history_item.dart';
import 'package:baixou/features/products/domain/entities/product.dart';
import 'package:baixou/features/products/domain/repositories/products_repository.dart';

class ProductsNotifier extends ChangeNotifier {
  final ProductsRepository _repository;
  final Map<int, List<PriceHistoryItem>> _priceHistories = {};
  List<Product> _products = [];
  List<PriceAlert> _alerts = [];
  bool _isLoading = false;
  String? _errorMessage;

  ProductsNotifier({ProductsRepository? repository})
      : _repository = repository ?? ProductsRepositoryImpl() {
    refresh();
  }

  List<Product> get products => List.unmodifiable(_products);
  List<Product> get scrapedBase => const [];
  List<PriceAlert> get alerts => List.unmodifiable(_alerts);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getTrackedProducts(),
        _repository.getActiveAlerts(),
      ]);
      _products = results[0] as List<Product>;
      _alerts = results[1] as List<PriceAlert>;
      await Future.wait(
        _products
            .where((product) => product.status == ProductStatus.scraped)
            .map(_loadHistory),
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadHistory(Product product) async {
    try {
      _priceHistories[product.id] = await _repository.getPriceHistory(product.id);
    } catch (_) {
      _priceHistories[product.id] = const [];
    }
  }

  List<PriceHistoryItem> getPriceHistoryForProduct(int productId) =>
      _priceHistories[productId] ?? const [];

  List<PriceAlert> getAlertsForProduct(int productId) =>
      _alerts.where((alert) => alert.productId == productId).toList();

  bool hasPriceDropped(Product product) {
    final history = _priceHistories[product.id];
    return product.currentPrice != null &&
        history != null &&
        history.length >= 2 &&
        product.currentPrice! < history.first.price;
  }

  int get droppedProductsCount => _products.where(hasPriceDropped).length;

  Future<List<Product>> searchCatalog(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      return await _repository.searchProductsInCatalog(query);
    } catch (error) {
      _errorMessage = error.toString();
      return const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> trackNewProduct(Product baseProduct) async {
    _isLoading = true;
    notifyListeners();
    try {
      final product = await _repository.trackNewProduct(baseProductId: baseProduct.id);
      _products = [..._products, product];
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> stopTracking(int productId) async {
    try {
      await _repository.stopTrackingProduct(productId);
      _products.removeWhere((product) => product.id == productId);
      _alerts.removeWhere((alert) => alert.productId == productId);
      _priceHistories.remove(productId);
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  void createAlert(int productId, double targetPrice) {
    _createAlert(productId, targetPrice);
  }

  Future<void> _createAlert(int productId, double targetPrice) async {
    try {
      final alert = await _repository.createPriceAlert(
        productId: productId,
        targetPrice: targetPrice,
      );
      _alerts = [..._alerts, alert];
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  void deleteAlert(int alertId) {
    _deleteAlert(alertId);
  }

  Future<void> _deleteAlert(int alertId) async {
    try {
      await _repository.removePriceAlert(alertId);
      _alerts.removeWhere((alert) => alert.id == alertId);
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> simulatePriceDrop(
    int productId,
    NotificationsNotifier notificationsNotifier,
  ) async {
    if (_repository is! ProductsRepositoryImpl) return;
    try {
      final updated =
          await _repository.simulatePriceDrop(productId);
      final index = _products.indexWhere((product) => product.id == productId);
      if (index >= 0) _products[index] = updated;
      await _loadHistory(updated);
      await notificationsNotifier.refresh();
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }
}
