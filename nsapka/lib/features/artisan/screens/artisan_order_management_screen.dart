// filepath: lib/features/artisan/screens/artisan_order_management_screen.dart
// Interface pour que les artisans gèrent leurs commandes reçues
// Permet de confirmer, préparer et marquer comme prêtes les commandes
// RELEVANT FILES: order_model.dart, api_service.dart, artisan_home_screen.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/notification_service.dart';
import '../../notifications/screens/notifications_screen.dart';

class ArtisanOrderManagementScreen extends StatefulWidget {
  const ArtisanOrderManagementScreen({super.key});

  @override
  State<ArtisanOrderManagementScreen> createState() =>
      _ArtisanOrderManagementScreenState();
}

class _ArtisanOrderManagementScreenState
    extends State<ArtisanOrderManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderModel> allOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);
    try {
      final ordersData = await ApiService.getArtisanOrders();

      // Vérifier que la réponse est bien une liste
      List<dynamic> ordersList = [];
      if (ordersData is List) {
        ordersList = ordersData;
      } else {
        debugPrint('API retourne un type inattendu: ${ordersData.runtimeType}');
        ordersList = []; // Utiliser une liste vide si pas une liste
      }

      final orders = ordersList
          .map((data) => OrderModel.fromJson(data))
          .toList();

      // Afficher les commandes de l'API uniquement (pas de données de test)
      if (mounted) {
        setState(() {
          allOrders = orders; // Peut être vide si pas de commandes réelles
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement commandes artisan: $e');
      // En cas d'erreur API, afficher une liste vide
      if (mounted) {
        setState(() {
          allOrders = []; // Liste vide au lieu de données de test
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fonction de test pour simuler une nouvelle commande
  void _simulateNewOrder() {
    // Créer une nouvelle commande fictive
    final newOrder = OrderModel(
      id: 'ORDER${DateTime.now().millisecondsSinceEpoch}',
      buyerId: 'buyer123',
      buyerName: 'Client Test',
      artisanId: 'artisan456',
      artisanName: 'Mon Artisan',
      items: [
        OrderItem(
          productId: 'product1',
          productName: 'Produit Test',
          productImage: '',
          quantity: 2,
          price: 7500.0,
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
    );
  }

  List<OrderModel> _getOrdersByStatus(OrderStatus status) {
    return allOrders.where((order) => order.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('manage_orders'.tr()),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Désactive le bouton retour
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'refresh'.tr(),
          ),
          // Notifications simples
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'pending'.tr(),
              icon: const Icon(Icons.access_time, size: 20),
            ),
            Tab(
              text: 'confirmed'.tr(),
              icon: const Icon(Icons.check_circle, size: 20),
            ),
            Tab(
              text: 'preparing'.tr(),
              icon: const Icon(Icons.build, size: 20),
            ),
            Tab(
              text: 'ready'.tr(),
              icon: const Icon(Icons.inventory, size: 20),
            ),
          ],
        ),
      ),
      body: isLoading
          ? _buildLoadingState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(OrderStatus.pending),
                _buildOrdersList(OrderStatus.confirmed),
                _buildOrdersList(OrderStatus.preparing),
                _buildOrdersList(OrderStatus.readyForPickup),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.secondary),
          SizedBox(height: 16),
          Text(
            'Chargement de vos commandes...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(OrderStatus status) {
    final orders = _getOrdersByStatus(status);

    if (orders.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppColors.secondary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(OrderStatus status) {
    String message;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        message = 'no_pending_orders'.tr();
        icon = Icons.inbox;
        break;
      case OrderStatus.confirmed:
        message = 'no_confirmed_orders'.tr();
        icon = Icons.check_circle;
        break;
      case OrderStatus.preparing:
        message = 'no_orders_in_preparation'.tr();
        icon = Icons.build;
        break;
      case OrderStatus.readyForPickup:
        message = 'no_orders_ready'.tr();
        icon = Icons.inventory;
        break;
      default:
        message = 'no_orders'.tr();
        icon = Icons.shopping_bag;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec statut et actions
          _buildOrderHeader(order),

          // Informations client
          _buildCustomerInfo(order),

          // Articles
          _buildOrderItems(order),

          // Footer avec montant et actions
          _buildOrderFooter(order),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(order.status).withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'order_number'.tr()} #${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(order.createdAt),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Badge de statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );
  }

  Widget _buildCustomerInfo(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              order.buyerName.isNotEmpty
                  ? order.buyerName[0].toUpperCase()
                  : 'C',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.buyerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.deliveryAddress,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${'ordered_items'.tr()} (${order.items.length})',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...order.items.take(3).map((item) => _buildOrderItem(item)),
          if (order.items.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+ ${order.items.length - 3} autres articles',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              item.productImage.isNotEmpty ? item.productImage : '',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 40,
                  height: 40,
                  color: AppColors.border,
                  child: const Icon(Icons.image, size: 20),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${'quantity'.tr()}: ${item.quantity}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(item.price * item.quantity).toInt()} FCFA',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderFooter(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: Column(
        children: [
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${order.total.toInt()} FCFA',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Information de réception pour les commandes livrées
          if (order.status == OrderStatus.delivered) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: order.isReceived ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: order.isReceived ? Colors.green : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    order.isReceived ? Icons.verified : Icons.pending,
                    color: order.isReceived ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.isReceived
                          ? 'Réception confirmée par le client le ${order.receivedAt != null ? _formatDate(order.receivedAt!) : 'N/A'}'
                          : 'En attente de confirmation de réception par le client',
                      style: TextStyle(
                        color: order.isReceived
                            ? Colors.green[800]
                            : Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Actions selon le statut
          _buildOrderActions(order),
        ],
      ),
    );
  }

  Widget _buildOrderActions(OrderModel order) {
    switch (order.status) {
      case OrderStatus.pending:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _rejectOrder(order.id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.cancel, size: 18),
                label: Text('reject'.tr()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _confirmOrder(order.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 2,
                ),
                icon: const Icon(Icons.check_circle, size: 18),
                label: Text('confirm_order'.tr()),
              ),
            ),
          ],
        );

      case OrderStatus.confirmed:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _startPreparation(order.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: Text('start_preparation'.tr()),
          ),
        );

      case OrderStatus.preparing:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _markReady(order.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('mark_ready'.tr()),
          ),
        );

      case OrderStatus.readyForPickup:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _viewOrderDetails(order),
                child: Text('view_details'.tr()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _markAsDelivered(order.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
                child: Text('mark_delivered'.tr()),
              ),
            ),
          ],
        );

      default:
        return OutlinedButton(
          onPressed: () => _viewOrderDetails(order),
          child: Text('view_details'.tr()),
        );
    }
  }

  Future<void> _confirmOrder(String orderId) async {
    try {
      await _showLoadingDialog();

      // Appel API pour confirmer la commande
      final success = await ApiService.updateOrderStatus(orderId, 'paid');

      Navigator.pop(context);

      if (success) {
        // Recharger les commandes pour rafraîchir l'UI
        _loadOrders();
        _showSuccessMessage('order_confirmed_success'.tr());
      } else {
        _showErrorMessage('Erreur lors de la confirmation');
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorMessage('Erreur lors de la confirmation');
    }
  }

  Future<void> _startPreparation(String orderId) async {
    try {
      await _showLoadingDialog();

      // Appel API pour commencer la préparation
      final success = await ApiService.updateOrderStatus(orderId, 'preparing');

      Navigator.pop(context);

      if (success) {
        // Synchroniser avec OrderService
        OrderService().startPreparingOrder(orderId);
        // Recharger les commandes pour rafraîchir l'UI
        _loadOrders();
        _showSuccessMessage('preparation_started'.tr());
      } else {
        _showErrorMessage('Erreur lors du démarrage');
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorMessage('Erreur lors du démarrage');
    }
  }

  Future<void> _markReady(String orderId) async {
    final confirmed = await _showConfirmationDialog(
      'mark_ready'.tr(),
      'mark_ready_confirmation'.tr(),
    );
    if (!confirmed) return;

    try {
      await _showLoadingDialog();

      // Appel API pour marquer la commande comme prête
      final success = await ApiService.updateOrderStatus(
        orderId,
        'ready_for_pickup',
      );

      Navigator.pop(context);

      if (success) {
        // Synchroniser avec OrderService
        OrderService().markOrderReady(orderId);
        // Recharger les commandes pour rafraîchir l'UI
        _loadOrders();
        _showSuccessMessage('✅ ${'order_ready_success'.tr()}');
      } else {
        _showErrorMessage('error_marking_ready'.tr());
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorMessage('error_marking_ready'.tr());
    }
  }

  Future<void> _rejectOrder(String orderId) async {
    final confirmed = await _showConfirmationDialog(
      'reject_order'.tr(),
      'reject_order_confirmation'.tr(),
    );
    if (!confirmed) return;

    try {
      await _showLoadingDialog();
      // Mock: Simuler le rejet de la commande
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
      _loadOrders();
      _showSuccessMessage('❌ ${'order_rejected_success'.tr()}');
    } catch (e) {
      Navigator.pop(context);
      _showErrorMessage('error_rejecting_order'.tr());
    }
  }

  Future<void> _markAsDelivered(String orderId) async {
    final confirmed = await _showConfirmationDialog(
      'mark_delivered'.tr(),
      'mark_delivered_confirmation'.tr(),
    );
    if (!confirmed) return;

    try {
      await _showLoadingDialog();

      // Appel API pour marquer la commande comme livrée
      final success = await ApiService.updateOrderStatus(orderId, 'delivered');

      Navigator.pop(context);

      if (success) {
        // Synchroniser avec OrderService
        OrderService().deliverOrder(orderId);
        // Recharger les commandes pour rafraîchir l'UI
        _loadOrders();
        _showSuccessMessage('order_delivered_success'.tr());
      } else {
        _showErrorMessage('error_marking_delivered'.tr());
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorMessage('error_marking_delivered'.tr());
    }
  }

  void _viewOrderDetails(OrderModel order) {
    // Pour l'instant, afficher un dialog avec les détails
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${'order_details'.tr()} #${order.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'customer'.tr()}: ${order.buyerName}'),
            Text('${'total'.tr()}: ${order.total.toInt()} FCFA'),
            Text('${'delivery_address'.tr()}: ${order.deliveryAddress}'),
            Text('${'status'.tr()}: ${_getStatusText(order.status)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _showLoadingDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: Text('confirm'.tr()),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
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
        return 'pending'.tr();
      case OrderStatus.confirmed:
        return 'confirmed'.tr();
      case OrderStatus.preparing:
        return 'preparing'.tr();
      case OrderStatus.readyForPickup:
        return 'ready'.tr();
      case OrderStatus.inTransit:
        return 'in_transit'.tr();
      case OrderStatus.delivered:
        return 'delivered'.tr();
      case OrderStatus.cancelled:
        return 'cancelled'.tr();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
