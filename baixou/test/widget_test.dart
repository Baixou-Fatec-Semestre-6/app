import 'package:flutter_test/flutter_test.dart';
import 'package:baixou/features/products/domain/entities/product.dart';

void main() {
  test('converte o contrato JSON de produto', () {
    final product = Product.fromJson({
      'id': 101,
      'url': 'https://www.amazon.com.br/dp/example',
      'title': 'Produto',
      'current_price': 99.9,
      'currency': 'BRL',
      'status': 'scraped',
      'created_at': '2026-10-18T12:00:00Z',
      'updated_at': '2026-10-18T13:00:00Z',
      'store': 'Amazon',
    });

    expect(product.id, 101);
    expect(product.currentPrice, 99.9);
    expect(product.status, ProductStatus.scraped);
  });
}
