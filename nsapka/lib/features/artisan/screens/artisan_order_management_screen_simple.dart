// filepath: lib/features/artisan/screens/artisan_order_management_screen_simple.dart
// Version simplifiée pour tester l'acceptation des commandes
// Interface basique pour que les artisans confirment leurs commandes
// RELEVANT FILES: order_model.dart, api_service.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/api_service.dart';

class ArtisanOrderManagementScreenSimple extends StatefulWidget {
  const ArtisanOrderManagementScreenSimple({super.key});

  @override
  State<ArtisanOrderManagementScreenSimple> createState() =>
      _ArtisanOrderManagementScreenSimpleState();
}

class _ArtisanOrderManagementScreenSimpleState
    extends State<ArtisanOrderManagementScreenSimple>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderModel> allOrders = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _createTestOrder();
  }

  void _createTestOrder() {
    final testOrder = OrderModel(
      id: 'ORDER001',
      buyerId: 'buyer123',
      buyerName: 'Client Test',
      artisanId: 'artisan456',
      artisanName: 'Mon Artisan',
      items: [
        OrderItem(
          productId: 'product1',
          productName: 'Produit Artisanal',
          productImage: '',
          quantity: 1,
          price: 15000.0,
        ),
      ],
      subtotal: 15000.0,
      deliveryFee: 2000.0,
      total: 17000.0,
      status: OrderStatus.pending,
      paymentStatus: PaymentStatus.pending,
      paymentMethod: 'Orange Money',
      transactionId: null,
      createdAt: DateTime.now(),
      confirmedAt: null,
      deliveredAt: null,
      deliveryAddress: '123 Rue Test, Abidjan',
      deliveryPhone: '+225 01 02 03 04 05',
      trackingNumber: null,
      tracking: [],
    );

    setState(() {
      allOrders = [testOrder];
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderModel> _getOrdersByStatus(OrderStatus status) {
    return allOrders.where((order) => order.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestion Commandes'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'En attente', icon: Icon(Icons.access_time, size: 20)),
            Tab(text: 'Confirmées', icon: Icon(Icons.check_circle, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(OrderStatus.pending),
          _buildOrdersList(OrderStatus.confirmed),
        ],
      ),
    );
  }

  Widget _buildOrdersList(OrderStatus status) {
    final orders = _getOrdersByStatus(status);

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == OrderStatus.pending ? Icons.inbox : Icons.check_circle,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              status == OrderStatus.pending
                  ? 'Aucune commande en attente'
                  : 'Aucune commande confirmée',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(orders[index]);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        // Border spécial pour nouvelles commandes
        border: order.status == OrderStatus.pending
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande #${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Info client
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    order.buyerName[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.buyerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      order.deliveryAddress,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Articles
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.quantity}x ${item.productName}'),
                    Text(
                      '${(item.price * item.quantity).toInt()} FCFA',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${order.total.toInt()} FCFA',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Actions
            if (order.status == OrderStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rejectOrder(order.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Rejeter'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _confirmOrder(order.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('✅ ACCEPTER'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOrder(String orderId) async {
    // Simuler un délai
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    // Mettre à jour le statut
    final orderIndex = allOrders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      setState(() {
        allOrders[orderIndex] = allOrders[orderIndex].copyWith(
          status: OrderStatus.confirmed,
        );
        isLoading = false;
      });

      // Afficher confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Commande acceptée avec succès !'),
          backgroundColor: AppColors.success,
        ),
      );

      // Changer d'onglet automatiquement
      _tabController.animateTo(1);
    }
  }

  Future<void> _rejectOrder(String orderId) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Rejeter la commande'),
            content: const Text(
              'Êtes-vous sûr de vouloir rejeter cette commande ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text(
                  'Rejeter',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      setState(() {
        allOrders.removeWhere((order) => order.id == orderId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Commande rejetée'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      default:
        return 'Inconnu';
    }
  }
}
