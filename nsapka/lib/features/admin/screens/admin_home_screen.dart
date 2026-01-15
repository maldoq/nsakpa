import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/user_model.dart';
import 'admin_order_management_screen.dart';
import 'test_dynamic_order_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TestDynamicOrderScreen(),
              ),
            ),
            heroTag: "test_orders",
            child: const Icon(Icons.science),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/test-orders'),
            icon: const Icon(Icons.shopping_cart),
            label: const Text('🧪 Test'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            heroTag: "test_purchases",
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildUsersTab();
      case 2:
        return _buildProductsTab();
      case 3:
        return _buildOrdersTab();
      case 4:
        return _buildSettingsTab();
      default:
        return _buildDashboardTab();
    }
  }

  // Dashboard - Vue d'ensemble
  Widget _buildDashboardTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.admin_panel_settings,
                            color: AppColors.textWhite,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Tableau de bord Admin",
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: AppColors.textWhite,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Gestion complète de la plateforme",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textWhite.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Statistiques
              _buildStatsGrid(),
              const SizedBox(height: 24),

              // Graphiques rapides
              _buildQuickStats(),
              const SizedBox(height: 24),

              // Actions rapides
              _buildQuickActions(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: 'customers'.tr(),
          value: "1,234",
          icon: Icons.people,
          color: AppColors.primary,
          onTap: () => setState(() => _currentIndex = 1),
        ),
        _buildStatCard(
          title: 'products'.tr(),
          value: "5,678",
          icon: Icons.inventory,
          color: AppColors.secondary,
          onTap: () => setState(() => _currentIndex = 2),
        ),
        _buildStatCard(
          title: 'my_orders'.tr(),
          value: "890",
          icon: Icons.shopping_cart,
          color: AppColors.accent,
          onTap: () => setState(() => _currentIndex = 3),
        ),
        _buildStatCard(
          title: 'revenue'.tr(),
          value: "12.5M",
          subtitle: "FCFA",
          icon: Icons.attach_money,
          color: AppColors.warning,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.arrow_forward, color: color, size: 16),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Aperçu rapide",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickStatRow("Artisans actifs", "456", Icons.palette),
          const Divider(),
          _buildQuickStatRow("Acheteurs", "778", Icons.shopping_bag),
          const Divider(),
          _buildQuickStatRow("Commandes en attente", "23", Icons.pending),
          const Divider(),
          _buildQuickStatRow("Produits à valider", "12", Icons.verified_user),
        ],
      ),
    );
  }

  Widget _buildQuickStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Actions rapides",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            "Valider des produits",
            Icons.check_circle,
            AppColors.success,
            () {},
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            "Gérer les utilisateurs",
            Icons.people_outline,
            AppColors.primary,
            () => setState(() => _currentIndex = 1),
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            "Voir les rapports",
            Icons.analytics,
            AppColors.accent,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  // Gestion des utilisateurs
  Widget _buildUsersTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des utilisateurs"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filtres
          _buildFilterChips(),
          const SizedBox(height: 16),

          // Liste des utilisateurs
          _buildUserCard(
            "Artisan",
            "Jean Dupont",
            "jean@example.com",
            UserRole.artisan,
          ),
          _buildUserCard(
            "Acheteur",
            "Marie Martin",
            "marie@example.com",
            UserRole.buyer,
          ),
          _buildUserCard(
            "Community Agent",
            "Paul Durand",
            "paul@example.com",
            UserRole.communityAgent,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip("Tous", true),
          const SizedBox(width: 8),
          _buildFilterChip("Artisans", false),
          const SizedBox(width: 8),
          _buildFilterChip("Acheteurs", false),
          const SizedBox(width: 8),
          _buildFilterChip("Agents", false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {},
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.textWhite,
    );
  }

  Widget _buildUserCard(
    String role,
    String name,
    String email,
    UserRole userRole,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(name[0].toUpperCase()),
        ),
        title: Text(name),
        subtitle: Text(email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(role),
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 8),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text("Modifier")),
                const PopupMenuItem(value: 'ban', child: Text("Suspendre")),
                const PopupMenuItem(value: 'delete', child: Text("Supprimer")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Gestion des produits
  Widget _buildProductsTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des produits"),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textWhite,
      ),
      body: const Center(child: Text("Gestion des produits - À implémenter")),
    );
  }

  // Gestion des commandes
  Widget _buildOrdersTab() {
    return const AdminOrderManagementScreen();
  }

  // Paramètres
  Widget _buildSettingsTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres Admin"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text("Sécurité"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text("Sauvegarde"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              "Déconnexion",
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/auth');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: 'dashboard'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people),
          label: 'customers'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.inventory),
          label: 'products'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.shopping_cart),
          label: 'my_orders'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: 'settings'.tr(),
        ),
      ],
    );
  }
}
