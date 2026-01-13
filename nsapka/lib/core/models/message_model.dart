enum MessageType {
  text,
  voice,
  image,
  product,
}

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String content;
  final String? translatedContent; // Traduction automatique
  final MessageType type;
  final String? imageUrl;
  final String? voiceUrl;
  final int? voiceDuration; // en secondes
  final bool isTranslated;
  final String originalLanguage;
  final String? targetLanguage;
  final DateTime sentAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.content,
    this.translatedContent,
    required this.type,
    this.imageUrl,
    this.voiceUrl,
    this.voiceDuration,
    this.isTranslated = false,
    this.originalLanguage = 'fr',
    this.targetLanguage,
    required this.sentAt,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      receiverId: json['receiverId'],
      content: json['content'],
      translatedContent: json['translatedContent'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
      ),
      imageUrl: json['imageUrl'],
      voiceUrl: json['voiceUrl'],
      voiceDuration: json['voiceDuration'],
      isTranslated: json['isTranslated'] ?? false,
      originalLanguage: json['originalLanguage'] ?? 'fr',
      targetLanguage: json['targetLanguage'],
      sentAt: DateTime.parse(json['sentAt']),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'content': content,
      'translatedContent': translatedContent,
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
      'voiceUrl': voiceUrl,
      'voiceDuration': voiceDuration,
      'isTranslated': isTranslated,
      'originalLanguage': originalLanguage,
      'targetLanguage': targetLanguage,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  MessageModel copyWith({
    bool? isRead,
    String? translatedContent,
    bool? isTranslated,
  }) {
    return MessageModel(
      id: id,
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      content: content,
      translatedContent: translatedContent ?? this.translatedContent,
      type: type,
      imageUrl: imageUrl,
      voiceUrl: voiceUrl,
      voiceDuration: voiceDuration,
      isTranslated: isTranslated ?? this.isTranslated,
      originalLanguage: originalLanguage,
      targetLanguage: targetLanguage,
      sentAt: sentAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
