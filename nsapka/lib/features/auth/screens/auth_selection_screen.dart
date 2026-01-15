import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class AuthSelectionScreen extends StatelessWidget {
  const AuthSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary, AppColors.accent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 48,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Logo et titre
                    _buildHeader(context),

                    const SizedBox(height: 40),

                    // Titre de sélection
                    Text(
                      'selectUserType'.tr(),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Carte Acheteur
                    _buildUserTypeCard(
                      context: context,
                      title: 'buyer'.tr(),
                      subtitle: 'discover_products'.tr(),
                      icon: Icons.shopping_bag,
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryLight, AppColors.primary],
                      ),
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed('/login', arguments: 'buyer');
                      },
                    ),

                    const SizedBox(height: 16),

                    // Carte Artisan
                    _buildUserTypeCard(
                      context: context,
                      title: 'artisan'.tr(),
                      subtitle: 'sell_your_creations'.tr(),
                      icon: Icons.palette,
                      gradient: const LinearGradient(
                        colors: [AppColors.secondaryLight, AppColors.secondary],
                      ),
                      onTap: () {
                        Navigator.of(
                          context,
                        ).pushNamed('/login', arguments: 'artisan');
                      },
                    ),

                    const SizedBox(height: 20),

                    // Bouton Mode Visiteur
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                          '/buyer-home',
                          arguments: {'isVisitorMode': true}, // Mode visiteur
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility,
                            color: AppColors.textWhite,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'visitor_mode'.tr(),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textWhite,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Texte informatif
                    Text(
                      "Choisissez votre profil ou explorez en mode visiteur",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textWhite.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.textWhite,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.back_hand,
            size: 50,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 24),

        // Nom de l'app
        Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 8),

        // Tagline
        Text(
          AppStrings.appTagline,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textWhite.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserTypeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.textWhite.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 35, color: AppColors.textWhite),
            ),

            const SizedBox(width: 20),

            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textWhite.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Flèche
            Icon(Icons.arrow_forward_ios, color: AppColors.textWhite, size: 24),
          ],
        ),
      ),
    );
  }
}
