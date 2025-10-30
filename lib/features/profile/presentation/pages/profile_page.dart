import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/user_preferences_service.dart';
import '../../../../core/services/error_handling_service.dart';
import '../../../auth/data/auth_service.dart';

/// Enhanced Profile/More Screen
/// Inspired by GitaWisdom2's more_screen with Material Design 3 & iOS HIG patterns
/// Features: Account management, appearance settings, wellness preferences, support
class ProfilePage extends StatefulWidget {
  final Function(int)? onTabChange;

  const ProfilePage({super.key, this.onTabChange});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final UserPreferencesService _prefsService = UserPreferencesService();
  String _appVersion = '';
  bool _isLoading = false;

  // Settings state
  bool _darkModeEnabled = false;
  bool _backgroundMusicEnabled = false;
  bool _breathingRemindersEnabled = true;
  String _fontSize = 'Medium';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadUserPreferences();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})');
    } catch (e) {
      if (mounted) setState(() => _appVersion = 'Unknown');
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await _prefsService.loadAllPreferences();
      if (mounted) {
        setState(() {
          _darkModeEnabled = prefs['darkMode'] as bool;
          _backgroundMusicEnabled = prefs['backgroundMusic'] as bool;
          _breathingRemindersEnabled = prefs['breathingReminders'] as bool;
          _fontSize = prefs['fontSize'] as String;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(user),
          SliverList(
            delegate: SliverChildListDelegate([
              // Account Section (if logged in)
              if (user != null) ...[
                _buildAccountSection(user),
                const Divider(height: 32, thickness: 1),
              ],

              // Wellness Settings
              _buildWellnessSection(),
              const Divider(height: 32, thickness: 1),

              // Appearance Settings
              _buildAppearanceSection(),
              const Divider(height: 32, thickness: 1),

              // Content Features
              _buildContentSection(),
              const Divider(height: 32, thickness: 1),

              // Support & Resources
              _buildSupportSection(),

              // App Version Footer
              _buildVersionFooter(),

              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(User? user) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          user != null ? 'Your Profile' : 'Settings',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.dreamGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Circular avatar with soft shadow (Calm/Headspace pattern)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: user?.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              user!.photoURL!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: AppColors.deepLavender,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                if (user != null) ...[
                  Text(
                    user.displayName ?? 'Mindful User',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  if (user.email != null)
                    Text(
                      user.email!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                        shadows: const [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection(User user) {
    return _buildSection(
      'Account',
      Icons.account_circle_rounded,
      [
        _buildTile(
          icon: Icons.logout_rounded,
          title: 'Sign Out',
          subtitle: 'Sign out of your account',
          color: AppColors.warning,
          onTap: _handleSignOut,
        ),
        _buildTile(
          icon: Icons.delete_forever_rounded,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account and data',
          color: AppColors.error,
          onTap: _handleDeleteAccount,
        ),
      ],
    );
  }

  Widget _buildWellnessSection() {
    return _buildSection(
      'Wellness Preferences',
      Icons.favorite_rounded,
      [
        _buildTile(
          icon: Icons.air_rounded,
          title: 'Breathing Reminders',
          subtitle: 'Get gentle reminders to breathe mindfully',
          switchValue: _breathingRemindersEnabled,
          onSwitchChanged: (value) async {
            setState(() => _breathingRemindersEnabled = value);
            await _prefsService.saveBreathingReminders(value);
          },
        ),
        _buildTile(
          icon: Icons.music_note_rounded,
          title: 'Background Music',
          subtitle: 'Play calming music during practices',
          switchValue: _backgroundMusicEnabled,
          onSwitchChanged: (value) async {
            setState(() => _backgroundMusicEnabled = value);
            await _prefsService.saveBackgroundMusic(value);
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSection(
      'Appearance',
      Icons.palette_rounded,
      [
        _buildTile(
          icon: Icons.dark_mode_rounded,
          title: 'Dark Mode',
          subtitle: 'Reduce eye strain in low light',
          switchValue: _darkModeEnabled,
          onSwitchChanged: (value) async {
            setState(() => _darkModeEnabled = value);
            await _prefsService.saveDarkMode(value);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dark mode coming soon!'), duration: Duration(seconds: 2)),
              );
            }
          },
        ),
        _buildTile(
          icon: Icons.text_fields_rounded,
          title: 'Text Size',
          subtitle: 'Adjust text size for readability',
          dropdownValue: _fontSize,
          dropdownItems: ['Small', 'Medium', 'Large'],
          onDropdownChanged: (value) async {
            setState(() => _fontSize = value ?? 'Medium');
            await _prefsService.saveFontSize(value ?? 'Medium');
          },
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return _buildSection(
      'Content',
      Icons.explore_rounded,
      [
        _buildTile(
          icon: Icons.search_rounded,
          title: 'Search Situations',
          subtitle: 'Find guidance for any life situation',
          onTap: () {
            // Navigate to explore tab (index 1)
            widget.onTabChange?.call(1);
          },
        ),
        _buildTile(
          icon: Icons.share_rounded,
          title: 'Share App',
          subtitle: 'Share Mindful Living with friends',
          onTap: _handleShareApp,
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSection(
      'Support & Resources',
      Icons.help_rounded,
      [
        _buildTile(
          icon: Icons.info_rounded,
          title: 'About',
          subtitle: 'Learn about Mindful Living',
          onTap: _handleAbout,
        ),
        _buildTile(
          icon: Icons.feedback_rounded,
          title: 'Send Feedback',
          subtitle: 'Help us improve the app',
          onTap: _handleFeedback,
        ),
        _buildTile(
          icon: Icons.privacy_tip_rounded,
          title: 'Privacy Policy',
          subtitle: 'How we protect your data',
          onTap: () => _launchURL('https://mindful-living.app/privacy'),
        ),
        _buildTile(
          icon: Icons.description_rounded,
          title: 'Terms of Service',
          subtitle: 'Our terms and conditions',
          onTap: () => _launchURL('https://mindful-living.app/terms'),
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lavender.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.deepLavender,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepLavender,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    VoidCallback? onTap,
    bool? switchValue,
    ValueChanged<bool>? onSwitchChanged,
    String? dropdownValue,
    List<String>? dropdownItems,
    ValueChanged<String?>? onDropdownChanged,
  }) {
    final Widget trailing;
    if (switchValue != null && onSwitchChanged != null) {
      trailing = Switch(
        value: switchValue,
        onChanged: onSwitchChanged,
        activeTrackColor: AppColors.lavender,
      );
    } else if (dropdownValue != null && dropdownItems != null && onDropdownChanged != null) {
      trailing = DropdownButton<String>(
        value: dropdownValue,
        items: dropdownItems.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onDropdownChanged,
        underline: Container(),
        borderRadius: BorderRadius.circular(12),
      );
    } else {
      trailing = Icon(Icons.chevron_right_rounded, color: AppColors.mutedGray);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (color ?? AppColors.lavender).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color ?? AppColors.deepLavender),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color ?? AppColors.deepCharcoal,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.lightGray)),
                    ],
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            const Text(
              'Mindful Living',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.deepLavender,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version $_appVersion',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.lightGray,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Made with mindfulness',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.lightGray.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action Handlers

  Future<void> _handleSignOut() async {
    final confirmed = await _showConfirmDialog(
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      isDestructive: false,
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _authService.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully signed out'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign out. Please try again.'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await _showConfirmDialog(
      title: 'Delete Account',
      message: 'This will permanently delete your account and all your data. This action cannot be undone.',
      confirmText: 'Delete Forever',
      isDestructive: true,
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _authService.deleteAccount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete account. Try signing in again first.'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleShareApp() {
    SharePlus.instance.share(
      ShareParams(
        text: 'Transform your daily life with Mindful Living - practical guidance for every situation. Download now!',
        subject: 'Mindful Living App',
      ),
    );
  }

  void _handleAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Mindful Living'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Mindful Living provides practical, evidence-based guidance for life\'s everyday situations.',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              const Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              const Text('• 1000+ life situations with guidance'),
              const Text('• Daily wellness tracking'),
              const Text('• Mindful journal'),
              const Text('• Breathing exercises'),
              const Text('• Meditation practices'),
              const SizedBox(height: 16),
              Text(
                'Version: $_appVersion',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.lightGray,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _handleFeedback() {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@mindful-living.app',
      query: 'subject=Feedback for Mindful Living',
    );
    _launchURL(emailUri.toString());
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required bool isDestructive,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? AppColors.error : AppColors.lavender,
            ),
            child: Text(confirmText),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
