import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/product_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/favorites_manager.dart';
import '../../../core/utils/cart_manager.dart';
import '../../product/screens/product_detail_screen.dart';
import '../widgets/product_filter_sheet.dart';
import '../widgets/enhanced_product_card.dart';

class CatalogScreen extends StatefulWidget {
  final bool isVisitorMode;

  const CatalogScreen({
    super.key,
    this.isVisitorMode = false,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];
  
  // États de chargement
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

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
    _loadProducts();
  }

  // 🔥 Chargement des produits depuis l'API
  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final products = await ApiService.getProducts();
      
      if (mounted) {
        setState(() {
          allProducts = products;
          filteredProducts = products;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Erreur chargement produits: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Impossible de charger les produits';
        });
      }
    }
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

  // 🔥 Gestion de l'état de chargement
  Widget _buildLoadingState() {
    return const SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Chargement des produits...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 Gestion de l'état d'erreur
  Widget _buildErrorState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 Gestion de l'état vide
  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty
                  ? 'Aucun produit trouvé pour "$searchQuery"'
                  : 'Aucun produit disponible',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (searchQuery.isNotEmpty || selectedCategory != 'Tous') ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    searchQuery = '';
                    selectedCategory = 'Tous';
                    showOnlyLimitedEdition = false;
                  });
                  _applyFilters();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Réinitialiser les filtres'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    if (filteredProducts.isEmpty) {
      return _buildEmptyState();
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return EnhancedProductCard(
              product: filteredProducts[index],
              onTap: () {
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
                setState(() {
                  FavoritesManager.toggleFavorite(filteredProducts[index].id);
                });

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
          },
          childCount: filteredProducts.length,
        ),
      ),
    );
  }

  void _addToCart(ProductModel product) {
    if (widget.isVisitorMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connectez-vous pour ajouter au panier'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    CartManager.addToCart(product, 1);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ajouté au panier'),
        action: SnackBarAction(
          label: 'Voir panier',
          onPressed: () {
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
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // App Bar avec recherche
            _buildSliverAppBar(),

            // Afficher les états de chargement/erreur
            if (isLoading)
              _buildLoadingState()
            else if (hasError)
              _buildErrorState()
            else ...[
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
          ],
        ),
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
              color: AppColors.textSecondary.withOpacity(0.6),
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