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

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: (json['id'] as num).toInt(),
        userId: (json['user_id'] as num).toInt(),
        productId: (json['product_id'] as num).toInt(),
        productTitle: json['product_title']?.toString() ?? 'Produto',
        productImageUrl: json['product_image_url']?.toString(),
        oldPrice: (json['old_price'] as num).toDouble(),
        newPrice: (json['new_price'] as num).toDouble(),
        isRead: json['is_read'] == true,
        createdAt: DateTime.parse(json['created_at'].toString()),
      );

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
