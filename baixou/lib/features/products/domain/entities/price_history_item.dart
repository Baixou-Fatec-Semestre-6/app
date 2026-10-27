class PriceHistoryItem {
  final int id;
  final int productId;
  final double price;
  final DateTime scrapedAt;

  PriceHistoryItem({
    required this.id,
    required this.productId,
    required this.price,
    required this.scrapedAt,
  });

  factory PriceHistoryItem.fromJson(Map<String, dynamic> json) => PriceHistoryItem(
        id: (json['id'] as num).toInt(),
        productId: (json['product_id'] as num).toInt(),
        price: (json['price'] as num).toDouble(),
        scrapedAt: DateTime.parse(json['scraped_at'].toString()),
      );
}
