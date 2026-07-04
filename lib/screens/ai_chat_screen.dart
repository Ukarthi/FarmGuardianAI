import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/mock_data.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({Key? key}) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _state = FarmState();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  final List<String> _quickPrompts = [
    'How is Zone A doing?',
    'Any pest alert in Orchard?',
    'Fertilizer recommendation',
  ];

  @override
  void initState() {
    super.initState();
    _state.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChange);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String message) {
    if (message.trim().isEmpty) return;
    
    _state.sendChatMessage(message);
    _controller.clear();
    setState(() => _isTyping = true);

    // Turn off typing indicator when bot answers
    Future.delayed(const Duration(seconds: 1.1), () {
      if (mounted) {
        setState(() => _isTyping = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top AI profile banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBgTranslucent,
            border: const Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGlow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Gemini Agronomist Consultant',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Contextually aware of IoT probes & drone history',
                    style: AppStyles.subtitleStyle,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Chat bubble lists
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            itemCount: _state.chats.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, idx) {
              if (idx == _state.chats.length && _isTyping) {
                return _buildTypingIndicator();
              }
              final chat = _state.chats[idx];
              final isUser = chat.role == 'user';
              return _buildChatBubble(chat.message, isUser);
            },
          ),
        ),

        // Quick query chips (displayed only if history is short or context matches)
        if (_state.chats.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8,
              children: _quickPrompts
                  .map((p) => ActionChip(
                        label: Text(p, style: const TextStyle(fontSize: 11)),
                        backgroundColor: AppColors.cardBg,
                        onPressed: () => _handleSend(p),
                      ))
                  .toList(),
            ),
          ),
        const SizedBox(height: 8),

        // Bottom message input field bar
        Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: AppStyles.bodyStyle,
                  decoration: InputDecoration(
                    hintText: 'Consult Farm Memory...',
                    hintStyle: AppStyles.subtitleStyle,
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.border),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onSubmitted: _handleSend,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: AppColors.background),
                  onPressed: () => _handleSend(_controller.text),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryGlow : AppColors.cardBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isUser ? 12 : 2),
            bottomRight: Radius.circular(isUser ? 2 : 12),
          ),
          border: Border.all(
            color: isUser ? AppColors.primary.withOpacity(0.2) : AppColors.border,
          ),
        ),
        child: Text(
          message,
          style: AppStyles.bodyStyle.copyWith(fontSize: 13, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'Typing analysis...',
          style: AppStyles.bodyStyle.copyWith(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}
