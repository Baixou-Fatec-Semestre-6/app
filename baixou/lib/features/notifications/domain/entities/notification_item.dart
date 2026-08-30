class NotificationItem {
  final int id;
  final int userId;
  final int productId;
  final String productTitle;
  final String? productImageUrl;
  final double oldPrice;
  final double newPrice;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productTitle,
    this.productImageUrl,
    required this.oldPrice,
    required this.newPrice,
    required this.isRead,
    required this.createdAt,
  });

  NotificationItem copyWith({
    int? id,
    int? userId,
    int? productId,
    String? productTitle,
    String? productImageUrl,
    double? oldPrice,
    double? newPrice,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      oldPrice: oldPrice ?? this.oldPrice,
      newPrice: newPrice ?? this.newPrice,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
