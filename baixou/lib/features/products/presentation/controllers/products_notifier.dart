import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:baixou/features/products/domain/entities/product.dart';
import 'package:baixou/features/products/domain/entities/price_history_item.dart';
import 'package:baixou/features/products/domain/entities/price_alert.dart';
import 'package:baixou/features/notifications/presentation/controllers/notifications_notifier.dart';

class ProductsNotifier extends ChangeNotifier {
  final List<Product> _products = [];
  final Map<int, List<PriceHistoryItem>> _priceHistories = {};
  final List<PriceAlert> _alerts = [];
  bool _isLoading = false;

  // Searchable base list (our product database)
  final List<Product> _scrapedBase = [];

  List<Product> get products => _products;
  List<Product> get scrapedBase => _scrapedBase;
  List<PriceAlert> get alerts => _alerts;
  bool get isLoading => _isLoading;

  ProductsNotifier() {
    _loadBaseCatalog();
    _loadMockData();
  }

  void _loadBaseCatalog() {
    _scrapedBase.addAll([
      Product(
        id: 1,
        url: 'https://www.amazon.com.br/dp/B0000C73CQ',
        title: 'Fujifilm Filme Instax Mini com 20 Fotos, 8.6 x 5.4 cm',
        imageUrl: 'https://m.media-amazon.com/images/I/61cpxtAOkFL._AC_SY879_.jpg',
        currentPrice: 124.45,
        status: ProductStatus.scraped,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: 'Kabum',
      ),
      Product(
        id: 2,
        url: 'https://www.amazon.com.br/dp/B0BSH7SQFY',
        title: 'CABO HDMI 2.0 4K 3D 19 PINOS - 5 METROS',
        imageUrl: 'https://m.media-amazon.com/images/I/61hOvsR6HKL._AC_SX679_.jpg',
        currentPrice: 22.64,
        status: ProductStatus.scraped,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: 'Mercado Livre',
      ),
      Product(
        id: 3,
        url: 'https://www.amazon.com.br/dp/B0F8R9NDXC',
        title: 'PlayStation®5 Slim Disk - Pacote ASTRO BOT e Gran Turismo 7',
        imageUrl: 'https://m.media-amazon.com/images/I/71IkUBtdDGL._AC_SX679_.jpg',
        currentPrice: 4691.91,
        status: ProductStatus.scraped,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: 'Amazon',
      ),
      Product(
        id: 4,
        url: 'https://www.amazon.com.br/dp/B0F5X4NPK2',
        title: 'Samsung Smart TV 75" Crystal UHD 4K U8100F 2025',
        imageUrl: 'https://m.media-amazon.com/images/I/81QsB0GMcyL._AC_SX679_.jpg',
        currentPrice: 4699.00,
        status: ProductStatus.scraped,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: 'Magalu',
      ),
      Product(
        id: 5,
        url: 'https://www.amazon.com.br/dp/B0F2N7L7HQ',
        title: 'Romantic Crown Mochila Masculina de Viagem para Notebook',
        imageUrl: 'https://m.media-amazon.com/images/I/613o1RrqyAL._AC_SX679_.jpg',
        currentPrice: 108.26,
        status: ProductStatus.scraped,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: 'Shopee',
      ),
      Product(
        id: 6,
        url: 'https://www.amazon.com.br/dp/B0GYQ2PLW3',
        title: 'Smart TV TCL 55 Polegadas QLED Mini LED 4K A400M WiFi Bluetooth Google TV HDR10+ 144 Hz VRR 55A400M',
        imageUrl: 'https://m.media-amazon.com/images/I/81YQ+AnOI9L._AC_SX679_.jpg',
        currentPrice: 3399.00,
        status: ProductStatus.scraped,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: 'Kabum',
      ),
      Product(
        id: 7,
        url: 'https://www.amazon.com.br/dp/B0DKLQT9XR',
        title: 'Amazon Echo Dot Max (Geração mais recente), smart speaker com Alexa',
        imageUrl: 'https://m.media-amazon.com/images/I/71J0hF-lw+L._AC_SY879_.jpg',
        currentPrice: 719.00,
        status: ProductStatus.scraped,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: 'Amazon',
      ),
      Product(
        id: 8,
        url: 'https://www.amazon.com.br/dp/B0F6D7MQQB',
        title: 'Nintendo, Console, Nintendo Switch 2, Nacional',
        imageUrl: 'https://m.media-amazon.com/images/I/61oPb9El-SL._AC_SX679_.jpg',
        currentPrice: 4128.70,
        status: ProductStatus.scraped,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: 'Amazon',
      ),
      Product(
        id: 9,
        url: 'https://www.amazon.com.br/dp/B0G4SLJNFF',
        title: 'Tablet Samsung Galaxy TAB A11+, 128GB, 6GB RAM, WiFi',
        imageUrl: 'https://m.media-amazon.com/images/I/51TU36U5C1L._AC_SX679_.jpg',
        currentPrice: 1421.96,
        status: ProductStatus.scraped,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: 'Magalu',
      ),
      Product(
        id: 10,
        url: 'https://www.amazon.com.br/dp/B0DH8J5YGH',
        title: 'PlayStation®5 Pro',
        imageUrl: 'https://m.media-amazon.com/images/I/51dfg52K-cL._AC_SX679_.jpg',
        currentPrice: 6981.50,
        status: ProductStatus.scraped,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: 'Kabum',
      ),
      Product(
        id: 11,
        url: 'https://www.amazon.com.br/dp/B07N78G8GB',
        title: 'Havit Headphone Fone de Ouvido H2232d, Gamer, Iluminação RGB',
        imageUrl: 'https://m.media-amazon.com/images/I/71+giACAGrL._AC_SX679_.jpg',
        currentPrice: 73.59,
        status: ProductStatus.scraped,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: 'Mercado Livre',
      ),
      Product(
        id: 12,
        url: 'https://www.amazon.com.br/dp/B0FCYP5FB2',
        title: 'Smartphone Motorola Moto g86 5G - 256GB 24GB, Grafite',
        imageUrl: 'https://m.media-amazon.com/images/I/514xNqIfRZL._AC_SX679_.jpg',
        currentPrice: 1599.00,
        status: ProductStatus.scraped,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: 'Americanas',
      ),
      Product(
        id: 13,
        url: 'https://www.amazon.com.br/dp/B0FTKCF3QJ',
        title: 'Apple iPhone 14 (128 GB) – Meia-Noite (Seminovo)',
        imageUrl: 'https://m.media-amazon.com/images/I/61cwywLZR-L._AC_SX679_.jpg',
        currentPrice: 2588.98,
        status: ProductStatus.scraped,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: 'Mercado Livre',
      ),
      Product(
        id: 14,
        url: 'https://www.amazon.com.br/dp/B0GVT1T3PB',
        title: 'Celular Samsung Galaxy A57 5G 128GB, 8GB RAM, Recursos AI (Cinza)',
        imageUrl: 'https://m.media-amazon.com/images/I/51LpX2qhRfL._AC_SX679_.jpg',
        currentPrice: 1877.32,
        status: ProductStatus.scraped,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: 'Americanas',
      ),
      Product(
        id: 15,
        url: 'https://www.amazon.com.br/dp/B0BQJVKVQR',
        title: 'TP-Link Tapo C500 Câmera de Segurança Wi-Fi Externa 360°, Full HD 1080p',
        imageUrl: 'https://m.media-amazon.com/images/I/41hQ4O29nKL._AC_SX679_.jpg',
        currentPrice: 299.90,
        status: ProductStatus.scraped,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: 'Kabum',
      ),
      Product(
        id: 16,
        url: 'https://www.amazon.com.br/dp/B0FYQ5TQDL',
        title: 'LG UltraGear Monitor Gamer 24" IPS 144Hz, Preto - 24G411A',
        imageUrl: 'https://m.media-amazon.com/images/I/51jlpxmXEIL._AC_SX679_.jpg',
        currentPrice: 569.05,
        status: ProductStatus.scraped,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        store: 'Kabum',
      ),
    ]);
  }

