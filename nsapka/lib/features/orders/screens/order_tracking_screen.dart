import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/order_model.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Suivi de commande'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec statut
            _buildHeader(),
            
            // Timeline de suivi
            _buildTimeline(),
            
            // Informations de livraison
            _buildDeliveryInfo(),
            
            // Informations de paiement
            _buildPaymentInfo(),
            
            // Produits
            _buildProducts(),
            
            // Actions
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: _getStatusGradient(),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Icône de statut
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.textWhite.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(),
                size: 40,
                color: AppColors.textWhite,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Statut
            Text(
              order.statusText,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Numéro de commande
            Text(
              'Commande #${order.id}',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textWhite.withValues(alpha: 0.9),
              ),
            ),
            
            if (order.trackingNumber != null) ...[
              const SizedBox(height: 4),
              Text(
                'Suivi: ${order.trackingNumber}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textWhite.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final allStatuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.readyForPickup,
      OrderStatus.inTransit,
      OrderStatus.delivered,
    ];
    
    final currentIndex = allStatuses.indexOf(order.status);
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suivi détaillé',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          ...List.generate(allStatuses.length, (index) {
            final status = allStatuses[index];
            final isCompleted = index <= currentIndex;
            final isCurrent = index == currentIndex;
            
            return _buildTimelineItem(
              status: status,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLast: index == allStatuses.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required OrderStatus status,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    final tracking = order.tracking.where((t) => t.status == status).firstOrNull;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicateur
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.success : AppColors.border,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent ? AppColors.primary : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                size: 20,
                color: isCompleted ? AppColors.textWhite : AppColors.textSecondary,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: isCompleted ? AppColors.success : AppColors.border,
              ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        // Contenu
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusLabel(status),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                    color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                if (tracking != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    tracking.message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(tracking.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                      if (tracking.location != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tracking.location!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withValues(alpha: 0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping, color: AppColors.primary),
              SizedBox(width: 12),
              Text(
                'Informations de livraison',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoRow(Icons.person, 'Destinataire', order.buyerName),
          _buildInfoRow(Icons.location_on, 'Adresse', order.deliveryAddress),
          if (order.deliveryPhone != null)
            _buildInfoRow(Icons.phone, 'Téléphone', order.deliveryPhone!),
          _buildInfoRow(Icons.store, 'Artisan', order.artisanName),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment, color: AppColors.primary),
              SizedBox(width: 12),
              Text(
                'Informations de paiement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoRow(Icons.credit_card, 'Méthode', order.paymentMethod),
          _buildInfoRow(Icons.security, 'Statut', order.paymentStatusText),
          if (order.transactionId != null)
            _buildInfoRow(Icons.receipt, 'Transaction', order.transactionId!),
          
          const Divider(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sous-total',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                '${order.subtotal.toStringAsFixed(0)} FCFA',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Livraison',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                '${order.deliveryFee.toStringAsFixed(0)} FCFA',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${order.total.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProducts() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shopping_bag, color: AppColors.primary),
              SizedBox(width: 12),
              Text(
                'Produits commandés',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ...order.items.map((item) => _buildProductItem(item)),
        ],
      ),
    );
  }

  Widget _buildProductItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.productImage,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: AppColors.border,
                  child: const Icon(Icons.image, color: AppColors.textSecondary),
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
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantité: ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.totalPrice.toInt()} FCFA',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled)
            ElevatedButton.icon(
              onPressed: () {
                // Contacter le support
              },
              icon: const Icon(Icons.support_agent),
              label: const Text('Contacter le support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          
          if (order.status == OrderStatus.delivered) ...[
            ElevatedButton.icon(
              onPressed: () {
                // Laisser un avis
              },
              icon: const Icon(Icons.star),
              label: const Text('Laisser un avis'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: AppColors.textWhite,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getStatusGradient() {
    switch (order.status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return const LinearGradient(colors: [AppColors.warning, AppColors.accent]);
      case OrderStatus.preparing:
      case OrderStatus.readyForPickup:
        return const LinearGradient(colors: [AppColors.primary, AppColors.secondary]);
      case OrderStatus.inTransit:
        return const LinearGradient(colors: [AppColors.secondary, AppColors.accent]);
      case OrderStatus.delivered:
        return const LinearGradient(colors: [AppColors.success, AppColors.primary]);
      case OrderStatus.cancelled:
        return const LinearGradient(colors: [AppColors.error, AppColors.textSecondary]);
    }
  }

  IconData _getStatusIcon() {
    switch (order.status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.preparing:
        return Icons.construction;
      case OrderStatus.readyForPickup:
        return Icons.inventory;
      case OrderStatus.inTransit:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Commande reçue';
      case OrderStatus.confirmed:
        return 'Confirmée par l\'artisan';
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

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inDays == 0) {
      return 'Aujourd\'hui à ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Hier à ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
