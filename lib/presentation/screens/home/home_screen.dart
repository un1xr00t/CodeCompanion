// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/github_stats_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/contribution_grid_widget.dart';
import '../contributions/contribution_detail_screen.dart';
import '../stats/stats_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../achievements/achievements_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'CodeCompanion',
        useNativeToolbar: true,
      ),
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        useNativeBottomBar: true, // This enables iOS 26 Liquid Glass automatically
        items: [
          AdaptiveNavigationDestination(
            icon: PlatformInfo.isIOS26OrHigher()
                ? "house.fill"
                : CupertinoIcons.home,
            label: 'Home',
          ),
          AdaptiveNavigationDestination(
            icon: PlatformInfo.isIOS26OrHigher()
                ? "chart.bar.fill"
                : CupertinoIcons.chart_bar_fill,
            label: 'Stats',
          ),
          AdaptiveNavigationDestination(
            icon: PlatformInfo.isIOS26OrHigher()
                ? "star.fill"
                : CupertinoIcons.star_fill,
            label: 'Achievements',
          ),
          AdaptiveNavigationDestination(
            icon: PlatformInfo.isIOS26OrHigher()
                ? "person.fill"
                : CupertinoIcons.person_fill,
            label: 'Profile',
          ),
          AdaptiveNavigationDestination(
            icon: PlatformInfo.isIOS26OrHigher()
                ? "gearshape.fill"
                : CupertinoIcons.settings_solid,
            label: 'Settings',
          ),
        ],
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 120, bottom: 100),
        child: _buildPageForIndex(_selectedIndex),
      ),
    );
  }

  Widget _buildPageForIndex(int index) {
  switch (index) {
    case 0:
      return const _HomeTab();
    case 1:
      return const StatsScreen();
    case 2:
      return const AchievementsScreen(); // Add this import: import '../achievements/achievements_screen.dart';
    case 3:
      return const ProfileScreen();
    case 4:
      return const SettingsScreen();
    default:
      return const _HomeTab();
  }
}
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    // Watch the stats provider
    final statsState = ref.watch(githubStatsProvider(user.login));

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header with user info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User header card
                GlassCard(
                  child: Row(
                    children: [
                      // Avatar with glass border
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.accentBlue.withValues(alpha: 0.3),
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: user.avatarUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.name ?? user.login,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (user.bio != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                user.bio!,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Quick Stats Section
                Text(
                  'Quick Stats',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _StatCard(
                      icon: CupertinoIcons.folder_fill,
                      label: 'Repositories',
                      value: statsState.isLoading ? '...' : statsState.totalRepos.toString(),
                      subtitle: statsState.isLoading 
                          ? '' 
                          : '${statsState.publicRepos} public · ${statsState.privateRepos} private',
                      gradient: const LinearGradient(
                        colors: [AppColors.accentBlue, AppColors.accentPurple],
                      ),
                    ),
                    _StatCard(
                      icon: CupertinoIcons.person_2_fill,
                      label: 'Followers',
                      value: user.followers.toString(),
                      gradient: const LinearGradient(
                        colors: [AppColors.accentPurple, AppColors.accentPink],
                      ),
                    ),
                    _StatCard(
                      icon: CupertinoIcons.star_fill,
                      label: 'Following',
                      value: user.following.toString(),
                      gradient: const LinearGradient(
                        colors: [AppColors.accentTeal, AppColors.accentBlue],
                      ),
                    ),
                    _StatCard(
                      icon: CupertinoIcons.doc_text_fill,
                      label: 'Gists',
                      value: user.publicGists.toString(),
                      gradient: const LinearGradient(
                        colors: [AppColors.accentPink, AppColors.accentIndigo],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Contribution Activity Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Contribution Activity',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!statsState.isLoading)
                      Text(
                        '${statsState.totalContributions} contributions',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: statsState.isLoading 
                          ? null 
                          : () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => ContributionDetailScreen(
                                    username: user.login,
                                    contributions: statsState.contributions,
                                    totalContributions: statsState.totalContributions,
                                    repoBreakdown: statsState.repoBreakdown,
                                  ),
                                ),
                              );
                            },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: statsState.isLoading
                            ? Container(
                                height: 150,
                                alignment: Alignment.center,
                                child: const CupertinoActivityIndicator(),
                              )
                            : Column(
                                children: [
                                  ContributionGridWidget(
                                    contributions: statsState.contributions,
                                    compact: true,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'View Details',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.accentBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        CupertinoIcons.arrow_right_circle_fill,
                                        size: 16,
                                        color: AppColors.accentBlue,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Gradient gradient;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 22,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryLight,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiaryLight,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}