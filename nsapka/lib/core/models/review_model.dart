class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userImage;
  final double rating;
  final String comment;
  final List<String> images; // Photos du produit reçu
  final DateTime createdAt;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final String? artisanResponse;
  final DateTime? artisanResponseDate;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.createdAt,
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    this.artisanResponse,
    this.artisanResponseDate,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      productId: json['productId'],
      userId: json['userId'],
      userName: json['userName'],
      userImage: json['userImage'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      isVerifiedPurchase: json['isVerifiedPurchase'] ?? false,
      helpfulCount: json['helpfulCount'] ?? 0,
      artisanResponse: json['artisanResponse'],
      artisanResponseDate: json['artisanResponseDate'] != null
          ? DateTime.parse(json['artisanResponseDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'rating': rating,
      'comment': comment,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'isVerifiedPurchase': isVerifiedPurchase,
      'helpfulCount': helpfulCount,
      'artisanResponse': artisanResponse,
      'artisanResponseDate': artisanResponseDate?.toIso8601String(),
    };
  }
}
