enum OrderStatus {
  pending,        // En attente
  confirmed,      // Confirmée
  preparing,      // En préparation
  readyForPickup, // Prête pour enlèvement
  inTransit,      // En transit
  delivered,      // Livrée
  cancelled,      // Annulée
}

enum PaymentStatus {
  pending,    // En attente
  inEscrow,   // En séquestre
  released,   // Libéré
  refunded,   // Remboursé
}

class OrderModel {
  final String id;
  final String buyerId;
  final String buyerName;
  final String artisanId;
  final String artisanName;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String paymentMethod; // Mobile Money, Orange Money, etc.
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? deliveredAt;
  final String deliveryAddress;
  final String? deliveryPhone;
  final String? trackingNumber;
  final List<OrderTracking> tracking;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.artisanId,
    required this.artisanName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.transactionId,
    required this.createdAt,
    this.confirmedAt,
    this.deliveredAt,
    required this.deliveryAddress,
    this.deliveryPhone,
    this.trackingNumber,
    this.tracking = const [],
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente de confirmation';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.preparing:
        return 'En préparation';
      case OrderStatus.readyForPickup:
        return 'Prête pour enlèvement';
      case OrderStatus.inTransit:
        return 'En cours de livraison';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  String get paymentStatusText {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'Paiement en attente';
      case PaymentStatus.inEscrow:
        return 'Paiement sécurisé (Escrow)';
      case PaymentStatus.released:
        return 'Paiement libéré';
      case PaymentStatus.refunded:
        return 'Remboursé';
    }
  }

  double get deliveryProgress {
    switch (status) {
      case OrderStatus.pending:
        return 0.1;
      case OrderStatus.confirmed:
        return 0.2;
      case OrderStatus.preparing:
        return 0.5;
      case OrderStatus.readyForPickup:
        return 0.8;
      case OrderStatus.inTransit:
        return 0.9;
      case OrderStatus.delivered:
        return 1.0;
      case OrderStatus.cancelled:
        return 0.0;
    }
  }

  String get currentStatusDescription {
    switch (status) {
      case OrderStatus.pending:
        return 'Votre commande est en cours de validation par l\'artisan.';
      case OrderStatus.confirmed:
        return 'Votre commande a été confirmée et sera bientôt préparée.';
      case OrderStatus.preparing:
        return 'L\'artisan prépare votre commande avec soin.';
      case OrderStatus.readyForPickup:
        return 'Votre commande est prête pour l\'enlèvement.';
      case OrderStatus.inTransit:
        return 'Votre commande est en cours de livraison.';
      case OrderStatus.delivered:
        return 'Votre commande a été livrée avec succès !';
      case OrderStatus.cancelled:
        return 'Cette commande a été annulée.';
    }
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;
  final String? artisanId;
  final String? artisanName;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
    this.artisanId,
    this.artisanName,
  });

  double get totalPrice => quantity * price;

  get total => null;
}

class OrderTracking {
  final OrderStatus status;
  final String message;
  final DateTime timestamp;
  final String? location;

  OrderTracking({
    required this.status,
    required this.message,
    required this.timestamp,
    this.location,
  });
}
