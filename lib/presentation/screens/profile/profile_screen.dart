import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Header
                GlassCard(
                  child: Column(
                    children: [
                      // Avatar with gradient border
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.accentBlue,
                              AppColors.accentPurple,
                              AppColors.accentPink,
                            ],
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: user.avatarUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Name
                      Text(
                        user.name ?? user.login,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Username
                      Text(
                        '@${user.login}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      
                      if (user.bio != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          user.bio!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                      
                      const SizedBox(height: 20),
                      
                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ProfileStat(
                            label: 'Repos',
                            value: user.publicRepos.toString(),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.glassBorderLight,
                          ),
                          _ProfileStat(
                            label: 'Followers',
                            value: user.followers.toString(),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.glassBorderLight,
                          ),
                          _ProfileStat(
                            label: 'Following',
                            value: user.following.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Profile Details
                Text(
                  'Profile Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (user.company != null)
                  _InfoCard(
                    icon: CupertinoIcons.building_2_fill,
                    label: 'Company',
                    value: user.company!,
                    gradient: const LinearGradient(
                      colors: [AppColors.accentBlue, AppColors.accentPurple],
                    ),
                  ),
                
                if (user.location != null) ...[
                  const SizedBox(height: 12),
                  _InfoCard(
                    icon: CupertinoIcons.location_fill,
                    label: 'Location',
                    value: user.location!,
                    gradient: const LinearGradient(
                      colors: [AppColors.accentPurple, AppColors.accentPink],
                    ),
                  ),
                ],
                
                if (user.email != null) ...[
                  const SizedBox(height: 12),
                  _InfoCard(
                    icon: CupertinoIcons.mail_solid,
                    label: 'Email',
                    value: user.email!,
                    gradient: const LinearGradient(
                      colors: [AppColors.accentTeal, AppColors.accentBlue],
                    ),
                  ),
                ],
                
                if (user.blog != null && user.blog!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoCard(
                    icon: CupertinoIcons.link,
                    label: 'Website',
                    value: user.blog!,
                    gradient: const LinearGradient(
                      colors: [AppColors.accentPink, AppColors.accentIndigo],
                    ),
                  ),
                ],
                
                const SizedBox(height: 12),
                _InfoCard(
                  icon: CupertinoIcons.calendar,
                  label: 'Joined',
                  value: '${user.createdAt.year}',
                  gradient: const LinearGradient(
                    colors: [AppColors.accentIndigo, AppColors.accentBlue],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiaryLight,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Gradient gradient;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
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
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}