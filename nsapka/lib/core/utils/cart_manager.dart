import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartManager {
  static final List<CartItemModel> _cartItems = [];

  static List<CartItemModel> get cartItems => _cartItems;

  static void addToCart(ProductModel product, int quantity) {
    // Vérifier si le produit est déjà dans le panier
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      // Produit déjà dans le panier, augmenter la quantité
      _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
        quantity: _cartItems[existingIndex].quantity + quantity,
      );
    } else {
      // Nouveau produit, l'ajouter
      final cartItem = CartItemModel(
        id: 'cart_${product.id}_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        quantity: quantity,
        addedAt: DateTime.now(),
      );
      _cartItems.add(cartItem);
    }
  }

  static void removeFromCart(String cartItemId) {
    _cartItems.removeWhere((item) => item.id == cartItemId);
  }

  static void updateQuantity(String cartItemId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      if (newQuantity <= 0) {
        removeFromCart(cartItemId);
      } else {
        _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
      }
    }
  }

  static void clearCart() {
    _cartItems.clear();
  }

  static double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  static int get itemCount {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  static bool isInCart(String productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  static int getQuantity(String productId) {
    final item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItemModel(
        id: '',
        product: ProductModel(
          id: '',
          name: '',
          description: '',
          price: 0,
          images: [],
          category: '',
          artisanId: '',
          artisanName: '',
          rating: 0,
          stock: 0,
          createdAt: DateTime.now(),
        ),
        addedAt: DateTime.now(),
      ),
    );
    return item.id.isNotEmpty ? item.quantity : 0;
  }
}
