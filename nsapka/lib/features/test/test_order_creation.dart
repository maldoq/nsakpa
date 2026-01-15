// filepath: lib/features/test/test_order_creation.dart
// Page de test pour vérifier la création dynamique de commandes
// Permet de tester le flux complet : achat → commande → artisan → admin
// RELEVANT FILES: order_service.dart, payment_screen.dart, cart_item_model.dart, product_model.dart

import 'package:flutter/material.dart';
import '../../core/services/order_service.dart';
import '../../core/models/order_model.dart';
import '../../core/models/cart_item_model.dart';
import '../../core/models/product_model.dart';
import '../payment/screens/payment_screen.dart';

class TestOrderCreationScreen extends StatelessWidget {
  const TestOrderCreationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Test Commandes Dynamiques'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 40),
                    SizedBox(height: 12),
                    Text(
                      'Test du Système de Commandes Dynamiques',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Teste le flux: Client achète → Commande créée → Artisan notifié → Admin voit tout',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bouton pour aller au paiement direct
            ElevatedButton.icon(
              onPressed: () => _goToPayment(context),
              icon: const Icon(Icons.payment),
              label: const Text('💳 Simuler un Achat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
              ),
            ),

            const SizedBox(height: 16),

            // Bouton pour voir les commandes existantes
            StreamBuilder<List<OrderModel>>(
              stream: _getOrdersStream(),
              builder: (context, snapshot) {
                final orders = snapshot.data ?? [];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '📊 Commandes Actuelles: ${orders.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (orders.isEmpty)
                          const Text(
                            'Aucune commande. Faites un test d\'achat !',
                            style: TextStyle(color: Colors.grey),
                          )
                        else
                          ...orders.map(
                            (order) => ListTile(
                              leading: Icon(
                                _getStatusIcon(order.status),
                                color: _getStatusColor(order.status),
                              ),
                              title: Text(order.buyerName),
                              subtitle: Text(
                                '${order.total?.toStringAsFixed(0) ?? "0"} FCFA',
                              ),
                              trailing: Text(
                                order.status.toString().split('.').last,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _goToPayment(BuildContext context) {
    // Créer un produit de test
    final testProduct = ProductModel(
      id: 'test_product_1',
      name: 'Masque Baoulé Test',
      description: 'Produit de test pour système commandes',
      price: 15000,
      stock: 10,
      category: 'Masques',
      images: ['test_image.jpg'],
      artisanId: 'artisan_test_001',
      artisanName: 'Kouamé l\'Artisan',
      createdAt: DateTime.now(),
    );

    // Créer un item de panier de test
    final cartItem = CartItemModel(
      id: 'cart_test_1',
      product: testProduct,
      quantity: 2,
      addedAt: DateTime.now(),
    );

    // Naviguer vers PaymentScreen avec les données de test
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          amount: 30000, // 15000 x 2
          orderId: 'TEST_${DateTime.now().millisecondsSinceEpoch}',
          cartItems: [cartItem],
          deliveryAddress: 'Cocody, Angré 8ème tranche',
          deliveryPhone: '+225 07 12 34 56 78',
          buyerName: 'Client Test Dynamique',
          artisanId: 'artisan_test_001',
          artisanName: 'Kouamé l\'Artisan',
        ),
      ),
    );
  }

  // Stream pour écouter les changements de commandes
  Stream<List<OrderModel>> _getOrdersStream() {
    return Stream.periodic(
      const Duration(seconds: 1),
      (count) => OrderService().allOrders,
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.preparing:
        return Icons.build;
      case OrderStatus.readyForPickup:
        return Icons.inventory;
      case OrderStatus.delivered:
        return Icons.check_circle_outline;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.inTransit:
        return Icons.local_shipping;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.purple;
      case OrderStatus.readyForPickup:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.inTransit:
        return Colors.blue;
    }
  }
}
