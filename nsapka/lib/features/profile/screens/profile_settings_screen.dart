import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/services/theme_service.dart';
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
  final ThemeService _themeService = ThemeService();

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
        title: Text('settings'.tr()),
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
          _buildSectionHeader('notifications'.tr()),
          _buildSwitchTile(
            title: 'push_notifications'.tr(),
            subtitle: 'receive_notifications'.tr(),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
            },
          ),

          // Section Apparence
          _buildSectionHeader('appearance'.tr()),
          _buildSwitchTile(
            title: 'dark_mode'.tr(),
            subtitle: 'enable_dark_theme'.tr(),
            value: _themeService.isDarkMode,
            onChanged: (value) async {
              await _themeService.setTheme(value);
              setState(() {});
            },
          ),

          // Section Langue
          _buildSectionHeader('language'.tr()),
          _buildLanguageSelector(),

          // Section Sécurité
          _buildSectionHeader('security'.tr()),
          _buildMenuTile(
            title: 'change_password'.tr(),
            subtitle: 'Modifier votre mot de passe',
            icon: Icons.lock,
            onTap: () => _showChangePasswordDialog(),
          ),

          // Section Support
          _buildSectionHeader('support'.tr()),
          _buildMenuTile(
            title: 'help_center'.tr(),
            subtitle: 'faq'.tr(),
            icon: Icons.help,
            onTap: () => _showHelpDialog(),
          ),
          _buildMenuTile(
            title: 'contact_support'.tr(),
            subtitle: 'send_message'.tr(),
            icon: Icons.support_agent,
            onTap: () => _showSupportDialog(),
          ),

          // Section Légal
          _buildSectionHeader('legal_info'.tr()),
          _buildMenuTile(
            title: 'terms_of_service'.tr(),
            subtitle: 'read_terms'.tr(),
            icon: Icons.description,
            onTap: () => _showLegalDialog(
              'Conditions d\'utilisation',
              'Contenu des conditions...',
            ),
          ),
          _buildMenuTile(
            title: 'privacy_policy'.tr(),
            subtitle: 'read_privacy'.tr(),
            icon: Icons.privacy_tip,
            onTap: () => _showLegalDialog(
              'Politique de confidentialité',
              'Contenu de la politique...',
            ),
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
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
    final currentLocale = context.locale;
    final languageName = currentLocale.languageCode == 'fr'
        ? 'Français'
        : 'English';

    return ListTile(
      title: Text('language'.tr()),
      subtitle: Text(languageName),
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

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('choose_language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('french'.tr()),
              trailing: context.locale.languageCode == 'fr'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () async {
                await context.setLocale(const Locale('fr'));
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('english'.tr()),
              trailing: context.locale.languageCode == 'en'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () async {
                await context.setLocale(const Locale('en'));
                if (mounted) Navigator.pop(context);
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
        content: const Text(
          'Fonctionnalité à venir dans la prochaine version.',
        ),
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
        content: const Text(
          'Consultez notre FAQ et nos guides d\'utilisation en ligne.',
        ),
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
        content: SingleChildScrollView(child: Text(content)),
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
