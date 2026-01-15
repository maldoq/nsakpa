// filepath: lib/features/buyer/screens/buyer_orders_screen.dart
// Écran des commandes pour les clients/acheteurs
// Permet aux clients de voir leurs commandes et suivre les statuts
// RELEVANT FILES: order_service.dart, order_model.dart, auth_service.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/order_model.dart';
import '../../../core/constants/app_colors.dart';

class BuyerOrdersScreen extends StatefulWidget {
  const BuyerOrdersScreen({super.key});

  @override
  State<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen> {
  final OrderService _orderService = OrderService();
  List<OrderModel> _myOrders = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _orderService.addListener(_onOrdersUpdated);
  }

  @override
  void dispose() {
    _orderService.removeListener(_onOrdersUpdated);
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUser();
    setState(() {
      _currentUserId = user?.id;
    });
    _loadMyOrders();
  }

  void _loadMyOrders() async {
    if (_currentUserId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Charger les commandes depuis l'API
        final ordersData = await ApiService.getBuyerOrders();

        setState(() {
          _myOrders = ordersData
              .map((data) => OrderModel.fromJson(data))
              .toList();
          _isLoading = false;
        });
      } catch (e) {
        debugPrint('Erreur chargement commandes: $e');
        setState(() {
          _myOrders = [];
          _isLoading = false;
        });
      }
    }
  }

  void _onOrdersUpdated() {
    if (mounted) {
      _loadMyOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛍️ Mes Commandes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myOrders.isEmpty
          ? _buildEmptyState()
          : _buildOrdersList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune commande',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos commandes apparaîtront ici',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    return RefreshIndicator(
      onRefresh: () async => _loadMyOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myOrders.length,
        itemBuilder: (context, index) {
          final order = _myOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec ID et statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Commande ${order.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),

            const SizedBox(height: 12),

            // Artisan
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Artisan: ${order.artisanName}'),
              ],
            ),

            const SizedBox(height: 8),

            // Articles
            Row(
              children: [
                const Icon(Icons.inventory_2, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${order.items.length} article(s): ${order.items.map((item) => item.productName).join(', ')}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Prix total
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${order.total?.toStringAsFixed(0) ?? 'N/A'} FCFA',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Date
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(_formatDate(order.createdAt)),
              ],
            ),

            if (order.deliveredAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Livrée le ${_formatDate(order.deliveredAt!)}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ],

            // Actions selon le statut
            if (order.status == OrderStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.pending, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    'En attente de confirmation par l\'artisan',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],

            if (order.status == OrderStatus.confirmed) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.check, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Commande confirmée - En préparation',
                    style: TextStyle(
                      color: Colors.blue,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],

            if (order.status == OrderStatus.readyForPickup) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping, color: Colors.green),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Prête pour le retrait/livraison !',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (order.status == OrderStatus.inTransit) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping, color: Colors.teal),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'En cours de livraison',
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (order.status == OrderStatus.delivered) ...[
              const SizedBox(height: 12),
              if (!order.isReceived) ...[
                // Bouton pour confirmer la réception
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Commande livrée ! Confirmez la réception.',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _confirmReceived(order.id),
                        icon: const Icon(Icons.thumb_up),
                        label: const Text('Confirmer réception'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Confirmation déjà faite
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Réception confirmée le ${order.receivedAt != null ? _formatDate(order.receivedAt!) : 'N/A'}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        label = 'En attente';
        icon = Icons.pending;
        break;
      case OrderStatus.confirmed:
        color = Colors.blue;
        label = 'Confirmée';
        icon = Icons.check_circle;
        break;
      case OrderStatus.preparing:
        color = Colors.purple;
        label = 'Préparation';
        icon = Icons.build;
        break;
      case OrderStatus.readyForPickup:
        color = Colors.indigo;
        label = 'Prête';
        icon = Icons.local_shipping;
        break;
      case OrderStatus.inTransit:
        color = Colors.teal;
        label = 'En transit';
        icon = Icons.local_shipping;
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        label = 'Livrée';
        icon = Icons.check_circle_outline;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        label = 'Annulée';
        icon = Icons.cancel;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Future<void> _confirmReceived(String orderId) async {
    // Afficher dialog de confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la réception'),
        content: const Text(
          'Confirmez-vous avoir bien reçu cette commande ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Afficher loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Confirmation en cours...'),
          ],
        ),
      ),
    );

    try {
      final success = await ApiService.confirmReceived(orderId);
      Navigator.pop(context); // Fermer loading

      if (success) {
        // Recharger les commandes
        _loadMyOrders();

        // Afficher succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Réception confirmée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la confirmation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Fermer loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la confirmation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Il y a ${difference.inMinutes} min';
      }
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
