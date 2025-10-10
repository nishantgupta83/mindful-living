import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/firebase_service.dart';

class ChatAssistantWidget extends StatefulWidget {
  final List<Color> gradientColors;
  final Function(Map<String, dynamic>) onDilemmaSelected;

  const ChatAssistantWidget({
    super.key,
    required this.gradientColors,
    required this.onDilemmaSelected,
  });

  @override
  State<ChatAssistantWidget> createState() => _ChatAssistantWidgetState();
}

class _ChatAssistantWidgetState extends State<ChatAssistantWidget>
    with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingAnimController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    _typingAnimController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingAnimController,
      curve: Curves.easeInOut,
    ));

    // Add welcome message
    _messages.add(ChatMessage(
      text: "Hi! I'm your Life Guide Assistant. Tell me what's on your mind, and I'll help you find relevant guidance and wisdom.",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();
    HapticFeedback.lightImpact();

    // Get AI response
    final response = await _firebaseService.getChatResponse(text);

    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: response['message'],
        isUser: false,
        timestamp: DateTime.now(),
        relatedDilemmas: response['relatedDilemmas'],
        suggestions: response['suggestions'],
      ));
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            widget.gradientColors[0].withValues(alpha: 0.02),
            widget.gradientColors[1].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.gradientColors[0].withValues(alpha: 0.2),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assistant,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Life Guide Assistant',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Ask me anything',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: AppTypography.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: widget.gradientColors),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? LinearGradient(colors: widget.gradientColors)
                    : null,
                color: message.isUser ? null : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: AppTypography.bodyMedium.copyWith(
                  color: message.isUser ? Colors.white : Colors.grey[800],
                ),
              ),
            ),

            // Related Dilemmas
            if (message.relatedDilemmas != null && message.relatedDilemmas!.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...message.relatedDilemmas!.map((dilemma) => GestureDetector(
                onTap: () {
                  widget.onDilemmaSelected(dilemma);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.gradientColors[0].withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.gradientColors[0].withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 16,
                        color: widget.gradientColors[0],
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          dilemma['title'],
                          style: AppTypography.labelMedium.copyWith(
                            color: widget.gradientColors[0],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ],

            // Suggestions
            if (message.suggestions != null && message.suggestions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.suggestions!.map((suggestion) => GestureDetector(
                  onTap: () {
                    _messageController.text = suggestion;
                    _sendMessage();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: widget.gradientColors[0].withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      suggestion,
                      style: AppTypography.labelSmall.copyWith(
                        color: widget.gradientColors[0],
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedBuilder(
          animation: _typingAnimation,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final delay = index * 0.2;
                final value = (_typingAnimation.value - delay).clamp(0.0, 1.0);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.gradientColors[0].withValues(
                      alpha: 0.3 + (0.7 * value),
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Map<String, dynamic>>? relatedDilemmas;
  final List<String>? suggestions;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.relatedDilemmas,
    this.suggestions,
  });
}