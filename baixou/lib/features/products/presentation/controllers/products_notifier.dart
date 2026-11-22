import 'dart:async';

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

  /// A coleta é assíncrona (core → RabbitMQ → scraper → core): depois de
  /// monitorar um produto a API responde `pending` e o preço chega segundos
  /// depois. Enquanto houver oferta pendente, consulta a API periodicamente.
  final Duration pendingPollInterval;
  final Duration pendingPollLimit;
  Timer? _pendingTimer;
  DateTime? _pendingSince;
  bool _isPolling = false;
  bool _disposed = false;

  ProductsNotifier({
    ProductsRepository? repository,
    this.pendingPollInterval = const Duration(seconds: 3),
    this.pendingPollLimit = const Duration(minutes: 2),
  }) : _repository = repository ?? ProductsRepositoryImpl() {
    refresh();
  }

  bool get _hasPending => _products.any(
        (product) => product.listings
            .any((listing) => listing.status == ProductStatus.pending),
      );

  void _watchPending() {
    if (_disposed || !_hasPending) {
      _stopWatchingPending();
      return;
    }
    _pendingSince ??= DateTime.now();
    _pendingTimer ??= Timer.periodic(pendingPollInterval, (_) => _pollPending());
  }

  void _stopWatchingPending() {
    _pendingTimer?.cancel();
    _pendingTimer = null;
    _pendingSince = null;
  }

  Future<void> _pollPending() async {
    if (_isPolling || _disposed) return;
    if (!_hasPending ||
        DateTime.now().difference(_pendingSince ?? DateTime.now()) > pendingPollLimit) {
      _stopWatchingPending();
      return;
    }
    _isPolling = true;
    try {
      final previous = {for (final p in _products) p.id: p.status};
      final latest = await _repository.getTrackedProducts();
      if (_disposed) return;
      _products = latest;
      final changed = latest.where(
        (p) => p.listings.isNotEmpty && previous[p.id] != p.status,
      );
      await Future.wait(changed.map(_loadHistory));
      if (_disposed) return;
      notifyListeners();
    } catch (_) {
      // Falha momentânea de rede: tenta de novo no próximo intervalo.
    } finally {
      _isPolling = false;
    }
    if (!_hasPending) _stopWatchingPending();
  }

  @override
  void dispose() {
    _disposed = true;
    _stopWatchingPending();
    super.dispose();
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
        _products.where((product) => product.listings.isNotEmpty).map(_loadHistory),
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    _watchPending();
  }

  Future<void> _loadHistory(Product product) async {
    try {
      _priceHistories.addAll(await _repository.getPriceHistory(product.id));
    } catch (_) {
      for (final listing in product.listings) {
        _priceHistories[listing.id] = const [];
      }
    }
  }

  List<PriceHistoryItem> getPriceHistoryForProduct(int productId) =>
      _products
          .where((product) => product.id == productId)
          .map((product) => product.bestListing)
          .whereType<ProductListing>()
          .expand(
            (listing) =>
                _priceHistories[listing.id] ?? const <PriceHistoryItem>[],
          )
          .toList();

  List<PriceHistoryItem> getPriceHistoryForListing(int listingId) =>
      _priceHistories[listingId] ?? const [];

  List<PriceAlert> getAlertsForProduct(int productId) =>
      _alerts.where((alert) => alert.productId == productId).toList();

  bool hasPriceDropped(Product product) {
    final listing = product.bestListing;
    final history = listing == null ? null : _priceHistories[listing.id];
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
      _products = [..._products.where((p) => p.id != product.id), product];
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    _watchPending();
  }

  Future<void> stopTracking(int productId) async {
    try {
      await _repository.stopTrackingProduct(productId);
      final removed = _products.where((product) => product.id == productId).toList();
      for (final product in removed) {
        for (final listing in product.listings) {
          _priceHistories.remove(listing.id);
        }
      }
      _products.removeWhere((product) => product.id == productId);
      _alerts.removeWhere((alert) => alert.productId == productId);
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
