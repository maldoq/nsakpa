import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../chat/screens/chat_screen_v2.dart';
import '../../../core/services/auth_service.dart';

class ArtisanChatScreen extends StatefulWidget {
  const ArtisanChatScreen({super.key});

  @override
  State<ArtisanChatScreen> createState() => _ArtisanChatScreenState();
}

class _ArtisanChatScreenState extends State<ArtisanChatScreen> {
  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final chats = await ApiService.getArtisanChats();
      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.secondary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
          ? _buildEmptyState()
          : _buildChatsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun message',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsList() {
    return RefreshIndicator(
      onRefresh: _loadChats,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return _buildChatCard(chat);
        },
      ),
    );
  }

  Widget _buildChatCard(Map<String, dynamic> chat) {
    // -------------------------------------------------------------------------
    // CORRECTION DÉFENSIVE : Gestion des champs pouvant arriver en List ou Map
    // -------------------------------------------------------------------------

    // 1. Sécurisation de "other_user"
    var rawOtherUser = chat['other_user'];
    Map<String, dynamic>? otherUser;
    if (rawOtherUser is List) {
      if (rawOtherUser.isNotEmpty) {
        otherUser = rawOtherUser[0] as Map<String, dynamic>;
      }
    } else if (rawOtherUser is Map) {
      otherUser = rawOtherUser as Map<String, dynamic>;
    }

    // 2. Sécurisation de "last_message"
    var rawLastMessage = chat['last_message'];
    Map<String, dynamic>? lastMessage;
    if (rawLastMessage is List) {
      if (rawLastMessage.isNotEmpty) {
        lastMessage = rawLastMessage[0] as Map<String, dynamic>;
      }
    } else if (rawLastMessage is Map) {
      lastMessage = rawLastMessage as Map<String, dynamic>;
    }

    final unreadCount = chat['unread_count'] ?? 0;
    final otherUserName = otherUser?['name'] ?? 'Utilisateur';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.accent,
          backgroundImage:
              otherUser != null && otherUser['profile_image'] != null
              ? NetworkImage(otherUser['profile_image'])
              : null,
          child: otherUser == null || otherUser['profile_image'] == null
              ? Text(
                  otherUserName.isNotEmpty
                      ? otherUserName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(color: AppColors.textWhite),
                )
              : null,
        ),
        title: Text(
          otherUserName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: lastMessage != null
            ? Text(
                lastMessage['content'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : const Text('Aucun message'),
        trailing: unreadCount > 0
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () async {
          final currentUser = await AuthService.getCurrentUser();
          if (currentUser != null && otherUser != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreenV2(
                  otherUserId: otherUser!['id'],
                  currentUserId: currentUser.id,
                ),
              ),
            ).then((_) => _loadChats());
          }
        },
      ),
    );
  }
}
