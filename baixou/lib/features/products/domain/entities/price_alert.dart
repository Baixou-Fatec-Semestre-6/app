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
}
