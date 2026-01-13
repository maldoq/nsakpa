import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/data/mock_data.dart';
import '../../chat/screens/chat_screen_v2.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final String userId;
  final UserRole userRole;

  const ProfileSettingsScreen({
    super.key,
    required this.userId,
    required this.userRole,
  });

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late UserModel user;
  bool notificationsEnabled = true;
  bool darkMode = false;
  String selectedLanguage = 'fr';

  @override
  void initState() {
    super.initState();
    // Charger l'utilisateur
    if (widget.userRole == UserRole.artisan) {
      user = MockData.artisans.firstWhere(
        (u) => u.id == widget.userId,
        orElse: () => MockData.artisans.first,
      );
    } else {
      user = MockData.buyers.firstWhere(
        (u) => u.id == widget.userId,
        orElse: () => MockData.buyers.first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Retour',
        ),
      ),
      body: ListView(
        children: [
          // Section Notifications
          _buildSectionHeader('Notifications'),
          _buildSwitchTile(
            title: 'Notifications push',
            subtitle: 'Recevoir des notifications sur les nouvelles commandes',
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
            },
          ),

          // Section Apparence
          _buildSectionHeader('Apparence'),
          _buildSwitchTile(
            title: 'Mode sombre',
            subtitle: 'Activer le thème sombre',
            value: darkMode,
            onChanged: (value) {
              setState(() => darkMode = value);
            },
          ),

          // Section Langue
          _buildSectionHeader('Langue'),
          _buildLanguageSelector(),

          // Section Sécurité
          _buildSectionHeader('Sécurité'),
          _buildMenuTile(
            title: 'Changer le mot de passe',
            subtitle: 'Modifier votre mot de passe',
            icon: Icons.lock,
            onTap: () => _showChangePasswordDialog(),
          ),

          // Section Support
          _buildSectionHeader('Support'),
          _buildMenuTile(
            title: 'Centre d\'aide',
            subtitle: 'FAQ et guides d\'utilisation',
            icon: Icons.help,
            onTap: () => _showHelpDialog(),
          ),
          _buildMenuTile(
            title: 'Contacter le support',
            subtitle: 'Envoyer un message au support',
            icon: Icons.support_agent,
            onTap: () => _showSupportDialog(),
          ),

          // Section Légal
          _buildSectionHeader('Informations légales'),
          _buildMenuTile(
            title: 'Conditions d\'utilisation',
            subtitle: 'Lire les conditions générales',
            icon: Icons.description,
            onTap: () => _showLegalDialog('Conditions d\'utilisation', 'Contenu des conditions...'),
          ),
          _buildMenuTile(
            title: 'Politique de confidentialité',
            subtitle: 'Lire notre politique de confidentialité',
            icon: Icons.privacy_tip,
            onTap: () => _showLegalDialog('Politique de confidentialité', 'Contenu de la politique...'),
          ),

          // Section Compte
          _buildSectionHeader('Compte'),
          _buildMenuTile(
            title: 'Supprimer mon compte',
            subtitle: 'Supprimer définitivement votre compte',
            icon: Icons.delete_forever,
            color: AppColors.error,
            onTap: () => _showDeleteAccountDialog(),
          ),

          const SizedBox(height: 40),

          // Version
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      title: const Text('Langue'),
      subtitle: Text(_getLanguageName(selectedLanguage)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showLanguageDialog(),
    );
  }

  Widget _buildMenuTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Français';
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              trailing: selectedLanguage == 'fr' ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => selectedLanguage = 'fr');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              trailing: selectedLanguage == 'en' ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => selectedLanguage = 'en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Español'),
              trailing: selectedLanguage == 'es' ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => selectedLanguage = 'es');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: const Text('Fonctionnalité à venir dans la prochaine version.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Centre d\'aide'),
        content: const Text('Consultez notre FAQ et nos guides d\'utilisation en ligne.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              // Ouvrir le site web d'aide
              Navigator.pop(context);
            },
            child: const Text('Voir l\'aide'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacter le support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Comment pouvons-nous vous aider ?'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreenV2(
                      otherUserId: 'support',
                      currentUserId: widget.userId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat),
              label: const Text('Chat en direct'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showLegalDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible et toutes vos données seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Logique de suppression de compte
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demande de suppression envoyée'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textWhite,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
