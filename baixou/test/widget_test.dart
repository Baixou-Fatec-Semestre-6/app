import 'package:flutter_test/flutter_test.dart';
import 'package:baixou/features/products/domain/entities/product.dart';

void main() {
  test('converte o contrato JSON de produto', () {
    final product = Product.fromJson({
      'id': 101,
      'name': 'Produto',
      'listings': [
        {
          'id': 201,
          'url': 'https://www.amazon.com.br/dp/example',
          'current_price': 99.9,
          'currency': 'BRL',
          'status': 'scraped',
          'store': 'Amazon',
        },
      ],
      'created_at': '2026-10-18T12:00:00Z',
      'updated_at': '2026-10-18T13:00:00Z',
    });

    expect(product.id, 101);
    expect(product.currentPrice, 99.9);
    expect(product.status, ProductStatus.scraped);
    expect(product.bestListing?.id, 201);
  });

  test('seleciona a listing com menor preço', () {
    final product = Product.fromJson({
      'id': 102,
      'name': 'Produto com duas lojas',
      'listings': [
        {
          'id': 301,
          'store': 'Loja A',
          'url': 'https://example.com/a',
          'current_price': '120.50',
          'status': 'scraped',
        },
        {
          'id': 302,
          'store': 'Loja B',
          'url': 'https://example.com/b',
          'current_price': 99.90,
          'status': 'scraped',
        },
      ],
    });

    expect(product.currentPrice, 99.90);
    expect(product.bestListing?.id, 302);
  });
}
