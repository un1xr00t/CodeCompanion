// lib/presentation/screens/achievements/achievements_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/github_achievement.dart';
import '../../../providers/achievement_provider.dart';
import '../../widgets/glass_card.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  AchievementCategory? _selectedCategory;

  @override
Widget build(BuildContext context) {
  final achievementState = ref.watch(achievementProvider);
  final theme = Theme.of(context);

  return Scaffold(
    backgroundColor: theme.scaffoldBackgroundColor,
    body: CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Remove this whole SliverAppBar block
        /*
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Achievements'),
          centerTitle: true,
        ),
        */
        
        SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // XP & Level Card
                  _buildXPCard(achievementState),

                  const SizedBox(height: 24),

                  // Progress Stats
                  _buildProgressStats(achievementState),

                  const SizedBox(height: 32),

                  // Category Filter
                  Text(
                    'Filter by Category',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryFilters(),

                  const SizedBox(height: 24),

                  // Achievements Grid
                  if (achievementState.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CupertinoActivityIndicator(),
                      ),
                    )
                  else if (achievementState.achievements.isEmpty)
                    _buildEmptyState()
                  else
                    _buildAchievementsGrid(achievementState),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXPCard(AchievementState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      child: Row(
        children: [
          // Level badge
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentBlue, AppColors.accentPurple],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentBlue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  CupertinoIcons.star_fill,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  'Lv ${state.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // XP info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total XP',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.totalXP} XP',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep unlocking achievements to level up!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStats(AchievementState state) {
    final unlocked = state.unlockedAchievements.length;
    final total = state.achievements.length;
    final percentage = state.completionPercentage;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '$unlocked / $total',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 10,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.accentBlue,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(percentage * 100).toInt()}% Complete',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', null),
          const SizedBox(width: 8),
          ...AchievementCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(category.displayName, category),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, AchievementCategory? category) {
    final isSelected = _selectedCategory == category;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentBlue
              : theme.brightness == Brightness.dark
                  ? AppColors.glassSurfaceDark
                  : AppColors.glassSurfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.accentBlue
                : theme.brightness == Brightness.dark
                    ? AppColors.glassBorderDark
                    : AppColors.glassBorderLight,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsGrid(AchievementState state) {
    final filteredAchievements = _selectedCategory == null
        ? state.achievements
        : state.getByCategory(_selectedCategory!);

    // Sort: unlocked first, then by progress
    final sorted = List<GitHubAchievement>.from(filteredAchievements)
      ..sort((a, b) {
        if (a.isUnlocked && !b.isUnlocked) return -1;
        if (!a.isUnlocked && b.isUnlocked) return 1;
        return b.progress.compareTo(a.progress);
      });

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(sorted[index]);
      },
    );
  }

  Widget _buildAchievementCard(GitHubAchievement achievement) {
    final theme = Theme.of(context);
    final actualPercentage = (achievement.progress * 100).clamp(0.0, 100.0);
    final isUnlocked = achievement.isUnlocked;

    return GestureDetector(
      onTap: () => _showAchievementDetails(achievement),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        color: isUnlocked
            ? achievement.color.withOpacity(0.1)
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? achievement.color
                    : theme.brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: achievement.color.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                _getIconData(achievement.iconName),
                color: isUnlocked
                    ? Colors.white
                    : AppColors.textTertiaryLight.withOpacity(0.5),
                size: 32,
              ),
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isUnlocked
                    ? theme.colorScheme.onSurface
                    : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // XP Reward
            Text(
              '+${achievement.xpReward} XP',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isUnlocked
                    ? achievement.color
                    : AppColors.textTertiaryLight.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            // Progress or Unlocked badge
            if (isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: achievement.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'UNLOCKED',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              )
            else if (achievement.progress > 0)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: achievement.progress,
                      minHeight: 4,
                      backgroundColor:
                          theme.brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        achievement.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${actualPercentage.toInt()}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            else
              Icon(
                CupertinoIcons.lock_fill,
                size: 16,
                color: AppColors.textTertiaryLight.withOpacity(0.3),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.star_circle,
              size: 80,
              color: AppColors.textTertiaryLight.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Achievements Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start coding to unlock achievements!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetails(GitHubAchievement achievement) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? AppColors.glassSurfaceDark
              : AppColors.glassSurfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiaryLight.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: achievement.isUnlocked
                            ? achievement.color.withOpacity(0.2)
                            : theme.brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.03),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: achievement.isUnlocked
                              ? achievement.color.withOpacity(0.3)
                              : AppColors.glassBorderLight,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getIconData(achievement.iconName),
                        color: achievement.isUnlocked
                            ? achievement.color
                            : AppColors.textTertiaryLight.withOpacity(0.5),
                        size: 56,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title
                    Text(
                      achievement.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // XP Reward
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF10B981),
                            Color(0xFF059669),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${achievement.xpReward} XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Divider(
                      color: AppColors.glassBorderLight,
                    ),

                    const SizedBox(height: 24),

                    // Description
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Description',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      achievement.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondaryLight,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Progress
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Progress',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: achievement.isUnlocked
                            ? achievement.color.withOpacity(0.1)
                            : theme.brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: achievement.isUnlocked
                              ? achievement.color.withOpacity(0.3)
                              : AppColors.glassBorderLight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                achievement.isUnlocked
                                    ? '✓ Complete'
                                    : '${achievement.currentValue} / ${achievement.targetValue}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: achievement.isUnlocked
                                      ? achievement.color
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              if (!achievement.isUnlocked)
                                Text(
                                  '${(achievement.progress * 100).toInt()}%',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: achievement.color,
                                  ),
                                ),
                            ],
                          ),
                          if (!achievement.isUnlocked) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: achievement.progress,
                                minHeight: 8,
                                backgroundColor:
                                    theme.brightness == Brightness.dark
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.black.withOpacity(0.05),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  achievement.color,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Got it!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_fire_department':
        return CupertinoIcons.flame_fill;
      case 'whatshot':
        return CupertinoIcons.flame;
      case 'celebration':
        return CupertinoIcons.sparkles;
      case 'diamond':
        return CupertinoIcons.hexagon_fill;
      case 'flag':
        return CupertinoIcons.flag_fill;
      case 'trending_up':
        return CupertinoIcons.graph_circle_fill;
      case 'star':
        return CupertinoIcons.star_fill;
      case 'rocket_launch':
        return CupertinoIcons.rocket_fill;
      case 'emoji_events':
        return CupertinoIcons.shield_fill;
      case 'military_tech':
        return CupertinoIcons.rosette;
      case 'folder':
        return CupertinoIcons.folder_fill;
      case 'folder_open':
        return CupertinoIcons.folder_open;
      case 'account_tree':
        return CupertinoIcons.chart_bar_alt_fill;
      case 'source':
        return CupertinoIcons.doc_on_doc_fill;
      case 'today':
        return CupertinoIcons.calendar_today;
      case 'speed':
        return CupertinoIcons.speedometer;
      case 'flash_on':
        return CupertinoIcons.bolt_fill;
      case 'group':
        return CupertinoIcons.person_2_fill;
      case 'groups':
        return CupertinoIcons.person_3_fill;
      case 'diversity_3':
        return CupertinoIcons.person_3_fill;
      case 'dark_mode':
        return CupertinoIcons.moon_stars_fill;
      case 'wb_sunny':
        return CupertinoIcons.sun_max_fill;
      case 'weekend':
        return CupertinoIcons.calendar;
      case 'translate':
        return CupertinoIcons.textformat_abc;
      default:
        return CupertinoIcons.star_fill;
    }
  }
}