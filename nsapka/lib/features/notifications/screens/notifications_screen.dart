// filepath: lib/features/notifications/screens/notifications_screen.dart
// Écran d'affichage de toutes les notifications utilisateur
// Permet de voir, marquer comme lues et gérer les notifications
// RELEVANT FILES: notification_service.dart, app_colors.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _notificationService.addListener(_onNotificationsChanged);
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _onNotificationsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notificationService.notifications;
    final unreadCount = _notificationService.unreadCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text('notifications'.tr()),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'mark_all_read':
                    _notificationService.markAllAsRead();
                    break;
                  case 'clear_all':
                    _showClearAllDialog();
                    break;
                }
              },
              itemBuilder: (context) => [
                if (unreadCount > 0)
                  PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        const Icon(Icons.done_all, size: 20),
                        const SizedBox(width: 8),
                        Text('mark_all_read'.tr()),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_sweep,
                        size: 20,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'clear_all'.tr(),
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationsList(notifications),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 100,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'no_notifications'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'no_notifications_desc'.tr(),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Simuler quelques notifications pour la démo
              _notificationService.initializeTestNotifications();
            },
            icon: const Icon(Icons.add),
            label: Text('simulate_notifications'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    return RefreshIndicator(
      onRefresh: () async {
        // Simuler un refresh
        await Future.delayed(const Duration(seconds: 1));
        _notificationService.simulateRealtimeNotifications();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationTile(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
            onDismiss: () =>
                _notificationService.removeNotification(notification.id),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Marquer comme lue
    if (!notification.isRead) {
      _notificationService.markAsRead(notification.id);
    }

    // Navigation selon le type de notification
    switch (notification.type) {
      case NotificationType.orderReceived:
      case NotificationType.orderConfirmed:
      case NotificationType.orderReady:
      case NotificationType.orderDelivered:
        final orderId = notification.data?['orderId'];
        if (orderId != null) {
          Navigator.pushNamed(context, '/order-detail', arguments: orderId);
        }
        break;

      case NotificationType.newMessage:
        final chatId = notification.data?['chatId'];
        if (chatId != null) {
          Navigator.pushNamed(context, '/chat', arguments: chatId);
        }
        break;

      case NotificationType.productLiked:
      case NotificationType.reviewReceived:
        final productId = notification.data?['productId'];
        if (productId != null) {
          Navigator.pushNamed(context, '/product-detail', arguments: productId);
        }
        break;

      default:
        // Notification générale, pas d'action spécifique
        break;
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('clear_all_notifications'.tr()),
        content: Text('clear_all_notifications_desc'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _notificationService.clearAll();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('clear_all'.tr()),
          ),
        ],
      ),
    );
  }
}
