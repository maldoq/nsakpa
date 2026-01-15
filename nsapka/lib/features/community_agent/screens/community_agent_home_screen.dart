import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class CommunityAgentHomeScreen extends StatefulWidget {
  const CommunityAgentHomeScreen({super.key});

  @override
  State<CommunityAgentHomeScreen> createState() =>
      _CommunityAgentHomeScreenState();
}

class _CommunityAgentHomeScreenState extends State<CommunityAgentHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildArtisansTab();
      case 2:
        return _buildValidationTab();
      case 3:
        return _buildSupportTab();
      case 4:
        return _buildProfileTab();
      default:
        return _buildDashboardTab();
    }
  }

  // Dashboard Community Agent
  Widget _buildDashboardTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.accent,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accent, AppColors.secondary],
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
                            Icons.support_agent,
                            color: AppColors.textWhite,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Community Agent",
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
                        "Soutenez les artisans de votre communauté",
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
              // Mes statistiques
              _buildMyStats(),
              const SizedBox(height: 24),

              // Tâches en attente
              _buildPendingTasks(),
              const SizedBox(height: 24),

              // Artisans assignés
              _buildAssignedArtisans(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildMyStats() {
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
            'statistics'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "Artisans",
                  "24",
                  Icons.palette,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  "Validations",
                  "156",
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "En attente",
                  "8",
                  Icons.pending,
                  AppColors.warning,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  "Support",
                  "12",
                  Icons.support_agent,
                  AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingTasks() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tâches en attente",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentIndex = 2),
                child: const Text("Voir tout"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTaskItem(
            "Valider produit",
            "Masque traditionnel",
            "Artisan: Jean Dupont",
            Icons.check_circle,
          ),
          const Divider(),
          _buildTaskItem(
            "Vérifier artisan",
            "Nouvel artisan",
            "Marie Martin",
            Icons.verified_user,
          ),
          const Divider(),
          _buildTaskItem(
            "Support client",
            "Problème de commande",
            "Commande #1234",
            Icons.support_agent,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(
    String type,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.accent),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }

  Widget _buildAssignedArtisans() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Artisans assignés",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentIndex = 1),
                child: const Text("Voir tout"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildArtisanCard("Jean Dupont", "Sculptures", "12 produits", true),
          const SizedBox(height: 8),
          _buildArtisanCard("Marie Martin", "Textiles", "8 produits", false),
        ],
      ),
    );
  }

  Widget _buildArtisanCard(
    String name,
    String specialty,
    String info,
    bool isVerified,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(name[0].toUpperCase()),
        ),
        title: Row(
          children: [
            Text(name),
            if (isVerified)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.verified, color: AppColors.success, size: 16),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(specialty),
            Text(info, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }

  // Gestion des artisans
  Widget _buildArtisansTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes artisans"),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textWhite,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildArtisanCard("Jean Dupont", "Sculptures", "12 produits", true),
          _buildArtisanCard("Marie Martin", "Textiles", "8 produits", false),
          _buildArtisanCard("Paul Durand", "Poteries", "15 produits", true),
        ],
      ),
    );
  }

  // Validation des produits
  Widget _buildValidationTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Validation produits"),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textWhite,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProductValidationCard(
            "Masque traditionnel",
            "Jean Dupont",
            "Masque en bois sculpté",
            "assets/images/image.png",
          ),
          _buildProductValidationCard(
            "Tissu wax",
            "Marie Martin",
            "Tissu africain authentique",
            "assets/images/image.png",
          ),
        ],
      ),
    );
  }

  Widget _buildProductValidationCard(
    String productName,
    String artisanName,
    String description,
    String imageUrl,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.image, size: 50));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Par $artisanName",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(description),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.close, color: AppColors.error),
                        label: const Text("Refuser"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.check),
                        label: const Text("Valider"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Support
  Widget _buildSupportTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support"),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textWhite,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSupportCard(
            "Problème de commande",
            "Commande #1234",
            "En attente",
            Icons.shopping_cart,
          ),
          _buildSupportCard(
            "Question artisan",
            "Jean Dupont",
            "En cours",
            Icons.palette,
          ),
          _buildSupportCard(
            "Problème de paiement",
            "Commande #5678",
            "Résolu",
            Icons.payment,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(
    String title,
    String subtitle,
    String status,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.accent),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Chip(
          label: Text(status),
          backgroundColor: AppColors.accent.withValues(alpha: 0.2),
        ),
        onTap: () {},
      ),
    );
  }

  // Profil
  Widget _buildProfileTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon profil"),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textWhite,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Photo de profil
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.textWhite,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Nom"),
            subtitle: const Text("Community Agent"),
            trailing: const Icon(Icons.edit),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text("Email"),
            subtitle: const Text("agent@nsapka.com"),
            trailing: const Icon(Icons.edit),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text("Téléphone"),
            subtitle: const Text("+225 XX XX XX XX XX"),
            trailing: const Icon(Icons.edit),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            trailing: Switch(value: true, onChanged: (value) {}),
          ),
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
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textSecondary,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: 'dashboard'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.palette),
          label: 'artisans'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.verified_user),
          label: "Validation",
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.support_agent),
          label: "Support",
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: 'profile'.tr(),
        ),
      ],
    );
  }
}
