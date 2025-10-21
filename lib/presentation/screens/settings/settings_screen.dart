// lib/presentation/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/github_stats_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/achievement_service.dart';

// Provider for contribution grid color scheme
final contributionColorSchemeProvider = StateProvider<String>((ref) => 'github');

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isRefreshing = false;
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final colorScheme = ref.watch(contributionColorSchemeProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Customize your experience',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Appearance Section
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                AdaptiveCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.accentPurple,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                CupertinoIcons.square_grid_2x2_fill,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Contribution Grid',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getColorSchemeName(colorScheme),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: AdaptiveSegmentedControl(
                                labels: const ['', '', ''],
                                sfSymbols: const [
                                  'square.grid.2x2.fill',
                                  'leaf.fill',
                                  'circle.hexagongrid.fill',
                                ],
                                selectedIndex: _getColorSchemeIndex(colorScheme),
                                onValueChanged: (index) {
                                  final schemes = ['github', 'ocean', 'sunset'];
                                  ref.read(contributionColorSchemeProvider.notifier).state = schemes[index];
                                },
                                iconColor: AppColors.accentPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Data Section
                Text(
                  'Data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                AdaptiveCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildSettingTile(
                        icon: CupertinoIcons.refresh_circled_solid,
                        title: 'Refresh Data',
                        subtitle: 'Update your GitHub stats',
                        gradient: const LinearGradient(
                          colors: [AppColors.accentIndigo, AppColors.accentBlue],
                        ),
                        trailing: _isRefreshing 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CupertinoActivityIndicator(),
                            )
                          : null,
                        onTap: _isRefreshing ? null : () => _refreshData(user?.login),
                      ),
                      const Divider(height: 1, indent: 62),
                      _buildSettingTile(
                        icon: CupertinoIcons.trash_fill,
                        title: 'Clear Cache',
                        subtitle: 'Reset all stored data',
                        gradient: const LinearGradient(
                          colors: [AppColors.accentPink, AppColors.error],
                        ),
                        onTap: () => _showClearCacheDialog(context),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // About Section
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                AdaptiveCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildSettingTile(
                        icon: CupertinoIcons.info_circle_fill,
                        title: 'Version',
                        subtitle: AppConstants.appVersion,
                        gradient: const LinearGradient(
                          colors: [AppColors.accentTeal, AppColors.accentBlue],
                        ),
                        onTap: null,
                      ),
                      const Divider(height: 1, indent: 62),
                      _buildSettingTile(
                        icon: CupertinoIcons.link,
                        title: 'GitHub Repository',
                        subtitle: 'View source code',
                        gradient: const LinearGradient(
                          colors: [AppColors.githubBlack, AppColors.githubGray],
                        ),
                        onTap: () => _launchGitHub(),
                      ),
                      const Divider(height: 1, indent: 62),
                      _buildSettingTile(
                        icon: CupertinoIcons.heart_fill,
                        title: 'Rate App',
                        subtitle: 'Support development',
                        gradient: const LinearGradient(
                          colors: [AppColors.accentPink, AppColors.accentPurple],
                        ),
                        onTap: () => _showAlert(
                          context,
                          'Coming Soon',
                          'App Store integration coming soon!',
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Account Section
                Text(
                  'Account',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                AdaptiveCard(
                  padding: EdgeInsets.zero,
                  child: _buildSettingTile(
                    icon: CupertinoIcons.arrow_right_square_fill,
                    title: 'Sign Out',
                    subtitle: 'Logout from GitHub',
                    gradient: const LinearGradient(
                      colors: [AppColors.error, AppColors.accentPink],
                    ),
                    onTap: () => _showSignOutDialog(context),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Footer
                Center(
                  child: Text(
                    'Made with ❤️ by CodeCompanion',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else if (onTap != null)
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 20,
                  color: AppColors.textTertiaryLight,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getColorSchemeName(String scheme) {
    switch (scheme) {
      case 'github':
        return 'GitHub Green';
      case 'ocean':
        return 'Ocean Blue';
      case 'sunset':
        return 'Sunset Orange';
      default:
        return 'GitHub Green';
    }
  }

  int _getColorSchemeIndex(String scheme) {
    switch (scheme) {
      case 'github':
        return 0;
      case 'ocean':
        return 1;
      case 'sunset':
        return 2;
      default:
        return 0;
    }
  }

  Future<void> _refreshData(String? username) async {
    if (username == null) return;
    
    setState(() => _isRefreshing = true);
    
    try {
      // Refresh user data from GitHub
      await ref.read(authProvider.notifier).refreshUser();
      
      // Refresh GitHub stats (contributions, repos, etc.)
      await ref.read(githubStatsProvider(username).notifier).refresh();
      
      if (mounted) {
        _showAlert(
          context,
          'Success',
          'Your data has been refreshed successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        _showAlert(
          context,
          'Error',
          'Failed to refresh data: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _launchGitHub() async {
    final uri = Uri.parse('https://github.com/un1xr00t/codecompanion');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        _showAlert(context, 'Error', 'Could not open GitHub');
      }
    }
  }

  void _showSignOutDialog(BuildContext context) {
    if (PlatformInfo.isIOS || PlatformInfo.isMacOS) {
      AdaptiveAlertDialog.show(
        context: context,
        title: 'Sign Out',
        message: 'Are you sure you want to sign out?',
        icon: 'arrow.right.square.fill',
        iconColor: AppColors.error,
        actions: [
          AlertAction(
            title: 'Cancel',
            style: AlertActionStyle.cancel,
            onPressed: () {},
          ),
          AlertAction(
            title: 'Sign Out',
            style: AlertActionStyle.destructive,
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      );
    }
  }

  void _showClearCacheDialog(BuildContext context) {
    if (PlatformInfo.isIOS || PlatformInfo.isMacOS) {
      AdaptiveAlertDialog.show(
        context: context,
        title: 'Clear Cache',
        message: 'This will clear all cached data including achievements. Your GitHub data will remain safe.',
        icon: 'trash.fill',
        iconColor: AppColors.error,
        actions: [
          AlertAction(
            title: 'Cancel',
            style: AlertActionStyle.cancel,
            onPressed: () {},
          ),
          AlertAction(
            title: 'Clear',
            style: AlertActionStyle.destructive,
            onPressed: () async {
              await _clearCache();
            },
          ),
        ],
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear Cache'),
          content: const Text('This will clear all cached data including achievements. Your GitHub data will remain safe.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _clearCache();
              },
              child: const Text('Clear'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _clearCache() async {
    try {
      final storage = StorageService();
      final achievements = AchievementService();
      
      // Clear achievement data
      await achievements.resetAllAchievements();
      
      // You can add more cache clearing here if needed
      // await storage.clearCache(); // implement this in StorageService if you want
      
      if (mounted) {
        _showAlert(
          context,
          'Success',
          'Cache cleared successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        _showAlert(
          context,
          'Error',
          'Failed to clear cache: ${e.toString()}',
        );
      }
    }
  }

  void _showAlert(BuildContext context, String title, String message) {
    if (PlatformInfo.isIOS || PlatformInfo.isMacOS) {
      AdaptiveAlertDialog.show(
        context: context,
        title: title,
        message: message,
        icon: title == 'Success' ? 'checkmark.circle.fill' : 'exclamationmark.triangle.fill',
        iconColor: title == 'Success' ? AppColors.success : AppColors.error,
        actions: [
          AlertAction(
            title: 'OK',
            style: AlertActionStyle.primary,
            onPressed: () {},
          ),
        ],
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}