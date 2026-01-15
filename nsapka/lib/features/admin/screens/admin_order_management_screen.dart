// filepath: lib/features/admin/screens/admin_order_management_screen.dart
// Écran de gestion des commandes pour l'administrateur
// Interface complète pour voir et gérer toutes les commandes du système
// RELEVANT FILES: order_model.dart, api_service.dart, admin_home_screen.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/order_service.dart';

class AdminOrderManagementScreen extends StatefulWidget {
  const AdminOrderManagementScreen({super.key});

  @override
  State<AdminOrderManagementScreen> createState() =>
      _AdminOrderManagementScreenState();
}

class _AdminOrderManagementScreenState extends State<AdminOrderManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderModel> allOrders = [];
  bool isLoading = false;
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _orderService.addListener(_onOrdersUpdated);
    _loadAllOrders();
  }

  void _onOrdersUpdated() {
    if (mounted) {
      setState(() {
        allOrders = _orderService.allOrders;
      });
    }
  }

  Future<void> _loadAllOrders() async {
    setState(() => isLoading = true);
    try {
      // Essayer de charger depuis l'API
      final ordersData = await ApiService.getAllOrders();

      List<dynamic> ordersList = [];
      if (ordersData is List) {
        ordersList = ordersData;
      }

      final orders = ordersList
          .map((data) => OrderModel.fromJson(data))
          .toList();

      // Si pas de commandes de l'API, utiliser les commandes du service centralisé
      if (orders.isEmpty) {
        // Ne pas réinitialiser le service, juste récupérer les commandes existantes
        if (mounted) {
          setState(() {
            allOrders =
                _orderService.allOrders; // Récupérer les commandes dynamiques
            isLoading = false;
          });
        }
      } else {
        // Si on a des données de l'API, les ajouter au service
        for (final order in orders) {
          _orderService.addOrder(order);
        }
        if (mounted) {
          setState(() {
            allOrders = _orderService.allOrders;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Erreur chargement toutes commandes: $e');
      // En cas d'erreur, utiliser les commandes existantes du service
      if (mounted) {
        setState(() {
          allOrders =
              _orderService.allOrders; // Garder les commandes dynamiques
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _orderService.removeListener(_onOrdersUpdated);
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
        title: const Text('🛍️ Gestion Commandes Admin'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllOrders,
            tooltip: 'Actualiser',
          ),
          // Stats générales
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Total: ${allOrders.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: [
            Tab(
              text:
                  'En attente (${_getOrdersByStatus(OrderStatus.pending).length})',
              icon: const Icon(Icons.access_time, size: 18),
            ),
            Tab(
              text:
                  'Confirmées (${_getOrdersByStatus(OrderStatus.confirmed).length})',
              icon: const Icon(Icons.check_circle, size: 18),
            ),
            Tab(
              text:
                  'Préparation (${_getOrdersByStatus(OrderStatus.preparing).length})',
              icon: const Icon(Icons.build, size: 18),
            ),
            Tab(
              text:
                  'Prêtes (${_getOrdersByStatus(OrderStatus.readyForPickup).length})',
              icon: const Icon(Icons.inventory, size: 18),
            ),
            Tab(
              text:
                  'Livrées (${_getOrdersByStatus(OrderStatus.delivered).length})',
              icon: const Icon(Icons.done_all, size: 18),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(OrderStatus.pending),
                _buildOrdersList(OrderStatus.confirmed),
                _buildOrdersList(OrderStatus.preparing),
                _buildOrdersList(OrderStatus.readyForPickup),
                _buildOrdersList(OrderStatus.delivered),
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
              _getStatusIcon(status),
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune commande ${_getStatusText(status).toLowerCase()}',
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
        return _buildAdminOrderCard(orders[index]);
      },
    );
  }

  Widget _buildAdminOrderCard(OrderModel order) {
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec ID commande et statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🛒 Commande #${order.id}',
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

            const SizedBox(height: 12),

            // Info client et artisan
            Row(
              children: [
                // Client
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '👤 Client:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        order.buyerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Artisan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🎨 Artisan:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        order.artisanName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Total et date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💰 Total:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${order.total.toInt()} FCFA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '📅 Créée le:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _formatDate(order.createdAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Actions admin
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewOrderDetails(order),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Détails'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.info,
                      side: const BorderSide(color: AppColors.info),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _contactUser(order),
                    icon: const Icon(Icons.message, size: 16),
                    label: const Text('Contact'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📋 Détails Commande #${order.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('👤 Client', order.buyerName),
              _buildDetailRow('🎨 Artisan', order.artisanName),
              _buildDetailRow(
                '📱 Téléphone',
                order.deliveryPhone ?? 'Non renseigné',
              ),
              _buildDetailRow('📍 Adresse', order.deliveryAddress),
              _buildDetailRow('💰 Montant', '${order.total.toInt()} FCFA'),
              _buildDetailRow('📱 Paiement', order.paymentMethod),
              _buildDetailRow('📅 Créée le', _formatDate(order.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _contactUser(OrderModel order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📞 Contact avec ${order.buyerName}'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.access_time;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.preparing:
        return Icons.build;
      case OrderStatus.readyForPickup:
        return Icons.inventory;
      case OrderStatus.delivered:
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.preparing:
        return AppColors.accent;
      case OrderStatus.readyForPickup:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
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
      case OrderStatus.preparing:
        return 'En préparation';
      case OrderStatus.readyForPickup:
        return 'Prête';
      case OrderStatus.inTransit:
        return 'En transit';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
