import 'package:flutter/material.dart';
import 'package:nsapka/core/services/api_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/review_model.dart';
import '../../../core/models/product_model.dart';
import '../../chat/screens/chat_screen_v2.dart';
import '../../profile/screens/profile_screen.dart';
import '../../delivery/screens/delivery_tracking_screen.dart';

class ArtisansListScreen extends StatefulWidget {
  const ArtisansListScreen({super.key});

  @override
  State<ArtisansListScreen> createState() => _ArtisansListScreenState();
}

class _ArtisansListScreenState extends State<ArtisansListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String selectedCategory = 'Tous';
  final List<String> categories = [
    'Tous',
    'Sculpture',
    'Peinture',
    'Tissage',
    'Bijoux',
    'Décoration',
  ];

  String searchQuery = '';
  get artisanReviews => null;

  late Future<List<UserModel>> _artisansFuture;

  @override
  void initState() {
    super.initState();
    _artisansFuture = RemoteApiService.getArtisans();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredArtisans = _getFilteredArtisans();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nos Artisans'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Retour',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textWhite),
            onPressed: _showSearchDialog,
            tooltip: 'Rechercher des artisans',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Statistiques
            _buildStatsHeader(),

            // Filtres par catégorie
            _buildCategoryFilters(),

            // Liste des artisans
            Expanded(
              child: FutureBuilder<List<UserModel>>(
                future: _artisansFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }

                  final artisans = snapshot.data ?? [];

                  if (artisans.isEmpty) {
                    return const Center(
                      child: Text('Aucun artisan disponible'),
                    );
                  }

                  // 🔎 FILTRAGE LOCAL
                  final filteredArtisans = artisans.where((artisan) {
                    if (selectedCategory == 'Tous') return true;

                    return artisan.specialties?.any(
                          (s) => s.toLowerCase().contains(
                            selectedCategory.toLowerCase(),
                          ),
                        ) ??
                        false;
                  }).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredArtisans.length,
                    itemBuilder: (context, index) {
                      return _buildArtisanCard(filteredArtisans[index], index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${MockData.artisans.length}', 'Artisans\nactifs'),
          _buildStatItem('150+', 'Produits\nuniques'),
          _buildStatItem('4.8★', 'Note\nmoyenne'),
          _buildStatItem('25+', 'Années\nd\'expérience'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textWhite.withValues(alpha: 0.9),
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                });
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArtisanCard(UserModel artisan, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openArtisanProfile(artisan),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec avatar et nom
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.accent,
                        backgroundImage: artisan.profileImage != null
                            ? AssetImage(artisan.profileImage!)
                            : null,
                        child: artisan.profileImage == null
                            ? Text(
                                artisan.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      if (artisan.isVerified)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: AppColors.success,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
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
                            const SizedBox(width: 8),
                            if (artisan.rating != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${artisan.rating}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          artisan.standName ?? 'Artisan local',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (artisan.yearsOfExperience != null)
                          Text(
                            '${artisan.yearsOfExperience} ans d\'expérience',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Bio courte
              if (artisan.bio != null && artisan.bio!.isNotEmpty)
                Text(
                  artisan.bio!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 12),

              // Spécialités
              if (artisan.specialties != null &&
                  artisan.specialties!.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: artisan.specialties!.take(3).map((specialty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        specialty,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  // Voir le profil
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openArtisanProfile(artisan),
                      icon: const Icon(Icons.person),
                      label: const Text('Profil'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Statistiques (likes/commentaires)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.thumb_up,
                        color: AppColors.textWhite,
                      ),
                      onPressed: () => _showArtisanStats(artisan),
                      tooltip: 'Voir les statistiques',
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Chat
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chat, color: AppColors.textWhite),
                      onPressed: () => _startChat(artisan),
                      tooltip: 'Contacter l\'artisan',
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Suivi de livraison (si l'utilisateur a des commandes avec cet artisan)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.local_shipping,
                        color: AppColors.textWhite,
                      ),
                      onPressed: () => _showDeliveryTracking(artisan),
                      tooltip: 'Suivi de livraison',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<UserModel> _getFilteredArtisans() {
    if (selectedCategory == 'Tous') {
      return MockData.artisans;
    }

    return MockData.artisans.where((artisan) {
      return artisan.specialties?.any(
            (specialty) => specialty.toLowerCase().contains(
              selectedCategory.toLowerCase(),
            ),
          ) ??
          false;
    }).toList();
  }

  void _showArtisanStats(UserModel artisan) {
    // Get reviews for this artisan's products
    final artisanReviews = MockData.reviews.where((review) {
      final product = MockData.products.firstWhere(
        (p) => p.id == review.productId,
        orElse: () => ProductModel(
          id: '',
          name: '',
          description: '',
          price: 0,
          stock: 0,
          category: '',
          images: [],
          artisanId: '',
          artisanName: '',
          rating: 0.0,
          createdAt: DateTime.now(),
        ),
      );
      return product.artisanId == artisan.id;
    }).toList();

    final averageRating = artisanReviews.isNotEmpty
        ? artisanReviews.fold<double>(0, (sum, review) => sum + review.rating) /
              artisanReviews.length
        : 0.0;

    final totalLikes = artisanReviews.fold<int>(
      0,
      (sum, review) => sum + review.helpfulCount,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.accent,
                    backgroundImage: artisan.profileImage != null
                        ? AssetImage(artisan.profileImage!)
                        : null,
                    child: artisan.profileImage == null
                        ? Text(
                            artisan.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artisan.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
                        Text(
                          artisan.standName ?? 'Artisan local',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textWhite.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textWhite),
                  ),
                ],
              ),
            ),

            // Statistiques
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statistiques',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Métriques principales
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          '${averageRating.toStringAsFixed(1)}★',
                          'Note moyenne',
                          AppColors.warning,
                        ),
                        _buildStatCard(
                          '${artisanReviews.length}',
                          'Avis reçus',
                          AppColors.primary,
                        ),
                        _buildStatCard(
                          '$totalLikes',
                          'Likes reçus',
                          AppColors.accent,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Avis récents
                    if (artisanReviews.isNotEmpty) ...[
                      const Text(
                        'Avis récents',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...artisanReviews
                          .take(3)
                          .map(
                            (review) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ...List.generate(
                                        5,
                                        (index) => Icon(
                                          index < review.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 16,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatDate(review.createdAt),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    review.comment,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.thumb_up,
                                        size: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${review.helpfulCount} utiles',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ] else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'Aucun avis pour le moment',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
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

  Widget _buildStatCard(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showDeliveryTracking(UserModel artisan) {
    // Trouver les commandes de l'utilisateur avec cet artisan
    final userOrders = MockData.orders
        .where(
          (order) => order.buyerId == 'buy1' && order.artisanId == artisan.id,
        )
        .toList();

    if (userOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aucune commande trouvée avec ${artisan.name}'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Afficher la liste des commandes pour cet artisan
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_shipping,
                    color: AppColors.textWhite,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Suivi de livraison',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
                        Text(
                          'Commandes avec ${artisan.name}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textWhite.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textWhite),
                  ),
                ],
              ),
            ),

            // Liste des commandes
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: userOrders.length,
                itemBuilder: (context, index) {
                  final order = userOrders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getOrderStatusIcon(order.status),
                          color: AppColors.textWhite,
                        ),
                      ),
                      title: Text('Commande #${order.id}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${order.total.toInt()} FCFA'),
                          Text(
                            _getStatusDisplayName(order.status),
                            style: TextStyle(
                              color: _getStatusColor(order.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pop(context); // Fermer le modal
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DeliveryTrackingScreen(orderId: order.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.preparing:
        return AppColors.accent;
      case OrderStatus.readyForPickup:
        return AppColors.secondary;
      case OrderStatus.inTransit:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getOrderStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.preparing:
        return Icons.build;
      case OrderStatus.readyForPickup:
        return Icons.inventory;
      case OrderStatus.inTransit:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.preparing:
        return 'En préparation';
      case OrderStatus.readyForPickup:
        return 'Prête à l\'enlèvement';
      case OrderStatus.inTransit:
        return 'En transit';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher un artisan'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nom, spécialité, stand...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => searchQuery = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (searchQuery.isNotEmpty) {
                _performSearch(searchQuery);
              }
            },
            child: const Text('Rechercher'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    final results = MockData.artisans.where((artisan) {
      return artisan.name.toLowerCase().contains(query.toLowerCase()) ||
          artisan.standName?.toLowerCase().contains(query.toLowerCase()) ==
              true ||
          artisan.specialties?.any(
                (s) => s.toLowerCase().contains(query.toLowerCase()),
              ) ==
              true ||
          artisan.bio?.toLowerCase().contains(query.toLowerCase()) == true;
    }).toList();

    if (results.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aucun artisan trouvé')));
      return;
    }

    // Afficher les résultats dans un dialogue
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${results.length} résultat(s) trouvé(s)'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (context, index) {
              final artisan = results[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.accent,
                  child: Text(artisan.name[0]),
                ),
                title: Text(artisan.name),
                subtitle: Text(artisan.standName ?? ''),
                onTap: () {
                  Navigator.pop(context);
                  _openArtisanProfile(artisan);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _openArtisanProfile(UserModel artisan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProfileScreen(userId: artisan.id, userRole: UserRole.artisan),
      ),
    );
  }

  void _startChat(UserModel artisan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreenV2(
          otherUserId: artisan.id,
          currentUserId: 'buy1', // ID de l'utilisateur actuel
        ),
      ),
    );
  }
}
