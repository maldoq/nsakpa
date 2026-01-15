import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/product_model.dart';
import '../../../core/services/api_service.dart';
import '../../catalog/widgets/enhanced_product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<ProductModel> favoriteProducts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final favorites = await ApiService.getFavorites();
      setState(() {
        favoriteProducts = favorites;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de chargement: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(String productId) async {
    try {
      final success = await ApiService.removeFavorite(productId);

      if (success) {
        setState(() {
          favoriteProducts.removeWhere((p) => p.id == productId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Retiré des favoris'),
              duration: Duration(seconds: 2),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        throw Exception('Échec de suppression');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _removeAllFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer'),
        content: const Text('Voulez-vous vraiment retirer tous les favoris ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Confirmer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Supprimer tous les favoris
      for (final product in List.from(favoriteProducts)) {
        await ApiService.removeFavorite(product.id);
      }
      setState(() {
        favoriteProducts.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('favorites'.tr()),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (favoriteProducts.isNotEmpty)
            TextButton.icon(
              onPressed: _removeAllFavorites,
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              label: const Text(
                'Tout retirer',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? _buildError()
          : favoriteProducts.isEmpty
          ? _buildEmptyFavorites()
          : RefreshIndicator(
              onRefresh: _loadFavorites,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: favoriteProducts.length,
                itemBuilder: (context, index) {
                  return EnhancedProductCard(
                    product: favoriteProducts[index],
                    onTap: () {
                      // Naviguer vers détails produit
                    },
                    onFavoriteToggle: () {
                      _toggleFavorite(favoriteProducts[index].id);
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Erreur inconnue',
            style: const TextStyle(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadFavorites,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavorites() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 120,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'no_favorites'.tr(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'add_to_favorites'.tr(),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/catalog');
            },
            icon: const Icon(Icons.explore),
            label: Text('catalog'.tr()),
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
}
