import '../services/api_service.dart';

class FavoritesManager {
  static final Set<String> _favoriteProductIds = {};

  static Set<String> get favoriteProductIds => _favoriteProductIds;

  /// Initialise les favoris depuis l'API
  static Future<void> loadFavorites() async {
    try {
      final favorites = await ApiService.getFavorites();
      _favoriteProductIds.clear();
      _favoriteProductIds.addAll(favorites.map((p) => p.id));
    } catch (e) {
      print('Erreur chargement favoris: $e');
    }
  }

  /// Toggle avec appel API
  static Future<bool> toggleFavorite(String productId) async {
    final wasAlreadyFavorite = _favoriteProductIds.contains(productId);

    try {
      if (wasAlreadyFavorite) {
        final success = await ApiService.removeFavorite(productId);
        if (success) {
          _favoriteProductIds.remove(productId);
          return true;
        }
      } else {
        final success = await ApiService.addFavorite(productId);
        if (success) {
          _favoriteProductIds.add(productId);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Erreur toggle favori: $e');
      return false;
    }
  }

  static bool isFavorite(String productId) {
    return _favoriteProductIds.contains(productId);
  }

  /// Ajoute aux favoris avec appel API
  static Future<bool> addToFavorites(String productId) async {
    try {
      final success = await ApiService.addFavorite(productId);
      if (success) {
        _favoriteProductIds.add(productId);
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur ajout favori: $e');
      return false;
    }
  }

  /// Retire des favoris avec appel API
  static Future<bool> removeFromFavorites(String productId) async {
    try {
      final success = await ApiService.removeFavorite(productId);
      if (success) {
        _favoriteProductIds.remove(productId);
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur suppression favori: $e');
      return false;
    }
  }

  static void clearFavorites() {
    _favoriteProductIds.clear();
  }

  static int get favoritesCount => _favoriteProductIds.length;
}
