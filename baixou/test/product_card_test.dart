import 'package:baixou/features/products/domain/entities/price_alert.dart';
import 'package:baixou/features/products/domain/entities/product.dart';
import 'package:baixou/features/products/domain/repositories/products_repository.dart';
import 'package:baixou/features/products/presentation/controllers/products_notifier.dart';
import 'package:baixou/features/products/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _EmptyRepository implements ProductsRepository {
  @override
  Future<List<Product>> getTrackedProducts() async => [];

  @override
  Future<List<PriceAlert>> getActiveAlerts() async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final status in ProductStatus.values) {
    for (final price in <double?>[null, 646.46]) {
      testWidgets('exibe nome e preço disponível: $status, $price', (
        tester,
      ) async {
        final notifier = ProductsNotifier(repository: _EmptyRepository());
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: notifier,
            child: MaterialApp(
              home: Scaffold(
                body: SizedBox(
                  width: 320,
                  height: 400,
                  child: ProductCard(
                    product: Product(
                      id: 1,
                      name: 'Logitech MX Master 3',
                      listings: [
                        ProductListing(
                          id: 2,
                          store: 'Amazon',
                          url: 'https://www.amazon.com.br/dp/B07S395RWD',
                          status: status,
                          currentPrice: price,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Logitech MX Master 3'), findsOneWidget);
        expect(
          find.text('R\$ 646.46'),
          price == null ? findsNothing : findsOneWidget,
        );
        expect(
          find.text('Último preço conhecido'),
          price != null && status != ProductStatus.scraped
              ? findsOneWidget
              : findsNothing,
        );
        if (price == null) {
          expect(
            find.text(
              status == ProductStatus.pending
                  ? 'Calculando...'
                  : 'Indisponível',
            ),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        notifier.dispose();
      });
    }
  }
}
