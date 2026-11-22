class PriceHistoryItem {
  final double price;
  final DateTime scrapedAt;

  const PriceHistoryItem({required this.price, required this.scrapedAt});

  factory PriceHistoryItem.fromJson(Map<String, dynamic> json) =>
      PriceHistoryItem(
        price: json['price'] is num
            ? (json['price'] as num).toDouble()
            : double.parse(json['price'].toString()),
        scrapedAt: DateTime.parse(json['scraped_at'].toString()),
      );
}
