// filepath: lib/features/notifications/widgets/notification_tile.dart
// Widget tuile pour afficher une notification individuelle
// Avec différents styles selon le type de notification et l'état lu/non-lu
// RELEVANT FILES: notification_service.dart, app_colors.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(height: 4),
            Text(
              'Supprimer',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.surface
              : AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: notification.isRead
              ? Border.all(color: AppColors.border)
              : Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icône selon le type
                  _buildNotificationIcon(),

                  const SizedBox(width: 12),

                  // Contenu
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre avec indicateur non-lu
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead
                                      ? FontWeight.w600
                                      : FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Message
                        Text(
                          notification.message,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Horodatage
                        Text(
                          _formatTime(notification.createdAt),
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions rapides
                  _buildQuickActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.orderReceived:
        iconData = Icons.shopping_bag;
        iconColor = AppColors.success;
        break;
      case NotificationType.orderConfirmed:
        iconData = Icons.check_circle;
        iconColor = AppColors.primary;
        break;
      case NotificationType.orderReady:
        iconData = Icons.inventory;
        iconColor = AppColors.accent;
        break;
      case NotificationType.orderDelivered:
        iconData = Icons.local_shipping;
        iconColor = AppColors.success;
        break;
      case NotificationType.paymentReceived:
        iconData = Icons.payments;
        iconColor = AppColors.success;
        break;
      case NotificationType.newMessage:
        iconData = Icons.message;
        iconColor = AppColors.info;
        break;
      case NotificationType.productLiked:
        iconData = Icons.favorite;
        iconColor = AppColors.error;
        break;
      case NotificationType.reviewReceived:
        iconData = Icons.star;
        iconColor = AppColors.warning;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(iconData, color: iconColor, size: 22),
    );
  }

  Widget _buildQuickActions() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 16,
        color: AppColors.textSecondary.withOpacity(0.5),
      ),
      onSelected: (value) {
        switch (value) {
          case 'mark_read':
            if (!notification.isRead) {
              NotificationService().markAsRead(notification.id);
            }
            break;
          case 'delete':
            onDismiss?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (!notification.isRead)
          PopupMenuItem(
            value: 'mark_read',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.done, size: 16),
                const SizedBox(width: 8),
                Text('mark_read'.tr()),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete, size: 16, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                'delete'.tr(),
                style: const TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'just_now'.tr();
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${'minutes_ago'.tr()}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${'hours_ago'.tr()}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${'days_ago'.tr()}';
    } else {
      return DateFormat('dd/MM/yyyy').format(time);
    }
  }
}
