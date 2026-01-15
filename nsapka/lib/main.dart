import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/services/theme_service.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/auth_selection_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/buyer/screens/buyer_home_enhanced.dart';
import 'features/artisan/screens/artisan_home_screen.dart';
import 'features/artisan/screens/artisan_order_management_screen.dart';
import 'features/admin/screens/admin_home_screen.dart';
import 'features/community_agent/screens/community_agent_home_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/catalog/screens/catalog_screen.dart';
import 'features/cart/screens/cart_screen.dart';
import 'features/favorites/screens/favorites_screen.dart';
import 'features/chat/screens/chat_screen_v2.dart';
import 'features/blog/screens/blog_list_screen.dart';
import 'features/artisans/screens/artisans_list_screen.dart';
import 'features/test/test_order_creation.dart';
import 'features/buyer/screens/buyer_orders_screen.dart';
import 'core/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Charger le thème sauvegardé
  await ThemeService().loadTheme();

  // Configuration de la barre de statut pour qu'elle soit transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('fr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('fr'),
      child: const NSapkaApp(),
    ),
  );
}

class NSapkaApp extends StatefulWidget {
  const NSapkaApp({super.key});

  @override
  State<NSapkaApp> createState() => _NSapkaAppState();
}

class _NSapkaAppState extends State<NSapkaApp> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

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
        '/artisan-orders': (context) => const ArtisanOrderManagementScreen(),
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
        '/test-orders': (context) =>
            const TestOrderCreationScreen(), // 🧪 TEST COMMANDES DYNAMIQUES
        '/buyer-orders': (context) =>
            const BuyerOrdersScreen(), // 🛍️ COMMANDES CLIENT
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
