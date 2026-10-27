class PriceAlert {
  final int id;
  final int userId;
  final int productId;
  final double targetPrice;
  final DateTime createdAt;

  PriceAlert({
    required this.id,
    required this.userId,
    required this.productId,
    required this.targetPrice,
    required this.createdAt,
  });

  factory PriceAlert.fromJson(Map<String, dynamic> json) => PriceAlert(
        id: (json['id'] as num).toInt(),
        userId: (json['user_id'] as num).toInt(),
        productId: (json['product_id'] as num).toInt(),
        targetPrice: (json['target_price'] as num).toDouble(),
        createdAt: DateTime.parse(json['created_at'].toString()),
      );
}
