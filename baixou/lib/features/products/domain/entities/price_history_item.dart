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
}
