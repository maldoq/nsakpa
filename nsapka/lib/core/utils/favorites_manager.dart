class FavoritesManager {
  static final Set<String> _favoriteProductIds = {};

  static Set<String> get favoriteProductIds => _favoriteProductIds;

  static void toggleFavorite(String productId) {
    if (_favoriteProductIds.contains(productId)) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
  }

  static bool isFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }

  static void addToFavorites(String productId) {
    _favoriteProductIds.add(productId);
  }

  static void removeFromFavorites(String productId) {
    _favoriteProductIds.remove(productId);
  }

  static void clearFavorites() {
    _favoriteProductIds.clear();
  }

  static int get favoritesCount => _favoriteProductIds.length;
}
