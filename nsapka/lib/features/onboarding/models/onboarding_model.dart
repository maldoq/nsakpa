/// Modèle pour les pages d'onboarding
class OnboardingModel {
  final String title;
  final String description;
  final String imagePath;
  final String? lottieAnimation;

  OnboardingModel({
    required this.title,
    required this.description,
    required this.imagePath,
    this.lottieAnimation,
  });
}
