import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/review_model.dart';
import '../../../core/models/product_model.dart';
import '../../../core/data/mock_data.dart';
import '../../chat/screens/chat_screen_v2.dart';
import '../../../core/utils/cart_manager.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  final bool isVisitorMode;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.isVisitorMode = false,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  int selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final artisan = MockData.artisans.firstWhere(
      (a) => a.id == widget.product.artisanId,
      orElse: () => MockData.artisans.first,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar avec images
          _buildImageGallery(),
          
          // Contenu
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Infos produit
                _buildProductInfo(),
                
                const Divider(height: 32),
                
                // Artisan
                _buildArtisanSection(artisan),
                
                const Divider(height: 32),
                
                // Description
                _buildDescription(),
                
                const Divider(height: 32),
                
                // Caractéristiques
                _buildFeatures(),
                
                const Divider(height: 32),
                
                // Avis clients
                _buildReviewsSection(),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      
      // Barre d'actions en bas
      bottomNavigationBar: _buildBottomBar(artisan),
      
      // Bouton Chat flottant
      floatingActionButton: _buildChatButton(artisan),
    );
  }

  Widget _buildImageGallery() {
    final screenHeight = MediaQuery.of(context).size.height;
    final expandedHeight = (screenHeight * 0.5).clamp(300.0, 500.0);
    
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      backgroundColor: AppColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Image principale
            PageView.builder(
              itemCount: widget.product.images.length,
              onPageChanged: (index) {
                setState(() {
                  selectedImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  widget.product.images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.border,
                      child: const Center(
                        child: Icon(Icons.image, size: 80, color: AppColors.textSecondary),
                      ),
                    );
                  },
                );
              },
            ),
            
            // Badges
            Positioned(
              top: 60,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.product.isLimitedEdition)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.warning, AppColors.error],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flash_on, size: 16, color: AppColors.textWhite),
                          const SizedBox(width: 4),
                          Text(
                            'Édition Limitée (${widget.product.limitedQuantity})',
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.product.videoUrl != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle, size: 16, color: AppColors.textWhite),
                          SizedBox(width: 4),
                          Text(
                            'Vidéo disponible',
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Indicateur de pages
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.product.images.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedImageIndex == index
                          ? AppColors.textWhite
                          : AppColors.textWhite.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            if (widget.isVisitorMode) {
              _showLoginDialog('ajouter aux favoris');
            } else {
              // Toggle favori
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Partage disponible pour tous
          },
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Catégorie
          Text(
            widget.product.category.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Nom
          Text(
            widget.product.name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Note et avis
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < widget.product.rating.floor()
                      ? Icons.star
                      : Icons.star_border,
                  size: 20,
                  color: AppColors.warning,
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${widget.product.rating} (${widget.product.reviewCount} avis)',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Prix
          Row(
            children: [
              Text(
                '${widget.product.price} FCFA',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              // Stock
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.product.stock > 5
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.product.stock > 5 ? Icons.check_circle : Icons.warning,
                      size: 16,
                      color: widget.product.stock > 5 ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.product.stock > 5
                          ? 'En stock (${widget.product.stock})'
                          : 'Stock limité (${widget.product.stock})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.product.stock > 5 ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArtisanSection(artisan) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Artisan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.05),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // Photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    artisan.profileImage ?? 'assets/logo/unnamed (2).jpg',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            artisan.name[0],
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            artisan.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (artisan.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, size: 18, color: AppColors.success),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        artisan.standName ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text(
                            '${artisan.rating}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.work, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${artisan.yearsOfExperience} ans',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Bouton profil
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/profile',
                      arguments: {
                        'userId': artisan.id,
                        'userRole': artisan.role,
                      },
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Caractéristiques',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(Icons.location_on, 'Origine', widget.product.origin ?? 'Non spécifié'),
          _buildFeatureItem(Icons.category, 'Catégorie', widget.product.category),
          _buildFeatureItem(Icons.store, 'Stand', widget.product.artisanStand ?? 'Non spécifié'),
          if (widget.product.tags.isNotEmpty)
            _buildFeatureItem(Icons.label, 'Tags', widget.product.tags.join(', ')),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(artisan) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            // Quantité
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (quantity > 1) {
                        setState(() {
                          quantity--;
                        });
                      }
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (quantity < widget.product.stock) {
                        setState(() {
                          quantity++;
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Bouton Ajouter au panier
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (widget.isVisitorMode) {
                    _showLoginDialog('acheter ce produit');
                  } else {
                    _addToCart();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart),
                    SizedBox(width: 8),
                    Text(
                      'Ajouter au panier',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatButton(artisan) {
    return FloatingActionButton.extended(
      onPressed: () {
        if (widget.isVisitorMode) {
          _showLoginDialog('contacter l\'artisan');
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreenV2(
                otherUserId: artisan.id,
                currentUserId: 'buy1',
              ),
            ),
          );
        }
      },
      backgroundColor: AppColors.accent,
      icon: const Icon(Icons.chat_bubble),
      label: const Text(
        'Contacter l\'artisan',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showLoginDialog([String action = 'effectuer cette action']) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Connexion requise'),
          ],
        ),
        content: Text(
          'Vous devez vous connecter pour $action.\n\nCréez un compte ou connectez-vous pour :\n• Ajouter des produits au panier\n• Contacter les artisans\n• Sauvegarder vos favoris\n• Suivre vos commandes',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/auth'); // Utiliser pushNamed au lieu de pushReplacementNamed
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

  Widget _buildReviewsSection() {
    final productReviews = _getProductReviews();
    final averageRating = _calculateAverageRating(productReviews);

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec note moyenne
          Row(
            children: [
              const Text(
                'Avis Clients',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (productReviews.isNotEmpty)
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      final starRating = averageRating;
                      return Icon(
                        index < starRating.floor()
                            ? Icons.star
                            : index < starRating
                                ? Icons.star_half
                                : Icons.star_border,
                        size: 20,
                        color: AppColors.warning,
                      );
                    }),
                    const SizedBox(width: 8),
                    Text(
                      '${averageRating.toStringAsFixed(1)} (${productReviews.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Liste des avis
          if (productReviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aucun avis pour le moment.\nSoyez le premier à donner votre avis !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...productReviews.map((review) => _buildReviewCard(review)),

          const SizedBox(height: 16),

          // Bouton pour laisser un avis (seulement pour les acheteurs connectés)
          if (!widget.isVisitorMode)
            Center(
              child: OutlinedButton.icon(
                onPressed: () => _showAddReviewDialog(),
                icon: const Icon(Icons.rate_review),
                label: const Text('Laisser un avis'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec avatar, nom et étoiles
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Text(
                  review.userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (review.isVerifiedPurchase)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Achat vérifié',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) => Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: AppColors.warning,
                        )),
                        const SizedBox(width: 8),
                        Text(
                          '${_formatDate(review.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Commentaire
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),

          // Images si présentes
          if (review.images.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(review.images[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Réponse de l'artisan
          if (review.artisanResponse != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Réponse de l\'artisan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.artisanResponse!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

          // Bouton utile
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.thumb_up, size: 16),
                label: Text('Utile (${review.helpfulCount})'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<ReviewModel> _getProductReviews() {
    return MockData.reviews.where((review) => review.productId == widget.product.id).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  double _calculateAverageRating(List<ReviewModel> reviews) {
    if (reviews.isEmpty) return 0.0;
    final totalRating = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return totalRating / reviews.length;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      return 'Il y a ${difference.inDays ~/ 7} semaines';
    } else {
      return 'Il y a ${difference.inDays ~/ 30} mois';
    }
  }

  void _showAddReviewDialog() {
    double selectedRating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Laisser un avis'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Notez ce produit :',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() => selectedRating = index + 1.0);
                      },
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: AppColors.warning,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Votre commentaire',
                    border: OutlineInputBorder(),
                    hintText: 'Partagez votre expérience avec ce produit...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final comment = commentController.text.trim();
                if (comment.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez entrer un commentaire'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                // Afficher un indicateur de chargement
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  // Vérifier que l'utilisateur est connecté
                  final token = await AuthService.getToken();
                  if (token == null || token.isEmpty) {
                    if (mounted) {
                      Navigator.pop(context); // Fermer le loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vous devez être connecté pour laisser un avis'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                    return;
                  }

                  // Envoyer l'avis au backend
                  final result = await ApiService.createReview(
                    productId: widget.product.id,
                    rating: selectedRating,
                    comment: comment,
                  );

                  // Fermer les dialogs
                  if (mounted) {
                    Navigator.pop(context); // Fermer le loading
                    Navigator.pop(context); // Fermer le dialog d'avis
                    
                    // Rafraîchir la page pour afficher le nouvel avis
                    setState(() {});
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Merci pour votre avis !'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context); // Fermer le loading
                    print('Erreur lors de la création de l\'avis: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: ${e.toString()}'),
                        backgroundColor: AppColors.error,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
              ),
              child: const Text('Publier'),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart() {
    // Ajouter au panier via CartManager
    CartManager.addToCart(widget.product, quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$quantity x ${widget.product.name} ajouté au panier'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'Voir',
          textColor: AppColors.textWhite,
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/cart',
              arguments: {'isVisitorMode': widget.isVisitorMode},
            );
          },
        ),
      ),
    );
  }
}