  void _loadMockData() {
    // Initial Tracked Product 1: Kindle
    final kindle = Product(
      id: 101,
      url: 'https://www.amazon.com.br/dp/B09TWDYSVP',
      title: 'Kindle 11ª Geração (Lançamento 2022) - Mais leve, tela de 300 ppi',
      imageUrl: 'https://m.media-amazon.com/images/I/71X0PGbcVRL._AC_SL1500_.jpg',
      currentPrice: 474.05,
      currency: 'BRL',
      status: ProductStatus.scraped,
      lastScrapedAt: DateTime.now().subtract(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      store: 'Amazon',
    );

    // Initial Tracked Product 2: iPhone
    final iphone = Product(
      id: 102,
      url: 'https://www.amazon.com.br/dp/B0CHX1B3H2',
      title: 'Apple iPhone 15 Pro (128 GB) - Titânio Natural',
      imageUrl: 'https://m.media-amazon.com/images/I/81SigupXmOL._AC_SL1500_.jpg',
      currentPrice: 7299.00,
      currency: 'BRL',
      status: ProductStatus.scraped,
      lastScrapedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      store: 'Mercado Livre',
    );

    // Initial Tracked Product 3: PS5 Slim
    final ps5 = Product(
      id: 103,
      url: 'https://www.amazon.com.br/dp/B0CL5KFK8B',
      title: 'Console PlayStation 5 Slim Edição Digital',
      imageUrl: 'https://m.media-amazon.com/images/I/51p83f+zKzL._AC_SL1500_.jpg',
      status: ProductStatus.failed,
      lastErrorReason: 'blocked',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      store: 'Magalu',
    );

    // Initial Tracked Product 4: Alexa (Pending)
    final alexa = Product(
      id: 104,
      url: 'https://www.amazon.com.br/dp/B09B8V1CXY',
      status: ProductStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      store: 'Amazon',
    );

    _products.addAll([kindle, iphone, ps5, alexa]);

    // Mock Price Histories
    _priceHistories[101] = [
      PriceHistoryItem(id: 1, productId: 101, price: 499.00, scrapedAt: DateTime.now().subtract(const Duration(days: 9))),
      PriceHistoryItem(id: 2, productId: 101, price: 499.00, scrapedAt: DateTime.now().subtract(const Duration(days: 7))),
      PriceHistoryItem(id: 3, productId: 101, price: 485.00, scrapedAt: DateTime.now().subtract(const Duration(days: 5))),
      PriceHistoryItem(id: 4, productId: 101, price: 474.05, scrapedAt: DateTime.now().subtract(const Duration(days: 2))),
    ];

    _priceHistories[102] = [
      PriceHistoryItem(id: 5, productId: 102, price: 7599.00, scrapedAt: DateTime.now().subtract(const Duration(days: 4))),
      PriceHistoryItem(id: 6, productId: 102, price: 7499.00, scrapedAt: DateTime.now().subtract(const Duration(days: 3))),
      PriceHistoryItem(id: 7, productId: 102, price: 7299.00, scrapedAt: DateTime.now().subtract(const Duration(days: 1))),
    ];

    // Mock Price Alerts
    _alerts.addAll([
      PriceAlert(id: 201, userId: 1, productId: 101, targetPrice: 450.00, createdAt: DateTime.now()),
      PriceAlert(id: 202, userId: 1, productId: 102, targetPrice: 7000.00, createdAt: DateTime.now()),
    ]);
  }

  // Get price history for a specific product
  List<PriceHistoryItem> getPriceHistoryForProduct(int productId) {
    return _priceHistories[productId] ?? [];
  }

  // Get price alerts for a specific product
  List<PriceAlert> getAlertsForProduct(int productId) {
    return _alerts.where((alert) => alert.productId == productId).toList();
  }

  // Check if product's current price is lower than its initial price in history
  bool hasPriceDropped(Product product) {
    if (product.currentPrice == null || product.status != ProductStatus.scraped) return false;
    final history = _priceHistories[product.id];
    if (history != null && history.length >= 2) {
      final initialPrice = history.first.price;
      return product.currentPrice! < initialPrice;
    }
    return false;
  }

  int get droppedProductsCount => _products.where((p) => hasPriceDropped(p)).length;

  // Search products from the PostgreSQL base catalog
  Future<List<Product>> searchCatalog(String query) async {
    _isLoading = true;
    notifyListeners();

    // Simulate database query delay
    await Future.delayed(const Duration(milliseconds: 300));

    final results = _scrapedBase.where((p) {
      final titleMatch = p.title != null && p.title!.toLowerCase().contains(query.toLowerCase());
      final storeMatch = p.store.toLowerCase().contains(query.toLowerCase());
      return titleMatch || storeMatch;
    }).toList();

    _isLoading = false;
    notifyListeners();
    return results;
  }

  // Simulate tracking a new product selected from the catalog base
  Future<void> trackNewProduct(Product baseProduct) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final newId = Random().nextInt(10000) + 1000;
    final newProduct = Product(
      id: newId,
      url: baseProduct.url,
      status: ProductStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      store: baseProduct.store,
    );

    _products.add(newProduct);
    _isLoading = false;
    notifyListeners();

    // Start Async Scraper Simulator (RabbitMQ simulator)
    _simulateScraperService(newId, baseProduct);
  }

