import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/order_model.dart';

String getOrderStatusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'En attente';
    case OrderStatus.confirmed:
      return 'Confirmée';
    case OrderStatus.preparing:
      return 'En préparation';
    case OrderStatus.readyForPickup:
      return 'Prête';
    case OrderStatus.inTransit:
      return 'En livraison';
    case OrderStatus.delivered:
      return 'Livrée';
    case OrderStatus.cancelled:
      return 'Annulée';
  }
}

Color getOrderStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return Colors.grey;
    case OrderStatus.confirmed:
      return AppColors.info;
    case OrderStatus.preparing:
      return AppColors.warning;
    case OrderStatus.readyForPickup:
      return const Color(0xFF2196F3);
    case OrderStatus.inTransit:
      return const Color(0xFF9C27B0);
    case OrderStatus.delivered:
      return AppColors.success;
    case OrderStatus.cancelled:
      return AppColors.error;
  }
}

String formatOrderDate(DateTime date) {
  final months = [
    'janv.', 'févr.', 'mars', 'avril', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
