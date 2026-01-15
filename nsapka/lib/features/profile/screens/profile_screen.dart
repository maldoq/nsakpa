import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nsapka/core/models/order_model.dart';
import 'package:nsapka/core/utils/order_utils.dart';
import 'package:nsapka/features/orders/screens/order_tracking_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart';
import 'profile_settings_screen.dart';
import 'profile_edit_screen.dart';
import '../../buyer/screens/buyer_orders_screen.dart';
import '../../artisan/screens/artisan_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  final bool showBackButton;
  final UserRole? userRole;

  const ProfileScreen({
    super.key,
    this.userId,
    this.showBackButton = true,
    this.userRole,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  Map<String, dynamic>? _artisanDetails;
  bool _isLoading = true;
  List<OrderModel> _recentOrders = [];
  bool _isLoadingOrders = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadRecentOrders();
  }

  Future<void> _loadRecentOrders() async {
    setState(() => _isLoadingOrders = true);
    try {
      final orders = await ApiService.getMyOrders();
      debugPrint('DEBUG: Orders raw response: $orders');
      if (mounted) {
        setState(() {
          _recentOrders = orders;
          _isLoadingOrders = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement commandes: $e');
      if (mounted) setState(() => _isLoadingOrders = false);
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      UserModel? currentUser = await AuthService.getCurrentUser();

      if (currentUser != null && currentUser.role == UserRole.artisan) {
        try {
          final profileData = await ApiService.getArtisanProfile();
          if (profileData != null) {
            _artisanDetails = profileData;
          }
        } catch (e) {
          debugPrint("Erreur chargement profil artisan API: $e");
        }
      }

      if (mounted) {
        setState(() {
          _user = currentUser;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement user: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text("Utilisateur non trouvé"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text("Se connecter"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildNameSection(),
                  const SizedBox(height: 20),

                  if (_user!.role == UserRole.artisan) ...[
                    _buildStatsSection(),
                    const SizedBox(height: 20),
                  ],

                  _buildContentCard(
                    title: 'about'.tr(),
                    icon: Icons.person_outline,
                    child: Text(
                      _artisanDetails?['bio'] ??
                          _user!.bio ??
                          'Aucune description disponible.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildContentCard(
                    title: "Informations",
                    icon: Icons.info_outline,
                    child: _buildInfoContent(),
                  ),
                  const SizedBox(height: 20),

                  _buildOrdersSection(),

                  const SizedBox(height: 20),

                  if (_user!.role == UserRole.artisan) ...[
                    _buildSpecialtiesSection(),
                    const SizedBox(height: 20),
                    _buildQRSection(),
                    const SizedBox(height: 20),
                  ],

                  _buildActionButtons(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textWhite,
      automaticallyImplyLeading: widget.showBackButton,
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
              onPressed: () {
                // Navigation sécurisée vers l'écran précédent ou connexion
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                } else {
                  // Si pas d'écran précédent, aller vers l'écran de connexion
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/auth', (route) => false);
                }
              },
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            // Fond dégradé
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.secondary, AppColors.primary],
                ),
              ),
            ),
            // Motif décoratif discret (optionnel)
            Positioned(
              top: -20,
              right: -20,
              child: Icon(
                Icons.circle,
                size: 150,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            // Image de profil centrée
            Positioned(
              bottom: 20, // Légèrement remontée
              child: _buildProfileImage(),
            ),
          ],
        ),
      ),
      actions: [
        if (_user!.role == UserRole.artisan)
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textWhite),
            tooltip: "Modifier le profil public",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ArtisanProfileScreen(),
                ),
              );
              _loadUserData();
            },
          ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.textWhite),
          tooltip: "Paramètres",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileSettingsScreen(
                  userId: _user!.id,
                  userRole: _user!.role,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    String? imageUrl = _artisanDetails?['profile_image'] ?? _user!.profileImage;

    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: (imageUrl != null && imageUrl.startsWith('http'))
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildDefaultAvatar(),
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        _user!.role == UserRole.artisan ? Icons.storefront : Icons.person,
        size: 50,
        color: AppColors.primary.withOpacity(0.5),
      ),
    );
  }

  Widget _buildNameSection() {
    final displayName = _user!.name;
    final displayStand = _artisanDetails?['stand_name'] ?? _user!.standName;

    return Column(
      children: [
        Text(
          displayName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        if (_user!.role == UserRole.artisan && displayStand != null) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.store_mall_directory,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                displayStand,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        if (_artisanDetails?['is_verified'] == true ||
            _user!.role == UserRole.artisan)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 14, color: AppColors.success),
                SizedBox(width: 4),
                Text(
                  'Compte Vérifié',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final yearsExp = _artisanDetails?['years_of_experience'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              "4.8",
              "Note moyenne",
              Icons.star_rounded,
              AppColors.warning,
            ),
            const VerticalDivider(width: 20, thickness: 1, color: Colors.grey),
            _buildStatItem(
              "$yearsExp ans",
              "Expérience",
              Icons.history,
              AppColors.info,
            ),
            const VerticalDivider(width: 20, thickness: 1, color: Colors.grey),
            _buildStatItem(
              "12",
              "Produits",
              Icons.inventory_2_outlined,
              AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // Widget générique pour encadrer le contenu (Card style)
  Widget _buildContentCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoContent() {
    final location =
        _artisanDetails?['location'] ?? _user!.location ?? 'Non spécifié';
    final standLoc = _artisanDetails?['stand_location'] ?? _user!.standLocation;

    return Column(
      children: [
        _buildInfoRow(Icons.phone_outlined, _user!.phone),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.email_outlined, _user!.email),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.location_on_outlined, location),
        if (standLoc != null && standLoc.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildInfoRow(Icons.storefront_outlined, standLoc),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtiesSection() {
    List<dynamic> specs = _artisanDetails?['specialties'] ?? [];
    if (specs.isEmpty && _user!.specialties != null)
      specs = _user!.specialties!;

    if (specs.isEmpty) return const SizedBox.shrink();

    return _buildContentCard(
      title: "Spécialités",
      icon: Icons.star_border,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: specs
            .map(
              (s) => Chip(
                label: Text(s.toString()),
                backgroundColor: AppColors.secondary.withOpacity(0.1),
                labelStyle: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildQRSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Mon QR Shop',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.qr_code_2, size: 100, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          const Text(
            'Scannez pour visiter ma boutique',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRow(OrderModel order) {
    return GestureDetector(
      onTap: () {
        // ✅ Navigation vers l'écran de tracking
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(order: order),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Icône de commande
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: getOrderStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.receipt_long,
                color: getOrderStatusColor(order.status),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Informations de la commande
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Commande #${order.id}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          formatOrderDate(order.createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(' • ', style: TextStyle(color: Colors.grey)),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: getOrderStatusColor(
                              order.status,
                            ).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            getOrderStatusLabel(order.status),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: getOrderStatusColor(order.status),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Montant total
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${order.total.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersSection() {
    return _buildContentCard(
      title: "Mes commandes",
      icon: Icons.shopping_bag_outlined,
      child: _isLoadingOrders
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          : _recentOrders.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune commande pour le moment',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                ..._recentOrders.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildOrderRow(order),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BuyerOrdersScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: Text(
                      'view_all_orders'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_user!.role == UserRole.artisan) ...[
          _buildActionButton(
            label: 'manage_products'.tr(),
            icon: Icons.inventory_2,
            color: AppColors.primary,
            onPressed: () => Navigator.pushNamed(context, '/catalog'),
          ),
          const SizedBox(height: 12),
        ],

        if (_user!.role == UserRole.buyer) ...[
          _buildActionButton(
            label: 'Contacter des artisans',
            icon: Icons.chat_bubble_outline,
            color: AppColors.accent,
            onPressed: _showArtisansList,
          ),
          const SizedBox(height: 12),
        ],

        // Bouton Déconnexion style "Danger" mais élégant
        TextButton.icon(
          onPressed: _showLogoutDialog,
          icon: Icon(Icons.logout, color: Colors.red.shade400, size: 20),
          label: Text(
            'logout'.tr(),
            style: TextStyle(
              color: Colors.red.shade400,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.red.shade50,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 50),
        elevation: 4,
        shadowColor: color.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showArtisansList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Fonctionnalité Liste Artisans à connecter à l'API"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppColors.error),
            SizedBox(width: 12),
            Text('Déconnexion'),
          ],
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter de votre compte ?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
