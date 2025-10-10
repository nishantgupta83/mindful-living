import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'pastel_card.dart';
import 'pastel_button.dart';

// For now, we'll use a mock player implementation
// In production, this would integrate with just_audio or audioplayers
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  bool _isPlaying = false;
  bool _isPaused = false;
  Duration _currentPosition = Duration.zero;
  Duration _duration = const Duration(minutes: 5, seconds: 30); // Mock duration
  Timer? _timer;
  final StreamController<AudioPlayerState> _stateController = 
      StreamController<AudioPlayerState>.broadcast();

  Stream<AudioPlayerState> get stateStream => _stateController.stream;
  
  AudioPlayerState get currentState => AudioPlayerState(
    isPlaying: _isPlaying,
    isPaused: _isPaused,
    currentPosition: _currentPosition,
    duration: _duration,
  );

  Future<void> play(String url) async {
    if (!_isPlaying) {
      _isPlaying = true;
      _isPaused = false;
      _startTimer();
      _stateController.add(currentState);
    }
  }

  Future<void> pause() async {
    if (_isPlaying) {
      _isPlaying = false;
      _isPaused = true;
      _timer?.cancel();
      _stateController.add(currentState);
    }
  }

  Future<void> stop() async {
    _isPlaying = false;
    _isPaused = false;
    _currentPosition = Duration.zero;
    _timer?.cancel();
    _stateController.add(currentState);
  }

  Future<void> seek(Duration position) async {
    _currentPosition = position;
    _stateController.add(currentState);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentPosition.inSeconds < _duration.inSeconds) {
        _currentPosition = Duration(seconds: _currentPosition.inSeconds + 1);
        _stateController.add(currentState);
      } else {
        stop(); // Auto-stop when finished
      }
    });
  }

  void dispose() {
    _timer?.cancel();
    _stateController.close();
  }
}

class AudioPlayerState {
  final bool isPlaying;
  final bool isPaused;
  final Duration currentPosition;
  final Duration duration;

  AudioPlayerState({
    required this.isPlaying,
    required this.isPaused,
    required this.currentPosition,
    required this.duration,
  });

  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return currentPosition.inMilliseconds / duration.inMilliseconds;
  }

  String get positionText {
    return _formatDuration(currentPosition);
  }

  String get durationText {
    return _formatDuration(duration);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class AudioPlayerCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String audioUrl;
  final bool isExpanded;
  final VoidCallback? onExpand;
  final VoidCallback? onCollapse;
  final bool showWaveform;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const AudioPlayerCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.audioUrl,
    this.isExpanded = false,
    this.onExpand,
    this.onCollapse,
    this.showWaveform = false,
    this.margin,
    this.padding,
  });

  @override
  State<AudioPlayerCard> createState() => _AudioPlayerCardState();
}

