enum OrderStatus {
  pending, // En attente
  confirmed, // Confirmée
  preparing, // En préparation
  readyForPickup, // Prête pour enlèvement
  inTransit, // En transit
  delivered, // Livrée
  cancelled, // Annulée
}

enum PaymentStatus {
  pending, // En attente
  inEscrow, // En séquestre
  released, // Libéré
  refunded, // Remboursé
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

  // Nouveaux champs pour la réception
  final bool isDelivered;
  final bool isReceived;
  final DateTime? receivedAt;

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
    this.isDelivered = false,
    this.isReceived = false,
    this.receivedAt,
  });

  // Ajoutez cette méthode dans votre OrderModel existant
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return OrderModel(
      id: json['id'].toString(),
      buyerId:
          json['buyer_id']?.toString() ??
          json['buyer']?['id']?.toString() ??
          '',
      buyerName: json['buyer_name'] ?? json['buyer']?['first_name'] ?? '',
      artisanId: json['artisan_id']?.toString() ?? '',
      artisanName: json['artisan_name'] ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      subtotal: parseDouble(json['subtotal'] ?? 0),
      deliveryFee: parseDouble(json['delivery_fee'] ?? 0),
      total: parseDouble(json['total_amount'] ?? 0),
      status: _parseOrderStatus(json['status']),
      paymentStatus: _parsePaymentStatus(json['payment_status'] ?? 'pending'),
      paymentMethod: json['payment_method'] ?? 'orange_money',
      transactionId: json['transaction_id'],
      createdAt: DateTime.parse(json['created_at']),
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      deliveryAddress: json['delivery_address'] ?? '',
      deliveryPhone: json['delivery_phone'],
      trackingNumber: json['tracking_number'],
      tracking:
          (json['tracking'] as List<dynamic>?)
              ?.map((t) => OrderTracking.fromJson(t))
              .toList() ??
          [],
      isDelivered: json['is_delivered'] ?? false,
      isReceived: json['is_received'] ?? false,
      receivedAt: json['received_at'] != null
          ? DateTime.parse(json['received_at'])
          : null,
    );
  }

  static OrderStatus _parseOrderStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
      case 'paid':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready_for_pickup':
      case 'readyforpickup':
        return OrderStatus.readyForPickup;
      case 'in_transit':
      case 'intransit':
      case 'delivering':
        return OrderStatus.inTransit;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static PaymentStatus _parsePaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_escrow':
      case 'inescrow':
        return PaymentStatus.inEscrow;
      case 'released':
        return PaymentStatus.released;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

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

  // Ajoutez dans OrderItem
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return OrderItem(
      productId:
          json['product_id']?.toString() ??
          json['product']?['id']?.toString() ??
          '',
      productName: json['product_name'] ?? json['product']?['name'] ?? '',
      productImage: json['product_image'] ?? json['product']?['image'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: parseDouble(json['price'] ?? json['unit_price'] ?? 0),
      artisanId: json['artisan_id']?.toString(),
      artisanName: json['artisan_name'],
    );
  }

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

  // Ajoutez dans OrderTracking
  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      status: OrderModel._parseOrderStatus(json['status']),
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'],
    );
  }
}

extension OrderModelExtension on OrderModel {
  // Méthode copyWith pour créer une copie modifiée
  OrderModel copyWith({
    String? id,
    String? buyerId,
    String? buyerName,
    String? artisanId,
    String? artisanName,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentMethod,
    String? transactionId,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? deliveredAt,
    String? deliveryAddress,
    String? deliveryPhone,
    String? trackingNumber,
    List<OrderTracking>? tracking,
    bool? isDelivered,
    bool? isReceived,
    DateTime? receivedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      artisanId: artisanId ?? this.artisanId,
      artisanName: artisanName ?? this.artisanName,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryPhone: deliveryPhone ?? this.deliveryPhone,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      tracking: tracking ?? this.tracking,
      isDelivered: isDelivered ?? this.isDelivered,
      isReceived: isReceived ?? this.isReceived,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}
