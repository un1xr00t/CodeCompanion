// lib/presentation/screens/stats/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/github_stats_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Center(child: CupertinoActivityIndicator());
    }

    final statsState = ref.watch(githubStatsProvider(user.login));

    if (statsState.isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (statsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Error: ${statsState.error}'),
            const SizedBox(height: 16),
            CupertinoButton(
              onPressed: () => ref.read(githubStatsProvider(user.login).notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final streakData = _calculateStreaks(statsState.contributions);
    final weekStats = _getWeekStats(statsState.contributions);
    final monthStats = _getMonthStats(statsState.contributions);
    final weekdayStats = _getWeekdayStats(statsState.contributions);
    final topRepos = _getTopRepos(statsState.repoBreakdown, 5);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Statistics',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your coding insights',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Current Streak Card
                GlassCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accentPink, AppColors.accentIndigo],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentPink.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.flame_fill,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Streak',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${streakData['current'] ?? 0} days',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (streakData['current'] ?? 0) > 0 
                                  ? 'Keep it going!'
                                  : 'Start a new streak today',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        icon: CupertinoIcons.calendar_today,
                        label: 'This Week',
                        value: weekStats.toString(),
                        gradient: const LinearGradient(
                          colors: [AppColors.accentBlue, AppColors.accentTeal],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStatCard(
                        icon: CupertinoIcons.calendar,
                        label: 'This Month',
                        value: monthStats.toString(),
                        gradient: const LinearGradient(
                          colors: [AppColors.accentPurple, AppColors.accentPink],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _MiniStatCard(
                        icon: CupertinoIcons.flame,
                        label: 'Longest Streak',
                        value: '${streakData['longest']} days',
                        gradient: const LinearGradient(
                          colors: [AppColors.accentIndigo, AppColors.accentPurple],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStatCard(
                        icon: CupertinoIcons.chart_bar_fill,
                        label: 'Total Commits',
                        value: statsState.totalContributions.toString(),
                        gradient: const LinearGradient(
                          colors: [AppColors.accentTeal, AppColors.accentBlue],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Most Active Day
                Text(
                  'Activity by Day of Week',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                GlassCard(
                  child: Column(
                    children: weekdayStats.entries.map((entry) {
                      final maxCount = weekdayStats.values.isEmpty ? 0 : weekdayStats.values.reduce((a, b) => a > b ? a : b);
                      final percentage = maxCount > 0 ? entry.value / maxCount : 0.0;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${entry.value} commits',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.accentBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.05),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.accentBlue,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Most Active Repositories Section
                Text(
                  'Most Active Repositories',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (topRepos.isEmpty)
                  GlassCard(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accentPink, AppColors.accentIndigo],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            CupertinoIcons.folder_fill,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Repository Data',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start committing to see your most active repos',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textTertiaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ...topRepos.map((repo) {
                    final maxCommits = topRepos.isNotEmpty ? (topRepos.first['commits'] as int?) ?? 0 : 0;
                    final commits = (repo['commits'] as int?) ?? 0;
                    final percentage = maxCommits > 0 ? commits / maxCommits : 0.0;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppColors.accentBlue, AppColors.accentPurple],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.folder_fill,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        repo['name'] as String,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$commits commits',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textTertiaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentBlue.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    commits.toString(),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.accentBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.05),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.accentBlue,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Map<String, int> _calculateStreaks(Map<String, int> contributions) {
    int longestStreak = 0;
    int currentStreak = 0;
    int tempStreak = 0;
    
    final sortedDates = contributions.keys.toList()..sort();
    
    // Calculate longest streak
    DateTime? lastDate;
    for (var dateStr in sortedDates) {
      final date = DateTime.parse(dateStr);
      final count = contributions[dateStr] ?? 0;
      
      if (count > 0) {
        if (lastDate == null) {
          tempStreak = 1;
        } else {
          final daysDiff = date.difference(lastDate).inDays;
          if (daysDiff == 1) {
            tempStreak++;
          } else {
            if (tempStreak > longestStreak) {
              longestStreak = tempStreak;
            }
            tempStreak = 1;
          }
        }
        lastDate = date;
      }
    }
    
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }
    
    // Calculate current streak
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);
    final yesterdayStr = DateFormat('yyyy-MM-dd').format(today.subtract(const Duration(days: 1)));
    
    if (contributions.containsKey(todayStr) || contributions.containsKey(yesterdayStr)) {
      var checkDate = contributions.containsKey(todayStr) ? today : today.subtract(const Duration(days: 1));
      currentStreak = 0;
      
      while (true) {
        final checkDateStr = DateFormat('yyyy-MM-dd').format(checkDate);
        if (contributions.containsKey(checkDateStr) && (contributions[checkDateStr] ?? 0) > 0) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }
    
    return {
      'current': currentStreak,
      'longest': longestStreak,
    };
  }

  int _getWeekStats(Map<String, int> contributions) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    int total = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      total += contributions[dateStr] ?? 0;
    }
    
    return total;
  }

  int _getMonthStats(Map<String, int> contributions) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    int total = 0;
    
    var current = monthStart;
    while (current.month == now.month) {
      final dateStr = DateFormat('yyyy-MM-dd').format(current);
      total += contributions[dateStr] ?? 0;
      current = current.add(const Duration(days: 1));
    }
    
    return total;
  }

  Map<String, int> _getWeekdayStats(Map<String, int> contributions) {
    final weekdayMap = {
      'Monday': 0,
      'Tuesday': 0,
      'Wednesday': 0,
      'Thursday': 0,
      'Friday': 0,
      'Saturday': 0,
      'Sunday': 0,
    };
    
    for (var entry in contributions.entries) {
      final date = DateTime.parse(entry.key);
      final weekday = DateFormat('EEEE').format(date);
      weekdayMap[weekday] = (weekdayMap[weekday] ?? 0) + entry.value;
    }
    
    return weekdayMap;
  }

  List<Map<String, dynamic>> _getTopRepos(Map<String, int> repoBreakdown, int limit) {
    final sorted = repoBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(limit).map((e) => {
      'name': e.key,
      'commits': e.value,
    }).toList();
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Gradient gradient;

  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
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
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}