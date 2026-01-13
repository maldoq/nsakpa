import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/cart_item_model.dart';
import '../../../core/models/product_model.dart';
import '../../orders/screens/orders_list_screen.dart';
import '../../../core/utils/cart_manager.dart';
import '../../payment/screens/payment_screen.dart';
import '../../../core/services/api_service.dart';

class CartScreen extends StatefulWidget {
  final bool isVisitorMode;

  const CartScreen({super.key, this.isVisitorMode = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  List<CartItemModel> cartItems = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Vérifier si mode visiteur
    if (widget.isVisitorMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLoginDialog();
      });
      return;
    }

    // Utiliser les données du CartManager
    cartItems = CartManager.cartItems;
  }

  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get deliveryFee => 2000; // Frais de livraison fixes (mockés)

  double get total => subtotal + deliveryFee;

  void _updateQuantity(String itemId, int newQuantity) {
    setState(() {
      final index = cartItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        if (newQuantity > 0) {
          cartItems[index] = cartItems[index].copyWith(quantity: newQuantity);
        } else {
          cartItems.removeAt(index);
        }
      }
    });
  }

  void _removeItem(String itemId) {
    setState(() {
      cartItems.removeWhere((item) => item.id == itemId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Produit retiré du panier'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Connexion requise'),
          ],
        ),
        content: const Text(
          'Vous devez vous connecter pour accéder à votre panier et passer commande.\n\nCréez un compte ou connectez-vous maintenant !',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Ferme juste le dialogue
            },
            child: const Text('Retour'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/auth'); // Utiliser pushNamed
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textWhite,
            ),
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
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
      appBar: AppBar(
        title: const Text('Mon Panier'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Retour',
        ),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  cartItems.clear();
                });
              },
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              label: const Text(
                'Vider',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                // Liste des produits
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return _buildCartItem(cartItems[index]);
                    },
                  ),
                ),

                // Résumé et bouton commander
                _buildCheckoutSection(),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Votre panier est vide',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ajoutez des produits pour commencer',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/catalog');
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Découvrir les produits'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textWhite,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image produit
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.product.images.first,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: AppColors.border,
                    child: const Icon(
                      Icons.image,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            // Informations produit
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    item.product.artisanName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Prix
                      Flexible(
                        child: Text(
                          '${item.product.price.toInt()} FCFA',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Contrôles quantité
                      _buildQuantityControls(item),
                    ],
                  ),
                ],
              ),
            ),

            // Bouton supprimer
            IconButton(
              onPressed: () => _removeItem(item.id),
              icon: const Icon(Icons.close, color: AppColors.error),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(CartItemModel item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton -
          InkWell(
            onTap: () => _updateQuantity(item.id, item.quantity - 1),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.remove,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Quantité
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${item.quantity}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Bouton +
          InkWell(
            onTap: item.quantity < item.product.stock
                ? () => _updateQuantity(item.id, item.quantity + 1)
                : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.add,
                size: 18,
                color: item.quantity < item.product.stock
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sous-total
          _buildPriceRow('Sous-total', subtotal),

          const SizedBox(height: 8),

          // Frais de livraison
          _buildPriceRow('Livraison', deliveryFee),

          const Divider(height: 24),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  '${total.toInt()} FCFA',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Bouton Commander
          ElevatedButton(
            onPressed: () {
              // Aller directement au paiement
              _proceedToPayment(total);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textWhite,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_bag),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Commander (${cartItems.length} article${cartItems.length > 1 ? 's' : ''})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          child: Text(
            '${price.toInt()} FCFA',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Future<void> _proceedToPayment(double total) async {
    try {
      // Créer la commande d'abord
      final cartItems = CartManager.cartItems;

      if (cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votre panier est vide'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Créer la commande via l'API
      // Note: Le backend crée automatiquement la commande depuis le panier
      // On doit juste fournir l'adresse de livraison
      final order = await ApiService.createOrder(
        deliveryAddress:
            'Adresse à définir', // TODO: Récupérer depuis le profil
        deliveryPhone: '0000000000', // TODO: Récupérer depuis le profil
        deliveryFee: 2000.0, // Frais de livraison par défaut
      );

      if (order != null && mounted) {
        Navigator.pop(context); // Fermer le loading

        // Aller à l'écran de paiement
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              amount: total,
              orderId: order['id'] ?? order['id'].toString(),
            ),
          ),
        );
      } else {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la création de la commande'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
