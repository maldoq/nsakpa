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
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      stock: json['stock'],
      category: json['category'],
      images: List<String>.from(json['images']),
      videoUrl: json['videoUrl'],
      artisanId: json['artisanId'],
      artisanName: json['artisanName'],
      artisanStand: json['artisanStand'],
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      isLimitedEdition: json['isLimitedEdition'] ?? false,
      limitedQuantity: json['limitedQuantity'],
      origin: json['origin'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      createdAt: DateTime.parse(json['createdAt']),
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
  
  ProductModel copyWith({
    bool? isFavorite,
    int? stock,
  }) {
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