class _AudioPlayerCardState extends State<AudioPlayerCard>
    with SingleTickerProviderStateMixin {
  late AudioPlayerService _playerService;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  StreamSubscription<AudioPlayerState>? _stateSubscription;
  AudioPlayerState _playerState = AudioPlayerState(
    isPlaying: false,
    isPaused: false,
    currentPosition: Duration.zero,
    duration: const Duration(minutes: 5, seconds: 30),
  );

  @override
  void initState() {
    super.initState();
    _playerService = AudioPlayerService();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOut,
    );

    _stateSubscription = _playerService.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });

    if (widget.isExpanded) {
      _expandController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    if (_expandController.isCompleted) {
      _expandController.reverse();
      widget.onCollapse?.call();
    } else {
      _expandController.forward();
      widget.onExpand?.call();
    }
  }

  void _togglePlayPause() {
    if (_playerState.isPlaying) {
      _playerService.pause();
    } else {
      _playerService.play(widget.audioUrl);
    }
  }

  void _onSeek(double value) {
    final position = Duration(
      milliseconds: (value * _playerState.duration.inMilliseconds).round(),
    );
    _playerService.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return PastelCard.gradient(
      gradientColors: AppColors.oceanGradient,
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: widget.padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildProgressBar(),
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _expandAnimation,
                child: child,
              );
            },
            child: _buildExpandedContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Play/Pause Button
        PastelIconButton(
          icon: _playerState.isPlaying ? Icons.pause : Icons.play_arrow,
          onPressed: _togglePlayPause,
          style: PastelButtonStyle.gradient,
          gradientColors: AppColors.sunsetGradient,
          size: PastelButtonSize.medium,
        ),
        
        const SizedBox(width: 12),
        
        // Title and Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepLavender,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.softCharcoal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        
        // Time Display
        Text(
          '${_playerState.positionText} / ${_playerState.durationText}',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.lightGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Expand/Collapse Button
        PastelIconButton(
          icon: _expandController.isCompleted
              ? Icons.expand_less
              : Icons.expand_more,
          onPressed: _toggleExpansion,
          style: PastelButtonStyle.ghost,
          size: PastelButtonSize.small,
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.deepLavender,
            inactiveTrackColor: AppColors.withOpacity(AppColors.softCharcoal, 0.2),
            thumbColor: AppColors.deepLavender,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            trackHeight: 3,
          ),
          child: Slider(
            value: _playerState.progress.clamp(0.0, 1.0),
            onChanged: _onSeek,
            min: 0.0,
            max: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(
            color: AppColors.paleGray,
            thickness: 1,
          ),
          const SizedBox(height: 16),
          
          // Waveform Placeholder (if enabled)
          if (widget.showWaveform) ...[
            _buildWaveformPlaceholder(),
            const SizedBox(height: 16),
          ],
          
          // Additional Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PastelIconButton(
                icon: Icons.replay_10,
                onPressed: () {
                  final newPosition = Duration(
                    milliseconds: (_playerState.currentPosition.inMilliseconds - 10000)
                        .clamp(0, _playerState.duration.inMilliseconds),
                  );
                  _playerService.seek(newPosition);
                },
                style: PastelButtonStyle.ghost,
                size: PastelButtonSize.small,
                tooltip: 'Rewind 10s',
              ),
              
              PastelIconButton(
                icon: Icons.stop,
                onPressed: () => _playerService.stop(),
                style: PastelButtonStyle.ghost,
                size: PastelButtonSize.small,
                tooltip: 'Stop',
              ),
              
              PastelIconButton(
                icon: Icons.forward_10,
                onPressed: () {
                  final newPosition = Duration(
                    milliseconds: (_playerState.currentPosition.inMilliseconds + 10000)
                        .clamp(0, _playerState.duration.inMilliseconds),
                  );
                  _playerService.seek(newPosition);
                },
                style: PastelButtonStyle.ghost,
                size: PastelButtonSize.small,
                tooltip: 'Forward 10s',
              ),
              
              PastelIconButton(
                icon: Icons.download_outlined,
                onPressed: () {
                  // TODO: Implement download functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Download coming soon!')),
                  );
                },
                style: PastelButtonStyle.ghost,
                size: PastelButtonSize.small,
                tooltip: 'Download',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaveformPlaceholder() {
    // Mock waveform visualization
    return Container(
      height: 60,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.withOpacity(AppColors.softCharcoal, 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(30, (index) {
          final height = (index % 5 + 1) * 6.0;
          final isActive = _playerState.progress * 30 > index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 2,
            height: height,
            decoration: BoxDecoration(
              color: isActive 
                  ? AppColors.deepLavender 
                  : AppColors.withOpacity(AppColors.softCharcoal, 0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }),
      ),
    );
  }
}

// Compact version for lists
class CompactAudioPlayer extends StatelessWidget {
  final String title;
  final String audioUrl;
  final VoidCallback? onExpand;

  const CompactAudioPlayer({
    super.key,
    required this.title,
    required this.audioUrl,
    this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return PastelCard(
      backgroundColor: AppColors.lemon,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            Icons.headphones,
            size: 20,
            color: AppColors.softCharcoal,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Listen: $title',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.softCharcoal,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          PastelIconButton(
            icon: Icons.play_arrow,
            onPressed: onExpand,
            style: PastelButtonStyle.ghost,
            size: PastelButtonSize.small,
          ),
        ],
      ),
    );
  }
}