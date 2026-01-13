enum UserRole { visitor, buyer, artisan, communityAgent, admin, delivery }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? profileImage;
  final String? bio;
  final String? location;
  final double? rating;
  final int? totalSales;
  final bool isVerified;
  final bool isCertified;
  final DateTime createdAt;

  // Spécifique artisan
  final String? standName;
  final String? standLocation;
  final List<String>? specialties;
  final int? yearsOfExperience;
  final List<String>? certifications;
  final String? qrCode;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.bio,
    this.location,
    this.rating,
    this.totalSales,
    this.isVerified = false,
    this.isCertified = false,
    required this.createdAt,
    this.standName,
    this.standLocation,
    this.specialties,
    this.yearsOfExperience,
    this.certifications,
    this.qrCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parser le rôle - le backend envoie 'artisan', 'buyer', etc.
    UserRole parseRole(dynamic roleValue) {
      if (roleValue == null) return UserRole.visitor;

      try {
        final roleStr = roleValue.toString().toLowerCase().trim();

        // Gérer les différents formats possibles
        switch (roleStr) {
          case 'buyer':
          case 'acheteur':
            return UserRole.buyer;
          case 'artisan':
            return UserRole.artisan;
          case 'community_agent':
          case 'communityagent':
            return UserRole.communityAgent;
          case 'admin':
          case 'administrateur':
            return UserRole.admin;
          case 'delivery':
          case 'livreur':
            return UserRole.delivery;
          case 'visitor':
          case 'visiteur':
          default:
            return UserRole.visitor;
        }
      } catch (e) {
        return UserRole.visitor;
      }
    }

    // Parser la date de manière sécurisée
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      try {
        if (dateValue is String) {
          return DateTime.parse(dateValue);
        }
        return DateTime.now();
      } catch (e) {
        return DateTime.now();
      }
    }

    // Parser le rating de manière sécurisée
    double? parseRating(dynamic ratingValue) {
      if (ratingValue == null) return null;
      try {
        if (ratingValue is double) return ratingValue;
        if (ratingValue is int) return ratingValue.toDouble();
        if (ratingValue is String) {
          final parsed = double.tryParse(ratingValue);
          return parsed;
        }
        return null;
      } catch (e) {
        return null;
      }
    }

    // Parser les listes de manière sécurisée
    List<String>? parseStringList(dynamic listValue) {
      if (listValue == null) return null;
      try {
        if (listValue is List) {
          return listValue.map((e) => e.toString()).toList();
        }
        return null;
      } catch (e) {
        return null;
      }
    }

    // Parser les entiers de manière sécurisée
    int? parseInt(dynamic intValue) {
      if (intValue == null) return null;
      try {
        if (intValue is int) return intValue;
        if (intValue is String) return int.tryParse(intValue);
        return null;
      } catch (e) {
        return null;
      }
    }

    // S'assurer que les champs requis ne sont jamais null
    final idValue = json['id'];
    final nameValue = json['name'];
    final emailValue = json['email'];
    final phoneValue = json['phone'];
    final locationValue = json['location'];

    // Vérifier les champs obligatoires
    if (idValue == null) {
      throw Exception('Le champ id est obligatoire et ne peut pas être null');
    }
    if (nameValue == null || nameValue.toString().trim().isEmpty) {
      throw Exception(
        'Le champ name est obligatoire et ne peut pas être null ou vide',
      );
    }
    if (emailValue == null || emailValue.toString().trim().isEmpty) {
      throw Exception(
        'Le champ email est obligatoire et ne peut pas être null ou vide',
      );
    }
    if (phoneValue == null || phoneValue.toString().trim().isEmpty) {
      throw Exception(
        'Le champ phone est obligatoire et ne peut pas être null ou vide',
      );
    }

    // Convertir les valeurs en strings sécurisées
    final nameStr = nameValue.toString().trim();
    final emailStr = emailValue.toString().trim();
    final phoneStr = phoneValue.toString().trim();

    // Location peut être null selon le modèle Django, mais on préfère une valeur par défaut
    final locationFinal =
        locationValue != null && locationValue.toString().trim().isNotEmpty
        ? locationValue.toString().trim()
        : null;

    // S'assurer que tous les champs sont du bon type avant de créer UserModel
    try {
      // Convertir l'ID en string (peut être UUID ou string)
      final idString = idValue is String ? idValue : idValue.toString();

      // Parser tous les champs de manière sécurisée
      final parsedUser = UserModel(
        id: idString,
        name: nameStr,
        email: emailStr,
        phone: phoneStr,
        role: parseRole(json['role']),
        profileImage: _safeString(
          json['profileImage'] ?? json['profile_image'],
        ),
        bio: _safeString(json['bio']),
        location: locationFinal,
        rating: parseRating(json['rating']),
        totalSales: parseInt(json['totalSales'] ?? json['total_sales']),
        isVerified: _safeBool(json['isVerified'] ?? json['is_verified']),
        isCertified: _safeBool(json['isCertified'] ?? json['is_certified']),
        createdAt: parseDate(json['createdAt'] ?? json['date_joined']),
        standName: _safeString(json['standName'] ?? json['stand_name']),
        standLocation: _safeString(
          json['standLocation'] ?? json['stand_location'],
        ),
        specialties: parseStringList(json['specialties']),
        yearsOfExperience: parseInt(
          json['yearsOfExperience'] ?? json['years_of_experience'],
        ),
        certifications: parseStringList(json['certifications']),
        qrCode: _safeString(json['qrCode'] ?? json['qr_code']),
      );

      return parsedUser;
    } catch (e, stackTrace) {
      print('❌ ERREUR lors de la création de UserModel:');
      print('   Erreur: $e');
      print('   Type: ${e.runtimeType}');
      print('   Stack trace: $stackTrace');
      print('   JSON reçu: $json');
      rethrow;
    }
  }

  // Fonction helper pour convertir en String? de manière sécurisée
  static String? _safeString(dynamic value) {
    if (value == null) return null;
    try {
      final str = value.toString().trim();
      return str.isEmpty ? null : str;
    } catch (e) {
      return null;
    }
  }

  // Fonction helper pour convertir en bool de manière sécurisée
  static bool _safeBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString().split('.').last,
      'profileImage': profileImage,
      'bio': bio,
      'location': location,
      'rating': rating,
      'totalSales': totalSales,
      'isVerified': isVerified,
      'isCertified': isCertified,
      'createdAt': createdAt.toIso8601String(),
      'standName': standName,
      'standLocation': standLocation,
      'specialties': specialties,
      'yearsOfExperience': yearsOfExperience,
      'certifications': certifications,
      'qrCode': qrCode,
    };
  }

  /// Creates an empty user model (used as placeholder when user not found)
  factory UserModel.empty() {
    return UserModel(
      id: '',
      name: '',
      email: '',
      phone: '',
      role: UserRole.visitor,
      createdAt: DateTime.now(),
    );
  }
}
