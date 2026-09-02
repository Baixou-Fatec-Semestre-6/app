import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baixou/core/theme/app_theme.dart';
import 'package:baixou/features/products/presentation/screens/product_details_screen.dart';
import 'package:baixou/features/notifications/presentation/controllers/notifications_notifier.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationsNotifier = Provider.of<NotificationsNotifier>(context);
    final notifications = notificationsNotifier.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.done_all, color: AppTheme.primaryLight, size: 18),
              label: const Text('Marcar todas como lidas', style: TextStyle(color: AppTheme.primaryLight, fontSize: 13)),
              onPressed: () {
                notificationsNotifier.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todas as notificações foram marcadas como lidas!')),
                );
              },
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, color: AppTheme.textSecondary.withOpacity(0.5), size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Sem Notificações',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Defina alertas de preço nos seus produtos rastreados. Quando o preço cair, você será notificado aqui!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final percentDrop = ((notification.oldPrice - notification.newPrice) / notification.oldPrice * 100).toStringAsFixed(0);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      notificationsNotifier.markAsRead(notification.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsScreen(productId: notification.productId),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image or Icon
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.darkBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: notification.productImageUrl != null
                                      ? Image.network(
                                          notification.productImageUrl!,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.shopping_bag_outlined, color: AppTheme.textSecondary),
                                        )
                                      : const Icon(Icons.shopping_bag_outlined, color: AppTheme.textSecondary),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.productTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 6),
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.9), fontSize: 13),
                                        children: [
                                          const TextSpan(text: 'Preço caiu '),
                                          TextSpan(
                                            text: '$percentDrop% ',
                                            style: const TextStyle(color: AppTheme.statusScraped, fontWeight: FontWeight.bold),
                                          ),
                                          const TextSpan(text: 'de '),
                                          TextSpan(
                                            text: 'R\$ ${notification.oldPrice.toStringAsFixed(2)}',
                                            style: const TextStyle(decoration: TextDecoration.lineThrough),
                                          ),
                                          const TextSpan(text: ' para '),
                                          TextSpan(
                                            text: 'R\$ ${notification.newPrice.toStringAsFixed(2)}',
                                            style: const TextStyle(color: AppTheme.statusScraped, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatRelativeTime(notification.createdAt),
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Unread marker dot
                        if (!notification.isRead)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} minutos';
    if (diff.inHours < 24) return 'Há ${diff.inHours} horas';
    return 'Há ${diff.inDays} dias';
  }
}
