// filepath: lib/features/orders/screens/order_confirmation_screen.dart
// Écran de confirmation de commande après paiement réussi
// Affiche les détails de la commande et les prochaines étapes
// RELEVANT FILES: payment_screen.dart, order_model.dart, api_service.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/order_model.dart';
import 'order_tracking_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String orderId;
  final double amount;

  const OrderConfirmationScreen({
    super.key,
    required this.orderId,
    required this.amount,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  OrderModel? order;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _loadOrderDetails();
    _animationController.forward();
  }

  Future<void> _loadOrderDetails() async {
    try {
      // Mock: Pour la démo, créer une commande fictive
      final mockOrder = OrderModel(
        id: widget.orderId,
        buyerId: 'buyer1',
        buyerName: 'Client Test',
        artisanId: 'artisan1',
        artisanName: 'Artisan Test',
        items: [
          OrderItem(
            productId: '1',
            productName: 'Produit Test',
            productImage: '',
            quantity: 1,
            price: widget.amount,
          ),
        ],
        subtotal: widget.amount,
        deliveryFee: 2000.0,
        total: widget.amount + 2000.0,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        paymentMethod: 'orange_money',
        createdAt: DateTime.now(),
        deliveryAddress: 'Adresse de test',
        tracking: [],
      );

      if (mounted) {
        setState(() {
          order = mockOrder;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement commande: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isLoading
            ? _buildLoadingState()
            : order == null
            ? _buildErrorState()
            : _buildConfirmationContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Chargement de votre commande...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'error_loading_order'.tr(),
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('back'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationContent() {
    return Column(
      children: [
        // Header avec animation de succès
        _buildSuccessHeader(),

        // Contenu scrollable
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations de commande
                _buildOrderInfo(),

                const SizedBox(height: 24),

                // Articles commandés
                _buildOrderItems(),

                const SizedBox(height: 24),

                // Résumé des prix
                _buildPriceSummary(),

                const SizedBox(height: 24),

                // Prochaines étapes
                _buildNextSteps(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Boutons d'action
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.success.withOpacity(0.1), AppColors.background],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          // Animation de succès
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 60),
            ),
          ),

          const SizedBox(height: 24),

          // Texte de confirmation
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Text(
                  'order_confirmed'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'order_confirmation_message'.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'order_details'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildInfoRow('order_number'.tr(), order!.id),
          _buildInfoRow('order_date'.tr(), _formatDate(order!.createdAt)),
          _buildInfoRow(
            'payment_method'.tr(),
            _getPaymentMethodName(order!.paymentMethod),
          ),
          _buildInfoRow('delivery_address'.tr(), order!.deliveryAddress),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'ordered_items'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...order!.items.map((item) => _buildOrderItem(item)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Image produit
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.productImage.isNotEmpty ? item.productImage : '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  color: AppColors.border,
                  child: const Icon(Icons.image),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // Détails produit
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
                ),
                Text(
                  '${'quantity'.tr()}: ${item.quantity}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Prix
          Text(
            '${(item.price * item.quantity).toInt()} FCFA',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'order_summary'.tr(),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          _buildPriceRow('subtotal'.tr(), order!.subtotal),
          _buildPriceRow('delivery_fee'.tr(), order!.deliveryFee),

          const Divider(height: 24),

          _buildPriceRow('total'.tr(), order!.total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '${amount.toInt()} FCFA',
            style: TextStyle(
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextSteps() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'next_steps'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildStepItem(
            Icons.check_circle,
            'order_received'.tr(),
            'order_received_desc'.tr(),
            isCompleted: true,
          ),
          _buildStepItem(
            Icons.hourglass_empty,
            'awaiting_confirmation'.tr(),
            'awaiting_confirmation_desc'.tr(),
          ),
          _buildStepItem(
            Icons.build,
            'preparation'.tr(),
            'preparation_desc'.tr(),
          ),
          _buildStepItem(
            Icons.local_shipping,
            'delivery'.tr(),
            'delivery_desc'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    IconData icon,
    String title,
    String description, {
    bool isCompleted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success
                  : AppColors.textSecondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isCompleted ? Colors.white : AppColors.textSecondary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? AppColors.success
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton principal - Suivre commande
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderTrackingScreen(order: order!),
                  ),
                );
              },
              icon: const Icon(Icons.track_changes),
              label: Text('track_order'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bouton secondaire - Retour à l'accueil
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: Text('back_to_home'.tr()),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'orange_money':
        return 'Orange Money';
      case 'mtn_momo':
        return 'MTN Mobile Money';
      case 'wave':
        return 'Wave';
      default:
        return method;
    }
  }
}
