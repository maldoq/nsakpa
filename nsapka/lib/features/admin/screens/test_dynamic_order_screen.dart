// filepath: lib/features/admin/screens/test_dynamic_order_screen.dart
// Écran de test pour créer des commandes dynamiques depuis l'admin
// Permet de vérifier que le système d'ordre dynamique fonctionne
// RELEVANT FILES: order_service.dart, admin_order_management_screen.dart

import 'package:flutter/material.dart';
import '../../../core/services/order_service.dart';
import '../../../core/models/order_model.dart';
import '../../../core/constants/app_colors.dart';

class TestDynamicOrderScreen extends StatelessWidget {
  const TestDynamicOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Test Commandes Dynamiques'),
        backgroundColor: AppColors.primary,
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
                    Icon(Icons.info_outline, color: Colors.blue, size: 40),
                    SizedBox(height: 12),
                    Text(
                      'Statistiques des Commandes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Visualisez ici les commandes réelles créées par vos clients',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Boutons pour créer des commandes de test
            ElevatedButton.icon(
              onPressed: () => _createTestOrder(context, OrderStatus.pending),
              icon: const Icon(Icons.pending),
              label: const Text('➕ Commande En Attente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () => _createTestOrder(context, OrderStatus.confirmed),
              icon: const Icon(Icons.check_circle),
              label: const Text('✅ Commande Confirmée'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () => _createTestOrder(context, OrderStatus.delivered),
              icon: const Icon(Icons.local_shipping),
              label: const Text('🚚 Commande Livrée'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 20),

            // Afficher les stats actuelles
            StreamBuilder<Map<String, int>>(
              stream: _getStatsStream(),
              builder: (context, snapshot) {
                final stats = snapshot.data ?? {};
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '📊 Statistiques Actuelles',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Total',
                              stats['total'] ?? 0,
                              Colors.grey,
                            ),
                            _buildStatItem(
                              'En attente',
                              stats['pending'] ?? 0,
                              Colors.orange,
                            ),
                            _buildStatItem(
                              'Confirmées',
                              stats['confirmed'] ?? 0,
                              Colors.blue,
                            ),
                            _buildStatItem(
                              'Livrées',
                              stats['delivered'] ?? 0,
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Bouton pour aller voir l'admin
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Retourner à l'admin pour voir les commandes
              },
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('👀 Voir dans Admin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createTestOrder(BuildContext context, OrderStatus status) {
    final orderService = OrderService();
    final orderId = 'TEST_ADMIN_${DateTime.now().millisecondsSinceEpoch}';

    final testOrder = OrderModel(
      id: orderId,
      buyerId: 'test_buyer_${DateTime.now().millisecondsSinceEpoch}',
      buyerName:
          'Client Test ${DateTime.now().minute}:${DateTime.now().second}',
      artisanId: 'test_artisan_001',
      artisanName: 'Artisan de Test',
      items: [
        OrderItem(
          productId: 'test_product_1',
          productName: 'Produit Test ${status.toString().split('.').last}',
          productImage: '',
          quantity: 1,
          price: 15000.0,
        ),
      ],
      subtotal: 15000.0,
      deliveryFee: 2000.0,
      total: 17000.0,
      status: status,
      paymentStatus: PaymentStatus.released,
      paymentMethod: 'Test',
      transactionId: 'TEST_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      confirmedAt: status != OrderStatus.pending ? DateTime.now() : null,
      deliveredAt: status == OrderStatus.delivered ? DateTime.now() : null,
      deliveryAddress: 'Adresse de test',
      deliveryPhone: '+225 00 00 00 00 00',
      trackingNumber: status == OrderStatus.delivered ? 'TRACK_TEST' : null,
      tracking: [],
    );

    // Ajouter la commande au service
    orderService.addOrder(testOrder);

    // Afficher confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Commande test créée: ${testOrder.id}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Stream pour écouter les stats en temps réel
  Stream<Map<String, int>> _getStatsStream() {
    return Stream.periodic(
      const Duration(seconds: 1),
      (count) => OrderService().getOrderStatistics(),
    );
  }
}
