class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final List<String> images;
  final String? videoUrl;
  final String artisanId;
  final String artisanName;
  final String? artisanStand;
  final double rating;
  final int reviewCount;
  final bool isLimitedEdition;
  final int? limitedQuantity;
  final String? origin; // Provenance
  final List<String> tags;
  final DateTime createdAt;
  final bool isFavorite;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.images,
    this.videoUrl,
    required this.artisanId,
    required this.artisanName,
    this.artisanStand,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isLimitedEdition = false,
    this.limitedQuantity,
    this.origin,
    this.tags = const [],
    required this.createdAt,
    this.isFavorite = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    // 🔥 PARSER LES IMAGES - Gérer les deux formats
    List<String> parseImages(dynamic imagesData) {
      if (imagesData == null) return [];

      // Format 1 : Liste simple de strings (URLs)
      if (imagesData is List) {
        try {
          return List<String>.from(imagesData);
        } catch (e) {
          // Format 2 : Liste d'objets {id, image, is_main}
          return imagesData
              .map((img) => img['image']?.toString() ?? '')
              .where((url) => url.isNotEmpty)
              .toList()
              .cast<String>();
        }
      }

      return [];
    }

    return ProductModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: parseDouble(json['price']),
      stock: json['stock'] ?? 0,
      category: json['category'] ?? '',

      // 🔥 Utiliser la fonction de parsing
      images: parseImages(json['images'] ?? json['images_details']),

      videoUrl: json['videoUrl'] ?? json['video_url'],

      // 🔥 Gérer les données artisan (deux formats possibles)
      artisanId:
          json['artisanId']?.toString() ??
          json['artisan_details']?['id']?.toString() ??
          json['artisan']?.toString() ??
          '',

      artisanName:
          json['artisanName'] ??
          json['artisan_details']?['name'] ??
          json['artisan_details']?['first_name'] ??
          '',

      artisanStand:
          json['artisanStand'] ?? json['artisan_details']?['stand_name'],

      rating: parseDouble(json['rating'] ?? json['average_rating']),
      reviewCount: json['reviewCount'] ?? json['review_count'] ?? 0,

      isLimitedEdition:
          json['isLimitedEdition'] ?? json['is_limited_edition'] ?? false,

      limitedQuantity: json['limitedQuantity'] ?? json['limited_quantity'],
      origin: json['origin'],

      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],

      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),

      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'images': images,
      'videoUrl': videoUrl,
      'artisanId': artisanId,
      'artisanName': artisanName,
      'artisanStand': artisanStand,
      'rating': rating,
      'reviewCount': reviewCount,
      'isLimitedEdition': isLimitedEdition,
      'limitedQuantity': limitedQuantity,
      'origin': origin,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  ProductModel copyWith({bool? isFavorite, int? stock}) {
    return ProductModel(
      id: id,
      name: name,
      description: description,
      price: price,
      stock: stock ?? this.stock,
      category: category,
      images: images,
      videoUrl: videoUrl,
      artisanId: artisanId,
      artisanName: artisanName,
      artisanStand: artisanStand,
      rating: rating,
      reviewCount: reviewCount,
      isLimitedEdition: isLimitedEdition,
      limitedQuantity: limitedQuantity,
      origin: origin,
      tags: tags,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
