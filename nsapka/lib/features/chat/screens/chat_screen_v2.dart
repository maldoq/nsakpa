import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/message_model.dart';
import '../../../core/models/user_model.dart';
import '../widgets/message_bubble.dart';

class ChatScreenV2 extends StatefulWidget {
  final String otherUserId;
  final String currentUserId;

  const ChatScreenV2({
    super.key,
    required this.otherUserId,
    required this.currentUserId,
  });

  @override
  State<ChatScreenV2> createState() => _ChatScreenV2State();
}

class _ChatScreenV2State extends State<ChatScreenV2> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showTranslation = false;
  bool _isRecording = false;
  bool _isTyping = false;
  bool _agentEnabled = true;
  UserRole _currentRole = UserRole.artisan;
 
  // Mock chat storage
  final StreamController<List<MessageModel>> _messagesCtrl = StreamController.broadcast();
  final List<MessageModel> _messages = [];
  
  late AnimationController _recordingController;
  late Animation<double> _recordingAnimation;

  @override
  void initState() {
    super.initState();
    _recordingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _recordingAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _recordingController, curve: Curves.easeInOut),
    );
 
    // Seed initial mock messages
    final now = DateTime.now();
    _messages.addAll([
      MessageModel(
        id: '${now.millisecondsSinceEpoch}-1',
        senderId: widget.otherUserId,
        senderName: 'Artisan',
        receiverId: widget.currentUserId,
        content: 'Bonjour, comment puis-je vous aider ?',
        type: MessageType.text,
        sentAt: now.subtract(const Duration(minutes: 5)),
      ),
      MessageModel(
        id: '${now.millisecondsSinceEpoch}-2',
        senderId: widget.currentUserId,
        senderName: 'Vous',
        receiverId: widget.otherUserId,
        content: 'Je veux plus de détails sur le produit.',
        type: MessageType.text,
        sentAt: now.subtract(const Duration(minutes: 4)),
      ),
    ]);
    _messagesCtrl.add(List.unmodifiable(_messages));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _recordingController.dispose();
    _messagesCtrl.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final artisan = MockData.artisans.firstWhere(
      (a) => a.id == widget.otherUserId,
      orElse: () => MockData.artisans.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: _buildAppBar(artisan),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _messagesCtrl.stream,
              builder: (context, snapshot) {
                final items = snapshot.data ?? const [];
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final msg = items[index];
                    final isMe = msg.senderId == widget.currentUserId;
                    return MessageBubble(
                      message: msg,
                      isMe: isMe,
                      showTranslation: _showTranslation,
                    );
                  },
                );
              },
            ),
          ),
          
          // Indicateur "en train d'écrire"
          if (_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: artisan.profileImage != null
                        ? AssetImage(artisan.profileImage!)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTypingDot(0),
                        const SizedBox(width: 4),
                        _buildTypingDot(200),
                        const SizedBox(width: 4),
                        _buildTypingDot(400),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // Barre de saisie
          _buildInputBar(artisan),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(artisan) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textWhite,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.accent,
                backgroundImage: artisan.profileImage != null
                    ? AssetImage(artisan.profileImage!)
                    : null,
                child: artisan.profileImage == null
                    ? Text(
                        artisan.name[0],
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artisan.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'En ligne',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textWhite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.phone, size: 20),
            onPressed: () {
              _showVoiceCallDialog();
            },
            tooltip: 'Appel vocal',
          ),
        ),
        Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _showTranslation ? AppColors.accent : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.translate, size: 20),
            onPressed: () {
              setState(() {
                _showTranslation = !_showTranslation;
              });
              HapticFeedback.lightImpact();
            },
            tooltip: 'Traduction',
          ),
        ),
        if (_currentRole == UserRole.artisan)
          Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _agentEnabled ? AppColors.secondary : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.headset_mic, size: 20),
              onPressed: () {
                _showAgentHelper();
              },
              tooltip: 'Assistant',
            ),
          ),
        if (_currentRole == UserRole.admin)
          Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.admin_panel_settings, size: 20),
              onPressed: () {
                _showAdminQuickActions();
              },
              tooltip: 'Admin',
            ),
          ),
      ],
    );
  }

  // Send helpers (mock)
  void _appendMessage(MessageModel msg) {
    _messages.add(msg);
    _messagesCtrl.add(List.unmodifiable(_messages));
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _simulateAgentReply(String userText) {
    if (!_agentEnabled) return;
    Future.delayed(const Duration(milliseconds: 1200), () {
      final now = DateTime.now();
      _appendMessage(
        MessageModel(
          id: '${now.millisecondsSinceEpoch}-agent',
          senderId: 'agent',
          senderName: 'Agent',
          receiverId: widget.currentUserId,
          content: 'Bonjour, je suis l\'agent communautaire. Besoin d\'aide pour: Catalogue, Répondre au client, ou Accueil Artisan ?',
          type: MessageType.text,
          sentAt: now,
        ),
      );
    });
  }

  Widget _buildInputBar(artisan) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Bouton vocal
            _isRecording
                ? ScaleTransition(
                    scale: _recordingAnimation,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.stop, color: AppColors.textWhite),
                        onPressed: () {
                          setState(() {
                            _isRecording = false;
                          });
                          HapticFeedback.mediumImpact();
                        },
                      ),
                    ),
                  )
                : Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.mic, color: AppColors.textWhite),
                      onPressed: () {
                        setState(() {
                          _isRecording = true;
                        });
                        HapticFeedback.heavyImpact();
                      },
                      tooltip: 'Message vocal',
                    ),
                  ),
            
            const SizedBox(width: 8),
            
            // Champ de texte
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.textWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Écrivez votre message...',
                          border: InputBorder.none,
                        ),
                        onChanged: (text) {
                          setState(() {
                            _isTyping = text.isNotEmpty;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: AppColors.textSecondary),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: AppColors.textSecondary),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Bouton envoyer
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: AppColors.textWhite),
                onPressed: () {
                  final text = _messageController.text.trim();
                  if (text.isEmpty) return;
                  final now = DateTime.now();
                  final msg = MessageModel(
                    id: '${now.millisecondsSinceEpoch}-${_messages.length + 1}',
                    senderId: widget.currentUserId,
                    senderName: 'Vous',
                    receiverId: widget.otherUserId,
                    content: text,
                    type: MessageType.text,
                    sentAt: now,
                  );
                  _appendMessage(msg);
                  _simulateAgentReply(text);
                  _messageController.clear();
                  setState(() {
                    _isTyping = false;
                  });
                  HapticFeedback.lightImpact();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withValues(alpha: value),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  void _showVoiceCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.phone, color: AppColors.success),
            SizedBox(width: 12),
            Text('Appel vocal'),
          ],
        ),
        content: const Text(
          'Voulez-vous appeler cet artisan ?\n\nL\'appel sera gratuit via l\'application.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appel en cours...'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('Appeler'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }

  void _showAgentHelper() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                value: _agentEnabled,
                onChanged: (v) {
                  setState(() {
                    _agentEnabled = v;
                  });
                  Navigator.pop(context);
                },
                title: const Text('Activer l\'assistant'),
                secondary: const Icon(Icons.headset_mic),
              ),
              ListTile(
                leading: const Icon(Icons.storefront),
                title: const Text('Aller au Catalogue'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/catalog', arguments: {'isVisitorMode': false});
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Ouvrir le Chat'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/chat', arguments: {
                    'otherUserId': widget.otherUserId,
                    'currentUserId': widget.currentUserId,
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.home_repair_service),
                title: const Text('Accueil Artisan'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/artisan-home');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAdminQuickActions() {
    if (_currentRole != UserRole.admin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Accès réservé à l’administrateur'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Aperçu Acheteur'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/buyer-home', arguments: {'isVisitorMode': false});
                },
              ),
              ListTile(
                leading: const Icon(Icons.people_alt),
                title: const Text('Artisans'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/artisans');
                },
              ),
              ListTile(
                leading: const Icon(Icons.article),
                title: const Text('Blog/Annonces'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/blog');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
