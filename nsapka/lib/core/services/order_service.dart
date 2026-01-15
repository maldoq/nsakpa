// filepath: lib/core/services/order_service.dart
// Service centralisé pour la gestion des commandes
// Permet de synchroniser les commandes entre artisans, clients et admin
// RELEVANT FILES: order_model.dart, api_service.dart

import 'package:flutter/material.dart';
import '../models/order_model.dart';

class OrderService {
  // Singleton pattern
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  // Liste centrale des commandes
  final List<OrderModel> _allOrders = [];

  // Getters
  List<OrderModel> get allOrders => List.unmodifiable(_allOrders);

  // Obtenir les commandes d'un artisan spécifique
  List<OrderModel> getOrdersForArtisan(String artisanId) {
    return _allOrders.where((order) => order.artisanId == artisanId).toList();
  }

  // Obtenir les commandes d'un client spécifique
  List<OrderModel> getOrdersForBuyer(String buyerId) {
    return _allOrders.where((order) => order.buyerId == buyerId).toList();
  }

  // Obtenir les commandes par statut
  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _allOrders.where((order) => order.status == status).toList();
  }

  // Ajouter une nouvelle commande
  void addOrder(OrderModel order) {
    _allOrders.add(order);
    _notifyListeners();
  }

  // Mettre à jour une commande existante
  void updateOrder(String orderId, OrderModel updatedOrder) {
    final index = _allOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _allOrders[index] = updatedOrder;
      _notifyListeners();
    }
  }

  // Supprimer une commande
  void removeOrder(String orderId) {
    _allOrders.removeWhere((order) => order.id == orderId);
    _notifyListeners();
  }

  // Confirmer une commande (artisan accepte)
  void confirmOrder(String orderId) {
    final index = _allOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _allOrders[index] = _allOrders[index].copyWith(
        status: OrderStatus.confirmed,
        confirmedAt: DateTime.now(),
      );
      _notifyListeners();
    }
  }

  // Marquer comme en préparation
  void startPreparingOrder(String orderId) {
    final index = _allOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _allOrders[index] = _allOrders[index].copyWith(
        status: OrderStatus.preparing,
      );
      _notifyListeners();
    }
  }

  // Marquer comme prêt pour le retrait
  void markOrderReady(String orderId) {
    final index = _allOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _allOrders[index] = _allOrders[index].copyWith(
        status: OrderStatus.readyForPickup,
      );
      _notifyListeners();
    }
  }

  // Marquer comme livré
  void deliverOrder(String orderId) {
    final index = _allOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _allOrders[index] = _allOrders[index].copyWith(
        status: OrderStatus.delivered,
        deliveredAt: DateTime.now(),
      );
      _notifyListeners();
    }
  }

  // Annuler une commande
  void cancelOrder(String orderId) {
    final index = _allOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _allOrders[index] = _allOrders[index].copyWith(
        status: OrderStatus.cancelled,
      );
      _notifyListeners();
    }
  }

  // Initialiser le service (liste vide par défaut)
  void initialize() {
    _allOrders.clear();
    print(
      '🚀 OrderService initialisé avec liste vide - prêt pour commandes dynamiques',
    );
  }

  // Listeners pour les mises à jour
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  // Statistiques des commandes
  Map<String, int> getOrderStatistics() {
    return {
      'total': _allOrders.length,
      'pending': getOrdersByStatus(OrderStatus.pending).length,
      'confirmed': getOrdersByStatus(OrderStatus.confirmed).length,
      'preparing': getOrdersByStatus(OrderStatus.preparing).length,
      'ready': getOrdersByStatus(OrderStatus.readyForPickup).length,
      'delivered': getOrdersByStatus(OrderStatus.delivered).length,
      'cancelled': getOrdersByStatus(OrderStatus.cancelled).length,
    };
  }

  // Recherche de commandes
  List<OrderModel> searchOrders(String query) {
    return _allOrders
        .where(
          (order) =>
              order.buyerName.toLowerCase().contains(query.toLowerCase()) ||
              order.artisanName.toLowerCase().contains(query.toLowerCase()) ||
              order.id.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  // Obtenir le revenu total
  double getTotalRevenue() {
    double total = 0;
    for (final order in _allOrders) {
      if (order.status == OrderStatus.delivered) {
        total += order.total ?? 0;
      }
    }
    return total;
  }
}
