import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nsapka/core/models/cart_item_model.dart';
import 'package:nsapka/core/models/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'auth_service.dart';

// ==================== LOCAL DATA SERVICE (Stockage local) ====================

class LocalDataService {
  static const String _usersKey = 'local_users';
  static const String _currentUserKey = 'current_user';

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
  }

  static Future<void> setCurrentUser(UserModel? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_currentUserKey);
    } else {
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    }
  }

  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  static Future<void> logout() async {
    await setCurrentUser(null);
  }
}

// ==================== API SERVICE (Facade) ====================
// Cette classe décide si on appelle le VRAI backend ou si on renvoie du FAUX (Mock)

class ApiService {
  // ---------------------------------------------------------------------------
  // ✅ VRAIES MÉTHODES (Connectées au Backend Django)
  // ---------------------------------------------------------------------------

  static Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirm,
    required String location,
    required UserRole role,
    String? standName,
    String? bio,
    String? standLocation,
    List<String>? specialties,
  }) async {
    return RemoteApiService.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      location: location,
      role: role,
      standName: standName,
      bio: bio,
      standLocation: standLocation,
      specialties: specialties,
    );
  }

  static Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    return RemoteApiService.login(phone: phone, password: password);
  }

  static Future<List<Map<String, dynamic>>> getArtisanProducts({
    String? category,
    String? search,
  }) async {
    return RemoteApiService.getArtisanProducts(
      category: category,
      search: search,
    );
  }

  static Future<Map<String, dynamic>?> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    required List<String> images,
    required bool isLimitedEdition,
  }) async {
    return RemoteApiService.createProduct(
      name: name,
      description: description,
      price: price,
      stock: stock,
      category: category,
      images: images,
      isLimitedEdition: isLimitedEdition,
    );
  }

  static Future<Map<String, dynamic>?> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? category,
    List<String>? images,
    bool? isLimitedEdition,
    int? limitedQuantity,
    String? origin,
    List<String>? tags,
  }) async {
    return RemoteApiService.updateProduct(
      productId: productId,
      name: name,
      description: description,
      price: price,
      stock: stock,
      category: category,
      images: images,
      isLimitedEdition: isLimitedEdition,
    );
  }

  static Future<bool> deleteProduct(String productId) async {
    return RemoteApiService.deleteProduct(productId);
  }

  static Future<void> logout() async {
    await LocalDataService.logout();
  }

  static Future<UserModel?> getCurrentUser() {
    return LocalDataService.getCurrentUser();
  }

  // ---------------------------------------------------------------------------
  // 🎭 MÉTHODES FICTIVES (MOCK) - Pour éviter les erreurs 404/500
  // ---------------------------------------------------------------------------

  // Mock: Commandes artisan
  static Future<List<Map<String, dynamic>>> getArtisanOrders({
    String? status,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // Simuler délai réseau
    return [
      {
        'id': 'ord_123',
        'date': '2023-10-25',
        'status': 'En cours',
        'total': 45000,
        'customer': 'Kouassi Jean',
        'items': 2,
      },
      {
        'id': 'ord_124',
        'date': '2023-10-24',
        'status': 'Livré',
        'total': 12000,
        'customer': 'Amah Rose',
        'items': 1,
      },
    ];
  }

  // Mock: Profil Artisan (Retourne le user local + des fausses stats)
  static Future<Map<String, dynamic>?> getArtisanProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final user = await LocalDataService.getCurrentUser();
    return {
      'id': user?.id,
      'name': user?.name,
      'bio': user?.bio ?? "Artisan passionné par la culture locale.",
      'stand_name': user?.standName ?? "Mon Atelier",
      'stand_location': user?.standLocation ?? "Marché de Treichville",
      'years_of_experience': 5,
      'specialties': ['Sculpture', 'Bijoux'],
      'is_verified': true,
      'profile_image': user?.profileImage,
    };
  }

  // Mock: Update Profil
  static Future<Map<String, dynamic>?> updateArtisanProfile({
    String? bio,
    String? standName,
    String? standLocation,
    String? profileImageBase64,
    List<String>? specialties,
    int? yearsOfExperience,
    List<String>? certifications,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {'success': true}; // On fait semblant que ça a marché
  }

  static Future<Map<String, dynamic>?> createOrder({
    required String deliveryAddress,
    String? deliveryPhone,
    required List<CartItemModel> cartItems,
    String paymentMethod = 'orange_money',
  }) async {
    return RemoteApiService.createOrder(
      deliveryAddress: deliveryAddress,
      deliveryPhone: deliveryPhone,
      cartItems: cartItems,
      paymentMethod: paymentMethod,
    );
  }

  // Mock: Paiement
  static Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    return [
      {
        'code': 'orange_money',
        'name': 'Orange Money',
        'icon': 'assets/images/om.png',
      },
      {
        'code': 'mtn_money',
        'name': 'MTN MoMo',
        'icon': 'assets/images/momo.png',
      },
      {'code': 'wave', 'name': 'Wave', 'icon': 'assets/images/wave.png'},
    ];
  }

  static Future<Map<String, dynamic>?> initiatePayment({
    required String orderId,
    required String paymentMethodCode,
    required String phoneNumber,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return {'payment_id': 'pay_123', 'status': 'initiated'};
  }

  static Future<Map<String, dynamic>?> confirmPayment({
    required String paymentId,
    String? otp,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return {'status': 'success'};
  }

  // Mock: Chats
  static Future<List<Map<String, dynamic>>> getArtisanChats() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      {
        'id': 'chat_1',
        'name': 'Client Intéressé',
        'last_message': 'Le masque est-il disponible ?',
        'time': '14:30',
        'unread': 2,
      },
    ];
  }

  // Mock: Upload Image simple (si utilisé hors création produit)
  static Future<String?> uploadImage({
    required String imageBase64,
    String type = 'product',
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Retourne une image placeholder car on ne stocke pas vraiment
    return "https://via.placeholder.com/300";
  }

  // Mock: Autres
  static Future<bool> requestPasswordReset({required String email}) async =>
      true;

  static Future<Map<String, dynamic>?> createReview({
    required String productId,
    required double rating,
    required String comment,
  }) async => {'success': true};

  static Future<Map<String, dynamic>?> getArtisanOrderDetail(
    String orderId,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'id': orderId,
      'items': [
        {'name': 'Produit Test', 'price': 15000, 'quantity': 1},
      ],
      'total': 15000,
      'status': 'pending',
    };
  }
}

