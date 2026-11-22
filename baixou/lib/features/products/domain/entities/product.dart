import 'price_history_item.dart';

double? _asDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');

enum ProductStatus { pending, scraped, failed }

class ProductListing {
  final int id;
  final String store;
  final String url;
  final double? currentPrice;
  final String currency;
  final ProductStatus status;
  final String? lastErrorReason;
  final DateTime? lastScrapedAt;
  final double? minPrice;
  final double? avgPrice;
  final double? maxPrice;
  final List<PriceHistoryItem> history;

  const ProductListing({
    required this.id,
    required this.store,
    required this.url,
    this.currentPrice,
    this.currency = 'BRL',
    this.status = ProductStatus.pending,
    this.lastErrorReason,
    this.lastScrapedAt,
    this.minPrice,
    this.avgPrice,
    this.maxPrice,
    this.history = const [],
  });

  factory ProductListing.fromJson(Map<String, dynamic> json) {
    final statusValue = json['status']?.toString() ??
        (json['current_price'] == null ? 'pending' : 'scraped');
    return ProductListing(
      id: (json['id'] as num).toInt(),
      store: json['store']?.toString() ?? 'Loja',
      url: json['url']?.toString() ?? '',
      currentPrice: _asDouble(json['current_price']),
      currency: json['currency']?.toString() ?? 'BRL',
      status: ProductStatus.values.firstWhere(
        (value) => value.name == statusValue,
        orElse: () => ProductStatus.pending,
      ),
      lastErrorReason: json['last_error_reason']?.toString(),
      lastScrapedAt: DateTime.tryParse(
        (json['last_scraped_at'] ?? json['last_scrape_at'])?.toString() ?? '',
      ),
      minPrice: _asDouble(json['min_price']),
      avgPrice: _asDouble(json['avg_price']),
      maxPrice: _asDouble(json['max_price']),
      history: (json['history'] as List? ?? const [])
          .map((item) => PriceHistoryItem.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
    );
  }
}

class Product {
  final int id;
  final String name;
  final String? imageUrl;
  final List<ProductListing> listings;
  final Map<String, dynamic>? monitor;

  const Product({
    required this.id,
    required this.name,
    this.imageUrl,
    this.listings = const [],
    this.monitor,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: (json['id'] as num).toInt(),
        name: (json['name'] ?? json['title'])?.toString() ?? 'Produto',
        imageUrl: json['image_url']?.toString(),
        listings: (json['listings'] as List? ?? const [])
            .map((item) => ProductListing.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList(),
        monitor: json['monitor'] is Map
            ? Map<String, dynamic>.from(json['monitor'] as Map)
            : null,
      );

  ProductListing? get bestListing {
    final priced = listings.where((item) => item.currentPrice != null).toList()
      ..sort((a, b) => a.currentPrice!.compareTo(b.currentPrice!));
    return priced.isNotEmpty
        ? priced.first
        : (listings.isEmpty ? null : listings.first);
  }

  String? get title => name;
  String get url => bestListing?.url ?? '';
  double? get currentPrice => bestListing?.currentPrice;
  String get currency => bestListing?.currency ?? 'BRL';
  String get store => listings.isEmpty
      ? 'Loja'
      : listings.map((listing) => listing.store).join(' • ');
  ProductStatus get status {
    if (listings.any((listing) => listing.status == ProductStatus.scraped)) {
      return ProductStatus.scraped;
    }
    if (listings.isNotEmpty &&
        listings.every((listing) => listing.status == ProductStatus.failed)) {
      return ProductStatus.failed;
    }
    return ProductStatus.pending;
  }
  String? get lastErrorReason => bestListing?.lastErrorReason;
  DateTime? get lastScrapedAt => bestListing?.lastScrapedAt;

  Product copyWith({List<ProductListing>? listings}) => Product(
        id: id,
        name: name,
        imageUrl: imageUrl,
        listings: listings ?? this.listings,
        monitor: monitor,
      );
}
