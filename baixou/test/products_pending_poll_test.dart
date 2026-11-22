import 'package:baixou/features/products/domain/entities/price_alert.dart';
import 'package:baixou/features/products/domain/entities/price_history_item.dart';
import 'package:baixou/features/products/domain/entities/product.dart';
import 'package:baixou/features/products/domain/repositories/products_repository.dart';
import 'package:baixou/features/products/presentation/controllers/products_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

Product _product(ProductStatus status, {double? price}) => Product(
      id: 1,
      name: 'Echo Dot Max',
      listings: [
        ProductListing(
          id: 10,
          store: 'Amazon',
          url: 'https://www.amazon.com.br/dp/B0DKLQT9XR',
          status: status,
          currentPrice: price,
        ),
      ],
    );

/// Simula o core: o POST devolve `pending` e a coleta termina depois de
/// [callsUntilScraped] consultas a GET /products/catalog?scope=tracked.
class _FakeRepository implements ProductsRepository {
  _FakeRepository({this.callsUntilScraped = 2});

  final int callsUntilScraped;
  bool tracked = false;
  int trackedCalls = 0;

  @override
  Future<List<Product>> getTrackedProducts() async {
    if (!tracked) return const [];
    trackedCalls++;
    return [
      trackedCalls >= callsUntilScraped
          ? _product(ProductStatus.scraped, price: 599)
          : _product(ProductStatus.pending),
    ];
  }

  @override
  Future<Product> trackNewProduct({required int baseProductId}) async {
    tracked = true;
    return _product(ProductStatus.pending);
  }

  @override
  Future<Map<int, List<PriceHistoryItem>>> getPriceHistory(int productId) async => {10: const []};

  @override
  Future<List<PriceAlert>> getActiveAlerts() async => const [];

  @override
  Future<List<Product>> searchProductsInCatalog(String query) async => const [];

  @override
  Future<Product> getProductDetails(int productId) async => _product(ProductStatus.pending);

  @override
  Future<void> stopTrackingProduct(int productId) async {}

  @override
  Future<PriceAlert> createPriceAlert({required int productId, required double targetPrice}) =>
      throw UnimplementedError();

  @override
  Future<void> removePriceAlert(int alertId) async {}
}

void main() {
  test('produto monitorado sai de pending sozinho quando a coleta termina', () async {
    final repository = _FakeRepository(callsUntilScraped: 2);
    final notifier = ProductsNotifier(
      repository: repository,
      pendingPollInterval: const Duration(milliseconds: 20),
    );
    addTearDown(notifier.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    await notifier.trackNewProduct(_product(ProductStatus.pending));
    expect(notifier.products.single.status, ProductStatus.pending);

    for (var i = 0; i < 50 && notifier.products.single.status == ProductStatus.pending; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }

    expect(notifier.products.single.status, ProductStatus.scraped);
    expect(notifier.products.single.currentPrice, 599);

    final callsAfterScraped = repository.trackedCalls;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    expect(repository.trackedCalls, callsAfterScraped, reason: 'para de consultar quando nada está pendente');
  });
}
