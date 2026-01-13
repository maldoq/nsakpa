import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/product_model.dart';
import '../../../core/data/mock_data.dart';
import '../../catalog/widgets/enhanced_product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<ProductModel> favoriteProducts = [];

  @override
  void initState() {
    super.initState();
    // Charger les favoris (mockés)
    favoriteProducts = MockData.products.where((p) => p.isFavorite).toList();
    
    // Si aucun favori, en ajouter quelques-uns pour la démo
    if (favoriteProducts.isEmpty) {
      favoriteProducts = [
        MockData.products[0].copyWith(isFavorite: true),
        MockData.products[3].copyWith(isFavorite: true),
        MockData.products[7].copyWith(isFavorite: true),
      ];
    }
  }

  void _toggleFavorite(String productId) {
    setState(() {
      favoriteProducts.removeWhere((p) => p.id == productId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Retiré des favoris'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (favoriteProducts.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  favoriteProducts.clear();
                });
              },
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              label: const Text(
                'Tout retirer',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: favoriteProducts.isEmpty
          ? _buildEmptyFavorites()
          : GridView.builder(
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
            'Aucun favori',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ajoutez des produits à vos favoris',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/catalog');
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explorer les produits'),
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
