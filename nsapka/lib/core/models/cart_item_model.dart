import 'product_model.dart';
import 'package:flutter/material.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  int quantity;
  final DateTime addedAt;

  CartItemModel({
    required this.id,
    required this.product,
    this.quantity = 1,
    required this.addedAt,
  });

  double get totalPrice => product.price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      id: id,
      product: product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt,
    );
  }
}
