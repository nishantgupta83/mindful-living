import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../base/base_component.dart';
import '../adaptive/adaptive_components.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/managers/localization_manager.dart';

/// Main voice assistant interface widget
/// Features conversation UI, voice visualization, and smart suggestions
class VoiceAssistantWidget extends BaseComponent {
  final VoiceAssistantState state;
  final VoidCallback? onStartListening;
  final VoidCallback? onStopListening;
  final Function(String)? onTextInput;
  final Function(String)? onSuggestionTap;
  final List<String> suggestions;
  final List<VoiceMessage> messages;
  final bool showSuggestions;
  final bool isMinimized;

  const VoiceAssistantWidget({
    super.key,
    required this.state,
    this.onStartListening,
    this.onStopListening,
    this.onTextInput,
    this.onSuggestionTap,
    this.suggestions = const [],
    this.messages = const [],
    this.showSuggestions = true,
    this.isMinimized = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isMinimized) {
      return _buildMinimizedView(context);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(context),
          if (state != VoiceAssistantState.idle) _buildVoiceVisualization(),
          _buildConversationArea(context),
          if (showSuggestions) _buildSuggestions(context),
          _buildInputArea(context),
          SizedBox(height: getSafeAreaPadding(context).bottom),
        ],
      ),
    );
  }

  Widget _buildMinimizedView(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _getStateColor(),
        shape: BoxShape.circle,
        boxShadow: softShadow,
      ),
      child: IconButton(
        onPressed: _handleMicTap,
        icon: Icon(
          _getStateIcon(),
          color: AppColors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: BaseComponent.spacingM),
      decoration: BoxDecoration(
        color: AppColors.textLight,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BaseComponent.spacingL),
      child: Row(
        children: [
          Icon(
            Icons.psychology,
            color: AppColors.primaryBlue,
            size: 24,
          ),
          const SizedBox(width: BaseComponent.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.voiceAssistant,
                  style: getTextTheme(context).titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _getStateText(context),
                  style: getTextTheme(context).bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildStateIndicator(),
        ],
      ),
    );
  }

  Widget _buildStateIndicator() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _getStateColor(),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildVoiceVisualization() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: BaseComponent.spacingL, vertical: BaseComponent.spacingM),
      child: VoiceVisualization(
        isActive: state == VoiceAssistantState.listening || 
                  state == VoiceAssistantState.processing,
        amplitude: state == VoiceAssistantState.listening ? 0.8 : 0.3,
        color: _getStateColor(),
      ),
    );
  }

  Widget _buildConversationArea(BuildContext context) {
    if (messages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(BaseComponent.spacingL),
        child: _buildWelcomeMessage(context),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: BaseComponent.spacingL),
      child: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return VoiceMessageBubble(
            message: message,
            isUser: message.isUser,
          );
        },
      ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(BaseComponent.spacingL),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: defaultBorderRadius,
          ),
          child: Column(
            children: [
              Icon(
                Icons.waving_hand,
                color: AppColors.primaryBlue,
                size: 32,
              ),
              const SizedBox(height: BaseComponent.spacingM),
              Text(
                context.l10n.askVoiceQuestion,
                style: getTextTheme(context).bodyMedium?.copyWith(
                  color: AppColors.primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: BaseComponent.spacingL),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: VoiceSuggestionChip(
              text: suggestion,
              onTap: () => onSuggestionTap?.call(suggestion),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(BaseComponent.spacingL),
      child: Row(
        children: [
          Expanded(
            child: VoiceTextInput(
              onSubmitted: onTextInput,
              enabled: state != VoiceAssistantState.processing,
              hintText: context.l10n.askVoiceQuestion,
            ),
          ),
          const SizedBox(width: BaseComponent.spacingM),
          VoiceMicButton(
            state: state,
            onPressed: _handleMicTap,
          ),
        ],
      ),
    );
  }

  void _handleMicTap() {
    AdaptiveComponents.provideFeedback(type: HapticFeedbackType.medium);
    
    switch (state) {
      case VoiceAssistantState.idle:
        onStartListening?.call();
        break;
      case VoiceAssistantState.listening:
        onStopListening?.call();
        break;
      case VoiceAssistantState.processing:
        // Do nothing during processing
        break;
    }
  }

  Color _getStateColor() {
    switch (state) {
      case VoiceAssistantState.idle:
        return AppColors.primaryBlue;
      case VoiceAssistantState.listening:
        return AppColors.error;
      case VoiceAssistantState.processing:
        return AppColors.mindfulOrange;
    }
  }

  IconData _getStateIcon() {
    switch (state) {
      case VoiceAssistantState.idle:
        return Icons.mic_none;
      case VoiceAssistantState.listening:
        return Icons.mic;
      case VoiceAssistantState.processing:
        return Icons.hourglass_empty;
    }
  }

  String _getStateText(BuildContext context) {
    switch (state) {
      case VoiceAssistantState.idle:
        return 'Tap to speak or type your question';
      case VoiceAssistantState.listening:
        return context.l10n.listening;
      case VoiceAssistantState.processing:
        return context.l10n.processing;
    }
  }
}

/// Voice visualization widget with animated bars
class VoiceVisualization extends StatefulWidget {
  final bool isActive;
  final double amplitude;
  final Color color;

  const VoiceVisualization({
    super.key,
    required this.isActive,
    required this.amplitude,
    required this.color,
  });

  @override
  State<VoiceVisualization> createState() => _VoiceVisualizationState();
}

class _VoiceVisualizationState extends State<VoiceVisualization>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animations = List.generate(7, (index) {
      return Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            0.7 + index * 0.1,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VoiceVisualization oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (index) {
            final height = widget.isActive
                ? 20 + (_animations[index].value * 40 * widget.amplitude)
                : 20.0;
            
            return Container(
              width: 4,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: widget.isActive ? 0.8 : 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Voice message bubble for conversation display
class VoiceMessageBubble extends BaseComponent {
  final VoiceMessage message;
  final bool isUser;

  const VoiceMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: BaseComponent.spacingXs),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          if (!isUser) const SizedBox(width: 8.0),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(BaseComponent.spacingM),
              decoration: BoxDecoration(
                color: isUser 
                    ? AppColors.primaryBlue 
                    : AppColors.softGray,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: isUser ? null : const Radius.circular(4),
                ),
              ),
              child: Text(
                message.text,
                style: getTextTheme(context).bodyMedium?.copyWith(
                  color: isUser ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8.0),
          if (isUser) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? AppColors.primaryBlue : AppColors.mindfulOrange,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.psychology,
        color: AppColors.white,
        size: 20,
      ),
    );
  }
}

/// Voice suggestion chip
class VoiceSuggestionChip extends BaseComponent {
  final String text;
  final VoidCallback? onTap;

  const VoiceSuggestionChip({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AdaptiveComponents.provideFeedback(type: HapticFeedbackType.light);
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: BaseComponent.spacingM,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: getTextTheme(context).bodySmall?.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Voice text input field
class VoiceTextInput extends BaseComponent {
  final Function(String)? onSubmitted;
  final bool enabled;
  final String? hintText;

  const VoiceTextInput({
    super.key,
    this.onSubmitted,
    this.enabled = true,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: getTextTheme(context).bodyMedium?.copyWith(
          color: AppColors.textLight,
        ),
        filled: true,
        fillColor: AppColors.softGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: BaseComponent.spacingL,
          vertical: BaseComponent.spacingM,
        ),
        suffixIcon: Icon(
          Icons.send,
          color: AppColors.textLight,
        ),
      ),
      style: getTextTheme(context).bodyMedium?.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }
}

/// Voice microphone button with state indication
class VoiceMicButton extends BaseComponent {
  final VoiceAssistantState state;
  final VoidCallback? onPressed;

  const VoiceMicButton({
    super.key,
    required this.state,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _getButtonColor(),
        shape: BoxShape.circle,
        boxShadow: state == VoiceAssistantState.listening ? [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ] : softShadow,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _getButtonIcon(),
            key: ValueKey(state),
            color: AppColors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Color _getButtonColor() {
    switch (state) {
      case VoiceAssistantState.idle:
        return AppColors.primaryBlue;
      case VoiceAssistantState.listening:
        return AppColors.error;
      case VoiceAssistantState.processing:
        return AppColors.mindfulOrange;
    }
  }

  IconData _getButtonIcon() {
    switch (state) {
      case VoiceAssistantState.idle:
        return Icons.mic_none;
      case VoiceAssistantState.listening:
        return Icons.stop;
      case VoiceAssistantState.processing:
        return Icons.hourglass_empty;
    }
  }
}

/// Voice assistant state enum
enum VoiceAssistantState {
  idle,
  listening,
  processing,
}

/// Voice message model
class VoiceMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  VoiceMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.metadata,
  });

  factory VoiceMessage.user(String text) {
    return VoiceMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory VoiceMessage.assistant(String text, {Map<String, dynamic>? metadata}) {
    return VoiceMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
  }
}