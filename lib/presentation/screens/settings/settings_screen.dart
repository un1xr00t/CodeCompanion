import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    color: AppColors.textSecondaryLight,
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
                
                GlassCard(
                  child: Column(
                    children: [
                      _SettingItem(
                        icon: CupertinoIcons.paintbrush_fill,
                        title: 'Theme',
                        subtitle: 'Automatic',
                        gradient: const LinearGradient(
                          colors: [AppColors.accentBlue, AppColors.accentPurple],
                        ),
                        onTap: () {
                          // TODO: Implement theme picker
                        },
                      ),
                      const Divider(height: 1),
                      _SettingItem(
                        icon: CupertinoIcons.square_grid_2x2_fill,
                        title: 'Contribution Grid',
                        subtitle: 'Color scheme',
                        gradient: const LinearGradient(
                          colors: [AppColors.accentPurple, AppColors.accentPink],
                        ),
                        onTap: () {
                          // TODO: Implement color scheme picker
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Notifications Section
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                GlassCard(
                  child: Column(
                    children: [
                      _SettingItem(
                        icon: CupertinoIcons.bell_fill,
                        title: 'Push Notifications',
                        subtitle: 'Coming soon',
                        gradient: const LinearGradient(
                          colors: [AppColors.accentTeal, AppColors.accentBlue],
                        ),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _SettingItem(
                        icon: CupertinoIcons.star_fill,
                        title: 'Daily Reminders',
                        subtitle: 'Coming soon',
                        gradient: const LinearGradient(
                          colors: [AppColors.accentPink, AppColors.accentIndigo],
                        ),
                        onTap: () {},
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
                
                GlassCard(
                  child: Column(
                    children: [
                      _SettingItem(
                        icon: CupertinoIcons.refresh,
                        title: 'Refresh Data',
                        subtitle: 'Update your GitHub stats',
                        gradient: const LinearGradient(
                          colors: [AppColors.accentIndigo, AppColors.accentBlue],
                        ),
                        onTap: () async {
                          await ref.read(authProvider.notifier).refreshUser();
                          if (context.mounted) {
                            _showAlert(
                              context,
                              'Success',
                              'Your data has been refreshed',
                            );
                          }
                        },
                      ),
                      const Divider(height: 1),
                      _SettingItem(
                        icon: CupertinoIcons.arrow_right_arrow_left,
                        title: 'Switch Account',
                        subtitle: 'Coming soon',
                        gradient: const LinearGradient(
                          colors: [AppColors.accentPurple, AppColors.accentPink],
                        ),
                        onTap: () {},
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
                
                GlassCard(
                  child: Column(
                    children: [
                      _SettingItem(
                        icon: CupertinoIcons.info_circle_fill,
                        title: 'App Version',
                        subtitle: '1.0.0',
                        gradient: const LinearGradient(
                          colors: [AppColors.accentTeal, AppColors.accentBlue],
                        ),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _SettingItem(
                        icon: CupertinoIcons.doc_text_fill,
                        title: 'Privacy Policy',
                        subtitle: 'View our privacy policy',
                        gradient: const LinearGradient(
                          colors: [AppColors.accentBlue, AppColors.accentPurple],
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Logout Button
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _handleLogout(context, ref),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.arrow_right_square_fill,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Sign Out',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  void _handleLogout(BuildContext context, WidgetRef ref) {
    if (PlatformInfo.isIOS || PlatformInfo.isMacOS) {
      AdaptiveAlertDialog.show(
        context: context,
        title: 'Sign Out',
        message: 'Are you sure you want to sign out of your account?',
        icon: 'exclamationmark.triangle.fill',
        iconColor: AppColors.warning,
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

  void _showAlert(BuildContext context, String title, String message) {
    if (PlatformInfo.isIOS || PlatformInfo.isMacOS) {
      AdaptiveAlertDialog.show(
        context: context,
        title: title,
        message: message,
        icon: 'checkmark.circle.fill',
        iconColor: AppColors.success,
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

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.41,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiaryLight.withOpacity(0.8),
                        letterSpacing: -0.08,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: AppColors.textTertiaryLight.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}