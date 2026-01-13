import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/onboarding_model.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingModel model;
  final int pageIndex;

  const OnboardingPage({
    super.key,
    required this.model,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          _buildIllustration(context),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            model.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            model.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    // Illustrations personnalisées pour chaque page
    switch (pageIndex) {
      case 0:
        return _buildWelcomeIllustration();
      case 1:
        return _buildJourneyIllustration();
      case 2:
        return _buildSupportIllustration();
      default:
        return _buildWelcomeIllustration();
    }
  }

  Widget _buildWelcomeIllustration() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo N'SAPKA
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                'assets/logo/unnamed (2).jpg',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.back_hand,
                    size: 100,
                    color: AppColors.textWhite,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "N'SAPKA",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyIllustration() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        gradient: AppColors.secondaryGradient,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Motifs décoratifs africains
          Positioned(
            top: 20,
            left: 20,
            child: _buildDecorativePattern(),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _buildDecorativePattern(),
          ),
          
          // Icône centrale
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.terracotta.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag,
                size: 80,
                color: AppColors.textWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportIllustration() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        gradient: AppColors.warmGradient,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Éléments décoratifs
          Positioned(
            top: 30,
            right: 30,
            child: Icon(
              Icons.favorite,
              size: 40,
              color: AppColors.textWhite.withValues(alpha: 0.3),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 40,
            child: Icon(
              Icons.star,
              size: 35,
              color: AppColors.textWhite.withValues(alpha: 0.3),
            ),
          ),
          
          // Icône centrale
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.handshake,
                    size: 70,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 16),
                Icon(
                  Icons.trending_up,
                  size: 40,
                  color: AppColors.textWhite,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativePattern() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.textWhite.withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          9,
          (index) => Container(
            decoration: BoxDecoration(
              color: AppColors.textWhite.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
