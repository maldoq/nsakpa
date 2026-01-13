import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/auth_selection_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/buyer/screens/buyer_home_enhanced.dart';
import 'features/artisan/screens/artisan_home_screen.dart';
import 'features/admin/screens/admin_home_screen.dart';
import 'features/community_agent/screens/community_agent_home_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/catalog/screens/catalog_screen.dart';
import 'features/cart/screens/cart_screen.dart';
import 'features/favorites/screens/favorites_screen.dart';
import 'features/chat/screens/chat_screen_v2.dart';
import 'features/blog/screens/blog_list_screen.dart';
import 'features/artisans/screens/artisans_list_screen.dart';
import 'core/models/user_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration de la barre de statut pour qu'elle soit transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const NSapkaApp());
}

class NSapkaApp extends StatelessWidget {
  const NSapkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Route initiale
      initialRoute: '/',

      // Configuration des routes
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/auth': (context) => const AuthSelectionScreen(),
        '/login': (context) {
          // Correction de sécurité : Gérer String ET Map pour éviter le crash
          final args = ModalRoute.of(context)?.settings.arguments;
          String userType = 'buyer'; // Valeur par défaut

          if (args is Map<String, dynamic>) {
            userType = args['userType'] ?? 'buyer';
          } else if (args is String) {
            userType = args;
          }

          return LoginScreen(userType: userType);
        },
        '/register': (context) {
          // Correction de sécurité : Idem pour l'inscription
          final args = ModalRoute.of(context)?.settings.arguments;
          String userType = 'buyer';

          if (args is Map<String, dynamic>) {
            userType = args['userType'] ?? 'buyer';
          } else if (args is String) {
            userType = args;
          }

          return RegisterScreen(userType: userType);
        },
        '/buyer-home': (context) => const BuyerHomeEnhanced(),
        '/artisan-home': (context) => const ArtisanHomeScreen(),
        '/admin-home': (context) => const AdminHomeScreen(),
        '/agent-home': (context) => const CommunityAgentHomeScreen(),
        // '/profile': (context) => const ProfileScreen(userId: '', userRole: null,),
        '/catalog': (context) {
          // Gestion sécurisée des arguments optionnels
          final args = ModalRoute.of(context)?.settings.arguments;
          final isVisitor = (args is Map<String, dynamic>)
              ? (args['isVisitorMode'] ?? false)
              : false;
          return CatalogScreen(isVisitorMode: isVisitor);
        },
        '/cart': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final isVisitor = (args is Map<String, dynamic>)
              ? (args['isVisitorMode'] ?? false)
              : false;
          return CartScreen(isVisitorMode: isVisitor);
        },
        '/favorites': (context) => const FavoritesScreen(),
        '/chat': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return ChatScreenV2(
            otherUserId: args?['otherUserId'] ?? 'art1',
            currentUserId: args?['currentUserId'] ?? 'buy1',
          );
        },
        '/blog': (context) => const BlogListScreen(),
        '/artisans': (context) => const ArtisansListScreen(),
      },

      // Gestion des routes inconnues
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) =>
              const Scaffold(body: Center(child: Text("Page non trouvée"))),
        );
      },
    );
  }
}
