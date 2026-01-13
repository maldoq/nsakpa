class BlogArticleModel {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String author;
  final String authorRole;
  final String? authorImage;
  final String coverImage;
  final List<String> tags;
  final String category; // Histoire, Culture, Artisanat, Tradition
  final int readTime; // en minutes
  final DateTime publishedAt;
  final int likes;
  final int comments;
  final bool isFeatured;

  BlogArticleModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.author,
    required this.authorRole,
    this.authorImage,
    required this.coverImage,
    required this.tags,
    required this.category,
    required this.readTime,
    required this.publishedAt,
    this.likes = 0,
    this.comments = 0,
    this.isFeatured = false,
  });

  factory BlogArticleModel.fromJson(Map<String, dynamic> json) {
    return BlogArticleModel(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      content: json['content'],
      author: json['author'],
      authorRole: json['authorRole'],
      authorImage: json['authorImage'],
      coverImage: json['coverImage'],
      tags: List<String>.from(json['tags']),
      category: json['category'],
      readTime: json['readTime'],
      publishedAt: DateTime.parse(json['publishedAt']),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'author': author,
      'authorRole': authorRole,
      'authorImage': authorImage,
      'coverImage': coverImage,
      'tags': tags,
      'category': category,
      'readTime': readTime,
      'publishedAt': publishedAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'isFeatured': isFeatured,
    };
  }
}
