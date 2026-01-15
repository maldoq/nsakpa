import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

/// Service d'authentification qui gère la connexion et la déconnexion
class AuthService {
  static const String _tokenKey = 'user_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  /// Authentifie un utilisateur via l'API (Backend Django)
  /// Note: Le paramètre est nommé 'phone' pour correspondre à l'UI et l'API
  static Future<AuthResult> login({
    required String phone, // Peut être un téléphone ou un email
    required String password,
  }) async {
    try {
      // Appel vers le vrai Backend via ApiService
      // ApiService gère déjà le trim() et la requête HTTP
      final result = await ApiService.login(phone: phone, password: password);

      if (result.success && result.user != null && result.token != null) {
        // Sauvegarde locale si succès
        await saveUserData(result.user!, result.token!);
      }

      return result;
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Erreur technique: ${e.toString()}',
      );
    }
  }

  /// Récupère l'utilisateur actuellement connecté
  static Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson == null) return null;

      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  /// Récupère le token d'authentification
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Vérifie si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // On vérifie s'il y a un token valide
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Déconnecte l'utilisateur
  static Future<void> logout() async {
    // 1. Appel API pour invalider le token côté serveur (optionnel mais recommandé)
    await ApiService.logout();

    // 2. Nettoyage local
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  /// Sauvegarde les données utilisateur localement
  static Future<void> saveUserData(UserModel user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, json.encode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);

    // Synchronisation avec LocalDataService si nécessaire
    await LocalDataService.saveUser(user);
    await LocalDataService.setCurrentUser(user);
  }

  /// Redirige vers la bonne interface selon le rôle de l'utilisateur
  static String getRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.buyer:
        return '/buyer-home';
      case UserRole.artisan:
        return '/artisan-home';
      case UserRole.communityAgent:
        return '/community-agent-home';
      case UserRole.admin:
        return '/admin-home';
      case UserRole.delivery:
        return '/buyer-home'; // TODO: Créer interface delivery si besoin
      case UserRole.visitor:
        return '/login';
    }
  }
}
