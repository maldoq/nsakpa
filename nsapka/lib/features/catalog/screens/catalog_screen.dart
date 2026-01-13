import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/product_model.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/utils/favorites_manager.dart';
import '../../../core/utils/cart_manager.dart';
import '../../product/screens/product_detail_screen.dart';
import '../widgets/product_filter_sheet.dart';
import '../widgets/enhanced_product_card.dart';

class CatalogScreen extends StatefulWidget {
  final bool isVisitorMode;

  const CatalogScreen({
    super.key,
    this.isVisitorMode = false, // Par défaut, si on arrive ici, c'est qu'on est connecté
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];

  String searchQuery = '';
  String selectedCategory = 'Tous';
  String sortBy = 'recent'; // recent, price_asc, price_desc, rating
  bool showOnlyLimitedEdition = false;
  bool showNearMe = false;
  double maxPrice = 200000;

  final List<String> categories = [
    'Tous',
    'Masques',
    'Peinture',
    'Sculpture',
    'Mobilier',
    'Cuisine',
    'Décoration',
  ];

  @override
  void initState() {
    super.initState();
    allProducts = MockData.productsData;
    filteredProducts = allProducts;
  }

  void _applyFilters() {
    setState(() {
      filteredProducts = allProducts.where((product) {
        // Filtre par recherche
        if (searchQuery.isNotEmpty) {
          final query = searchQuery.toLowerCase();
          if (!product.name.toLowerCase().contains(query) &&
              !product.description.toLowerCase().contains(query) &&
              !product.artisanName.toLowerCase().contains(query)) {
            return false;
          }
        }

        // Filtre par catégorie
        if (selectedCategory != 'Tous' &&
            product.category != selectedCategory) {
          return false;
        }

        // Filtre édition limitée
        if (showOnlyLimitedEdition && !product.isLimitedEdition) {
          return false;
        }

        // Filtre prix
        if (product.price > maxPrice) {
          return false;
        }

        return true;
      }).toList();

      // Tri
      switch (sortBy) {
        case 'price_asc':
          filteredProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_desc':
          filteredProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'rating':
          filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'recent':
        default:
          filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductFilterSheet(
        selectedCategory: selectedCategory,
        sortBy: sortBy,
        showOnlyLimitedEdition: showOnlyLimitedEdition,
        maxPrice: maxPrice,
        onApply: (category, sort, limitedOnly, price) {
          setState(() {
            selectedCategory = category;
            sortBy = sort;
            showOnlyLimitedEdition = limitedOnly;
            maxPrice = price;
          });
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildProductsGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          return EnhancedProductCard(
            product: filteredProducts[index],
            onTap: () {
              // Naviguer vers détails produit
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    product: filteredProducts[index],
                    isVisitorMode: widget.isVisitorMode,
                  ),
                ),
              );
            },
            onFavoriteToggle: () {
              // Toggle favori
              setState(() {
                FavoritesManager.toggleFavorite(filteredProducts[index].id);
              });

              // Afficher feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    FavoritesManager.isFavorite(filteredProducts[index].id)
                        ? 'Ajouté aux favoris'
                        : 'Retiré des favoris',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            onAddToCart: () => _addToCart(filteredProducts[index]),
            isVisitorMode: widget.isVisitorMode,
          );
        }, childCount: filteredProducts.length),
      ),
    );
  }

  void _addToCart(ProductModel product) {
    CartManager.addToCart(product, 1);
    
    // Afficher feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ajouté au panier'),
        action: SnackBarAction(
          label: 'Voir panier',
          onPressed: () {
            // Naviguer vers le panier
            Navigator.pushNamed(
              context,
              '/cart',
              arguments: {'isVisitorMode': widget.isVisitorMode},
            );
          },
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  int _getCrossAxisCount() {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4; // Desktop
    if (width >= 800) return 3; // Tablet
    if (width >= 600) return 2; // Large mobile
    return 2; // Mobile
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar avec recherche
          _buildSliverAppBar(),

          // Filtres rapides
          SliverToBoxAdapter(child: _buildQuickFilters()),

          // Nombre de résultats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${filteredProducts.length} produit${filteredProducts.length > 1 ? 's' : ''} trouvé${filteredProducts.length > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Grille de produits
          _buildProductsGrid(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Retour',
      ),
      title: Container(
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
            _applyFilters();
          },
          decoration: InputDecoration(
            hintText: 'Rechercher un produit, artisan...',
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondary,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.filter_list, color: AppColors.primary),
              if (selectedCategory != 'Tous' ||
                  showOnlyLimitedEdition ||
                  sortBy != 'recent')
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: _showFilterSheet,
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Filtre "Près de moi"
          _buildQuickFilterChip(
            icon: Icons.location_on,
            label: 'Près de moi',
            isSelected: showNearMe,
            onTap: () {
              setState(() {
                showNearMe = !showNearMe;
              });
              _applyFilters();
            },
          ),

          const SizedBox(width: 8),

          // Filtre "Édition limitée"
          _buildQuickFilterChip(
            icon: Icons.workspace_premium,
            label: 'Édition limitée',
            isSelected: showOnlyLimitedEdition,
            onTap: () {
              setState(() {
                showOnlyLimitedEdition = !showOnlyLimitedEdition;
              });
              _applyFilters();
            },
          ),

          const SizedBox(width: 8),

          // Catégories
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildQuickFilterChip(
                label: category,
                isSelected: selectedCategory == category,
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                  _applyFilters();
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip({
    IconData? icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppColors.textWhite
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
