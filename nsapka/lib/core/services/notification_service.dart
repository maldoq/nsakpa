// filepath: lib/core/services/notification_service.dart
// Service de notifications pour alerter les utilisateurs des changements de statut de commandes
// Gère les notifications push et in-app pour les artisans et acheteurs
// RELEVANT FILES: order_model.dart, api_service.dart, main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum NotificationType {
  orderReceived, // Artisan reçoit nouvelle commande
  orderConfirmed, // Acheteur: commande confirmée
  orderReady, // Acheteur: commande prête
  orderDelivered, // Artisan: commande livrée
  paymentReceived, // Artisan: paiement reçu
  newMessage, // Nouveau message
  productLiked, // Produit liké
  reviewReceived, // Nouvel avis reçu
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationModel> _notifications = [];
  final List<Function(NotificationModel)> _listeners = [];

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  int get unreadCount => unreadNotifications.length;
  bool get hasUnread => unreadCount > 0;

  // Ajouter un listener pour les nouvelles notifications
  void addNotificationListener(Function(NotificationModel) listener) {
    _listeners.add(listener);
  }

  void removeNotificationListener(Function(NotificationModel) listener) {
    _listeners.remove(listener);
  }

  // Ajouter une nouvelle notification
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);

    // Limiter à 100 notifications max
    if (_notifications.length > 100) {
      _notifications.removeRange(100, _notifications.length);
    }

    // Notifier les listeners
    for (final listener in _listeners) {
      listener(notification);
    }

    // Vibration et son système
    _playNotificationSound();

    notifyListeners();
  }

  // Notifications spécifiques pour les commandes
  void notifyNewOrder(String orderId, String customerName, double amount) {
    addNotification(
      NotificationModel(
        id: 'order_${orderId}_new',
        title: 'Nouvelle commande reçue !',
        message: 'Commande de $customerName (${amount.toInt()} FCFA)',
        type: NotificationType.orderReceived,
        createdAt: DateTime.now(),
        data: {
          'orderId': orderId,
          'customerName': customerName,
          'amount': amount,
        },
      ),
    );
  }

  void notifyOrderConfirmed(String orderId, String artisanName) {
    addNotification(
      NotificationModel(
        id: 'order_${orderId}_confirmed',
        title: 'Commande confirmée !',
        message: '$artisanName a confirmé votre commande',
        type: NotificationType.orderConfirmed,
        createdAt: DateTime.now(),
        data: {'orderId': orderId, 'artisanName': artisanName},
      ),
    );
  }

  void notifyOrderReady(String orderId, String artisanName) {
    addNotification(
      NotificationModel(
        id: 'order_${orderId}_ready',
        title: 'Commande prête !',
        message: 'Votre commande chez $artisanName est prête pour le retrait',
        type: NotificationType.orderReady,
        createdAt: DateTime.now(),
        data: {'orderId': orderId, 'artisanName': artisanName},
      ),
    );
  }

  void notifyOrderDelivered(String orderId, String customerName) {
    addNotification(
      NotificationModel(
        id: 'order_${orderId}_delivered',
        title: 'Commande livrée !',
        message: 'Commande de $customerName marquée comme livrée',
        type: NotificationType.orderDelivered,
        createdAt: DateTime.now(),
        data: {'orderId': orderId, 'customerName': customerName},
      ),
    );
  }

  void notifyPaymentReceived(String orderId, double amount) {
    addNotification(
      NotificationModel(
        id: 'payment_${orderId}',
        title: 'Paiement reçu !',
        message: 'Vous avez reçu ${amount.toInt()} FCFA',
        type: NotificationType.paymentReceived,
        createdAt: DateTime.now(),
        data: {'orderId': orderId, 'amount': amount},
      ),
    );
  }

  void notifyNewMessage(String chatId, String senderName, String preview) {
    addNotification(
      NotificationModel(
        id: 'message_${chatId}_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Nouveau message',
        message: '$senderName: $preview',
        type: NotificationType.newMessage,
        createdAt: DateTime.now(),
        data: {'chatId': chatId, 'senderName': senderName},
      ),
    );
  }

  void notifyProductLiked(
    String productId,
    String productName,
    String userName,
  ) {
    addNotification(
      NotificationModel(
        id: 'like_${productId}_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Produit aimé !',
        message: '$userName aime votre produit "$productName"',
        type: NotificationType.productLiked,
        createdAt: DateTime.now(),
        data: {
          'productId': productId,
          'productName': productName,
          'userName': userName,
        },
      ),
    );
  }

  void notifyNewReview(String productId, String productName, int rating) {
    addNotification(
      NotificationModel(
        id: 'review_${productId}_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Nouvel avis reçu !',
        message: 'Votre produit "$productName" a reçu $rating étoiles',
        type: NotificationType.reviewReceived,
        createdAt: DateTime.now(),
        data: {
          'productId': productId,
          'productName': productName,
          'rating': rating,
        },
      ),
    );
  }

  // Marquer une notification comme lue
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  // Marquer toutes comme lues
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  // Supprimer une notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  // Supprimer toutes les notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  // Supprimer les anciennes notifications (plus de 30 jours)
  void cleanupOldNotifications() {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    _notifications.removeWhere((n) => n.createdAt.isBefore(cutoffDate));
    notifyListeners();
  }

  // Jouer le son de notification
  void _playNotificationSound() {
    if (!kIsWeb) {
      HapticFeedback.lightImpact();
    }
  }

  // Initialiser avec des notifications de test (pour le développement)
  void initializeTestNotifications() {
    // Notifications de test pour démonstration
    addNotification(
      NotificationModel(
        id: 'test_1',
        title: 'Bienvenue sur N\'SAPKA !',
        message: 'Découvrez toutes les fonctionnalités de notifications',
        type: NotificationType.newMessage,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    );

    addNotification(
      NotificationModel(
        id: 'test_2',
        title: 'Nouvelle commande !',
        message: 'Vous avez reçu une commande de Marie Dupont',
        type: NotificationType.orderReceived,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        data: {
          'orderId': 'ORDER_123',
          'customerName': 'Marie Dupont',
          'amount': 25000.0,
        },
      ),
    );
  }

  // Méthode pour simuler des notifications temps réel
  void simulateRealtimeNotifications() {
    // Cette méthode peut être appelée périodiquement pour simuler
    // des notifications en temps réel pendant le développement

    final random = DateTime.now().millisecond;
    if (random % 4 == 0) {
      notifyNewOrder('ORDER_${random}', 'Client Test', 15000.0);
    } else if (random % 4 == 1) {
      notifyOrderConfirmed('ORDER_123', 'Artisan Test');
    } else if (random % 4 == 2) {
      notifyNewMessage(
        'CHAT_${random}',
        'Marie',
        'Bonjour, votre produit est-il disponible ?',
      );
    } else {
      notifyProductLiked('PRODUCT_${random}', 'Masque Baoulé', 'Jean Kouassi');
    }
  }
}