  // Stop tracking a product
  Future<void> stopTracking(int productId) async {
    _products.removeWhere((p) => p.id == productId);
    _alerts.removeWhere((a) => a.productId == productId);
    _priceHistories.remove(productId);
    notifyListeners();
  }

  // Create a price alert
  void createAlert(int productId, double targetPrice) {
    final alertId = Random().nextInt(10000) + 2000;
    final newAlert = PriceAlert(
      id: alertId,
      userId: 1,
      productId: productId,
      targetPrice: targetPrice,
      createdAt: DateTime.now(),
    );

    _alerts.add(newAlert);
    notifyListeners();
  }

  // Delete a price alert
  void deleteAlert(int alertId) {
    _alerts.removeWhere((a) => a.id == alertId);
    notifyListeners();
  }

  // Simulator for the asynchronous scraping worker
  void _simulateScraperService(int productId, Product baseProduct) {
    Timer(const Duration(seconds: 3), () {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index == -1) return; // Product was removed

      final isSuccess = Random().nextDouble() < 0.90; // 90% success rate

      if (isSuccess) {
        _products[index] = _products[index].copyWith(
          title: baseProduct.title,
          imageUrl: baseProduct.imageUrl,
          currentPrice: baseProduct.currentPrice,
          status: ProductStatus.scraped,
          store: baseProduct.store,
          lastScrapedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Initialize history
        _priceHistories[productId] = [
          PriceHistoryItem(
            id: Random().nextInt(10000),
            productId: productId,
            price: baseProduct.currentPrice! * 1.12,
            scrapedAt: DateTime.now().subtract(const Duration(days: 3)),
          ),
          PriceHistoryItem(
            id: Random().nextInt(10000),
            productId: productId,
            price: baseProduct.currentPrice!,
            scrapedAt: DateTime.now(),
          ),
        ];
      } else {
        // Failed scraping
        final reason = Random().nextBool() ? 'blocked' : 'timeout';
        _products[index] = _products[index].copyWith(
          status: ProductStatus.failed,
          lastErrorReason: reason,
          updatedAt: DateTime.now(),
        );
      }

      notifyListeners();
    });
  }

  // Trigger simulated price drop for demonstration
  void simulatePriceDrop(int productId, NotificationsNotifier notificationsNotifier) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    final product = _products[index];
    if (product.status != ProductStatus.scraped || product.currentPrice == null) return;

    final oldPrice = product.currentPrice!;
    // Drop price by 20%
    final newPrice = (oldPrice * 0.8).roundToDouble();

    _products[index] = product.copyWith(
      currentPrice: newPrice,
      lastScrapedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Add to history
    if (_priceHistories.containsKey(productId)) {
      _priceHistories[productId]!.add(
        PriceHistoryItem(
          id: Random().nextInt(10000),
          productId: productId,
          price: newPrice,
          scrapedAt: DateTime.now(),
        ),
      );
    }

    notifyListeners();

    // Check if the drop triggers any active alerts
    final activeAlerts = getAlertsForProduct(productId);
    for (final alert in activeAlerts) {
      if (newPrice <= alert.targetPrice) {
        // Trigger notification!
        notificationsNotifier.addNotification(
          productId: productId,
          productTitle: product.title ?? 'Produto',
          productImageUrl: product.imageUrl,
          oldPrice: oldPrice,
          newPrice: newPrice,
        );
      }
    }
  }
}
