import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/cart_item_model.dart';
import '../../delivery/screens/delivery_tracking_screen.dart';
import '../../orders/screens/order_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String orderId;
  final List<CartItemModel>? cartItems; // Ajout des articles
  final String? deliveryAddress; // Ajout de l'adresse
  final String? deliveryPhone; // Ajout du téléphone
  final String? buyerName; // Nom du client
  final String? artisanId; // ID de l'artisan
  final String? artisanName; // Nom de l'artisan

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.orderId,
    this.cartItems,
    this.deliveryAddress,
    this.deliveryPhone,
    this.buyerName,
    this.artisanId,
    this.artisanName,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedMethod = 'orange_money';
  final TextEditingController phoneController = TextEditingController();
  bool isProcessing = false;
  List<PaymentMethod> paymentMethods = [];
  bool isLoadingMethods = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final methods = await ApiService.getPaymentMethods();
      if (methods.isNotEmpty) {
        setState(() {
          paymentMethods = methods
              .map(
                (m) => PaymentMethod(
                  id: m['code'] ?? m['id'] ?? '',
                  name: m['name'] ?? '',
                  icon: m['icon'] ?? '💳',
                  description: m['description'] ?? '',
                  color: _getColorForMethod(m['code'] ?? ''),
                ),
              )
              .toList();
          if (paymentMethods.isNotEmpty) {
            selectedMethod = paymentMethods.first.id;
          }
          isLoadingMethods = false;
        });
      } else {
        // Méthodes par défaut si l'API ne retourne rien
        setState(() {
          paymentMethods = _getDefaultPaymentMethods();
          isLoadingMethods = false;
        });
      }
    } catch (e) {
      // En cas d'erreur, utiliser les méthodes par défaut
      setState(() {
        paymentMethods = _getDefaultPaymentMethods();
        isLoadingMethods = false;
      });
    }
  }

  List<PaymentMethod> _getDefaultPaymentMethods() {
    return [
      PaymentMethod(
        id: 'orange_money',
        name: 'Orange Money',
        icon: '🟠',
        description: 'Paiement sécurisé via Orange Money',
        color: AppColors.warning,
      ),
      PaymentMethod(
        id: 'mtn_money',
        name: 'MTN Mobile Money',
        icon: '🟡',
        description: 'Paiement sécurisé via MTN',
        color: Color(0xFFFFCB05),
      ),
      PaymentMethod(
        id: 'moov_money',
        name: 'Moov Money',
        icon: '🔵',
        description: 'Paiement sécurisé via Moov',
        color: Color(0xFF009FE3),
      ),
      PaymentMethod(
        id: 'wave',
        name: 'Wave',
        icon: '💙',
        description: 'Paiement instantané via Wave',
        color: Color(0xFF00D9FF),
      ),
    ];
  }

  Color _getColorForMethod(String code) {
    switch (code) {
      case 'orange_money':
        return AppColors.warning;
      case 'mtn_money':
        return Color(0xFFFFCB05);
      case 'moov_money':
        return Color(0xFF009FE3);
      case 'wave':
        return Color(0xFF00D9FF);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paiement sécurisé'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Montant
            _buildAmountCard(),

            // Sécurité Escrow
            _buildEscrowInfo(),

            // Méthodes de paiement
            _buildPaymentMethods(),

            // Formulaire
            _buildPaymentForm(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Montant à payer',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.amount.toStringAsFixed(0)} FCFA',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commande #${widget.orderId}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textWhite.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscrowInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: AppColors.success,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paiement Sécurisé (Escrow)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Votre argent est protégé',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildEscrowStep(
                  '1',
                  'Vous payez',
                  'Votre argent est mis en sécurité',
                  Icons.payment,
                ),
                _buildEscrowStep(
                  '2',
                  'Artisan prépare',
                  'L\'artisan reçoit la commande',
                  Icons.construction,
                ),
                _buildEscrowStep(
                  '3',
                  'Vous recevez',
                  'Confirmez la réception du produit',
                  Icons.inventory_2,
                ),
                _buildEscrowStep(
                  '4',
                  'Artisan payé',
                  'L\'argent est libéré à l\'artisan',
                  Icons.check_circle,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscrowStep(
    String number,
    String title,
    String description,
    IconData icon, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choisissez votre méthode de paiement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (isLoadingMethods)
            const Center(child: CircularProgressIndicator())
          else
            ...paymentMethods.map((method) => _buildPaymentMethodCard(method)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final isSelected = selectedMethod == method.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = method.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? method.color.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? method.color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: method.color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(method.icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? method.color : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: method.color, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations de paiement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Numéro de téléphone',
              hintText: 'Ex: 07 00 00 00 00',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.background,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Vous recevrez un code de confirmation sur ce numéro',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: isProcessing ? null : _processPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: AppColors.textWhite,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: isProcessing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.textWhite,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Payer ${widget.amount.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _processPayment() async {
    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre numéro de téléphone'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      // 🔥 ICI on appelle ton vrai backend
      final result = await RemoteApiService.payOrder(
        orderId: widget.orderId,
        paymentMethod: selectedMethod,
        phoneNumber: phoneController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        isProcessing = false;
      });

      if (result != null && result['success'] == true) {
        // 🎉 CRÉER LA COMMANDE DYNAMIQUE DANS LE SYSTÈME
        await _createDynamicOrder();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement effectué avec succès')),
        );

        _showSuccessDialog(); // ➜ popup + redirection
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec du paiement'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  /// 🎯 CRÉER UNE COMMANDE DYNAMIQUE DANS LE SYSTÈME
  Future<void> _createDynamicOrder() async {
    try {
      if (widget.cartItems == null || widget.cartItems!.isEmpty) {
        print('❌ Pas d\'articles dans le panier');
        return;
      }

      // Calculer le prix total
      double totalPrice = widget.cartItems!.fold(
        0.0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

      // Générer ID unique pour la commande
      String orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

      // Récupérer l'utilisateur actuel
      final currentUser = await AuthService.getCurrentUser();

      // Créer la commande
      final newOrder = OrderModel(
        id: orderId,
        buyerId: currentUser?.id ?? 'buyer_unknown',
        buyerName: widget.buyerName ?? 'Client Inconnu',
        artisanId: widget.artisanId ?? '',
        artisanName: widget.artisanName ?? 'Artisan',
        items: widget.cartItems!
            .map(
              (item) => OrderItem(
                productId: item.product.id,
                productName: item.product.name,
                productImage: item.product.images.isNotEmpty
                    ? item.product.images.first
                    : '',
                quantity: item.quantity,
                price: item.product.price,
              ),
            )
            .toList(),
        subtotal: totalPrice,
        deliveryFee: 2500.0, // Frais de livraison par défaut
        total: totalPrice + 2500.0,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.released,
        paymentMethod: selectedMethod == 'orange_money'
            ? 'Orange Money'
            : selectedMethod == 'mtn_money'
            ? 'MTN Money'
            : 'Wave',
        createdAt: DateTime.now(),
        deliveryAddress: widget.deliveryAddress ?? 'Adresse non précisée',
        deliveryPhone: widget.deliveryPhone ?? phoneController.text,
      );

      // 🚀 AJOUTER LA COMMANDE AU SERVICE CENTRAL
      OrderService().addOrder(newOrder);

      print('✅ Commande créée dynamiquement: $orderId');
    } catch (e) {
      print('❌ Erreur création commande: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Paiement réussi !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Votre commande a été confirmée.\nL\'artisan va préparer votre commande.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer dialog
                Navigator.of(context).pop(); // Retour
                Navigator.of(context).pop(); // Retour au catalogue
                // Aller à l'écran de confirmation
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderConfirmationScreen(
                      orderId: widget.orderId,
                      amount: widget.amount,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Suivre ma commande'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final String icon;
  final String description;
  final Color color;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
  });
}
