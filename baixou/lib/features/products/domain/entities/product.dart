enum ProductStatus {
  pending,
  scraped,
  failed,
}

class Product {
  final int id;
  final String url;
  final String? title;
  final String? imageUrl;
  final double? currentPrice;
  final String currency;
  final ProductStatus status;
  final String? lastErrorReason;
  final DateTime? lastScrapedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String store;

  Product({
    required this.id,
    required this.url,
    this.title,
    this.imageUrl,
    this.currentPrice,
    this.currency = 'BRL',
    required this.status,
    this.lastErrorReason,
    this.lastScrapedAt,
    required this.createdAt,
    required this.updatedAt,
    this.store = 'Amazon',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final statusValue = json['status']?.toString() ?? 'pending';
    return Product(
      id: (json['id'] as num).toInt(),
      url: json['url']?.toString() ?? '',
      title: json['title']?.toString(),
      imageUrl: json['image_url']?.toString(),
      currentPrice: (json['current_price'] as num?)?.toDouble(),
      currency: json['currency']?.toString() ?? 'BRL',
      status: ProductStatus.values.firstWhere(
        (value) => value.name == statusValue,
        orElse: () => ProductStatus.pending,
      ),
      lastErrorReason: json['last_error_reason']?.toString(),
      lastScrapedAt: DateTime.tryParse(json['last_scraped_at']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      store: json['store']?.toString() ?? 'Amazon',
    );
  }

  Product copyWith({
    int? id,
    String? url,
    String? title,
    String? imageUrl,
    double? currentPrice,
    String? currency,
    ProductStatus? status,
    String? lastErrorReason,
    DateTime? lastScrapedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? store,
  }) {
    return Product(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      currentPrice: currentPrice ?? this.currentPrice,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      lastErrorReason: lastErrorReason ?? this.lastErrorReason,
      lastScrapedAt: lastScrapedAt ?? this.lastScrapedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      store: store ?? this.store,
    );
  }
}