// ==================== REMOTE API SERVICE (Le VRAI Backend) ====================

class RemoteApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    if (Platform.isAndroid) {
      return 'http://192.168.108.53:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  static Map<String, String> getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  // --- Auth Réelle ---
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String location,
    required UserRole role,
    String? standName,
    String? bio,
    String? standLocation,
    List<String>? specialties,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/users/');
      final roleStr = role == UserRole.artisan ? 'artisan' : 'buyer';
      final body = {
        'username': phone.trim(),
        'password': password,
        'email': email.trim(),
        'phone': phone.trim(),
        'name': name.trim(),
        'location': location,
        'role': roleStr,
        'bio': bio ?? '',
        'stand_name': standName ?? '',
        'stand_location': standLocation ?? '',
      };

      final response = await http.post(
        url,
        headers: getHeaders(),
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        return await login(phone: phone, password: password);
      } else {
        return AuthResult(
          success: false,
          error: 'Erreur inscription: ${response.body}',
        );
      }
    } catch (e) {
      return AuthResult(success: false, error: 'Erreur réseau: $e');
    }
  }

  static Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: getHeaders(),
        body: json.encode({'username': phone.trim(), 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = UserModel.fromJson(data['user']);
        await AuthService.saveUserData(user, data['token']);
        return AuthResult(success: true, user: user, token: data['token']);
      }
      return AuthResult(success: false, error: 'Identifiants incorrects');
    } catch (e) {
      return AuthResult(success: false, error: 'Erreur réseau: $e');
    }
  }

  // --- Affichage artisan ---
  static Future<List<UserModel>> getArtisans() async {
    try {
      // ✅ PAS DE TOKEN pour les endpoints publics
      final response = await http.get(
        Uri.parse('$baseUrl/users/?role=artisan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        debugPrint('Erreur getArtisans: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Erreur réseau getArtisans: $e');
      return [];
    }
  }

  // --- Commandes utilisateur ---

  static Future<Map<String, dynamic>?> createOrder({
    required String deliveryAddress,
    String? deliveryPhone,
    required List<CartItemModel> cartItems,
    String paymentMethod = 'orange_money',
  }) async {
    try {
      final token = await AuthService.getToken();

      final body = {
        'delivery_address': deliveryAddress,
        'delivery_phone': deliveryPhone,
        'payment_method': paymentMethod,
        'items': cartItems
            .map((e) => {'product_id': e.product.id, 'quantity': e.quantity})
            .toList(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/orders/'),
        headers: getHeaders(token: token),
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint('Erreur createOrder: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Erreur réseau createOrder: $e');
      return null;
    }
  }

  static Future<List<OrderModel>> getMyOrders({int? limit}) async {
    try {
      final token = await AuthService.getToken();

      final uri = limit != null
          ? Uri.parse('$baseUrl/orders/my/?limit=$limit')
          : Uri.parse('$baseUrl/orders/my/');

      final response = await http.get(uri, headers: getHeaders(token: token));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => OrderModel.fromJson(e)).toList();
      } else {
        debugPrint('Erreur getMyOrders: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Erreur réseau getMyOrders: $e');
      return [];
    }
  }

  // --- Produits Réels ---
  static Future<List<Map<String, dynamic>>> getArtisanProducts({
    String? category,
    String? search,
  }) async {
    try {
      String url =
          '$baseUrl/artisan/products?'; // Assurez-vous que l'endpoint existe ou utilisez /products/
      // Fallback si l'endpoint artisan spécifique n'existe pas encore
      // url = '$baseUrl/products/';

      if (category != null) url += '&category=$category';
      if (search != null) url += '&search=$search';

      final response = await http.get(
        Uri.parse(url),
        headers: getHeaders(token: await AuthService.getToken()),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    required List<String> images,
    required bool isLimitedEdition,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products/'),
        headers: getHeaders(token: await AuthService.getToken()),
        body: json.encode({
          'name': name,
          'description': description,
          'price': price.toInt(),
          'stock': stock,
          'category': category,
          'is_limited_edition': isLimitedEdition,
          'images': images,
        }),
      );
      if (response.statusCode == 201)
        return json.decode(utf8.decode(response.bodyBytes));
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? category,
    List<String>? images,
    bool? isLimitedEdition,
    int? limitedQuantity,
    String? origin,
    List<String>? tags,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (price != null) body['price'] = price.toInt();
    if (stock != null) body['stock'] = stock;
    if (category != null) body['category'] = category;
    if (images != null) body['images'] = images;
    if (isLimitedEdition != null) body['is_limited_edition'] = isLimitedEdition;

    final response = await http.put(
      Uri.parse('$baseUrl/artisan/products/$productId/update'),
      headers: getHeaders(token: await AuthService.getToken()),
      body: json.encode(body),
    );
    if (response.statusCode == 200) return json.decode(response.body);
    return null;
  }

  static Future<bool> deleteProduct(String productId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/artisan/products/$productId/delete'),
      headers: getHeaders(token: await AuthService.getToken()),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }
}

// Classe Résultat Auth
class AuthResult {
  final bool success;
  final String? error;
  final UserModel? user;
  final String? token;
  AuthResult({required this.success, this.error, this.user, this.token});
}
