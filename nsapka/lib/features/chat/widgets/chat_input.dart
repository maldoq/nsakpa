import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSendText;
  final VoidCallback onSendVoice;
  final VoidCallback onSendImage;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSendText,
    required this.onSendVoice,
    required this.onSendImage,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Bouton image
            IconButton(
              onPressed: widget.onSendImage,
              icon: const Icon(Icons.image, color: AppColors.primary),
              tooltip: 'Envoyer une image',
            ),
            
            const SizedBox(width: 8),
            
            // Champ de texte
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    hintText: 'Écrivez votre message...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Bouton vocal / envoyer
            ValueListenableBuilder(
              valueListenable: widget.controller,
              builder: (context, value, child) {
                final hasText = value.text.trim().isNotEmpty;
                
                return GestureDetector(
                  onTap: hasText
                      ? () => widget.onSendText(widget.controller.text)
                      : null,
                  onLongPressStart: hasText ? null : (_) {
                    setState(() {
                      isRecording = true;
                    });
                  },
                  onLongPressEnd: hasText ? null : (_) {
                    setState(() {
                      isRecording = false;
                    });
                    widget.onSendVoice();
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: isRecording
                          ? const LinearGradient(
                              colors: [AppColors.error, AppColors.warning],
                            )
                          : AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isRecording ? AppColors.error : AppColors.primary)
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      hasText
                          ? Icons.send
                          : isRecording
                              ? Icons.mic
                              : Icons.mic_none,
                      color: AppColors.textWhite,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
