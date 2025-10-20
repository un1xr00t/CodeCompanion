// lib/presentation/screens/contributions/contribution_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/contribution_grid_widget.dart';
import '../../../core/theme/app_colors.dart';

class ContributionDetailScreen extends StatefulWidget {
  final String username;
  final Map<String, int> contributions;
  final int totalContributions;
  final Map<String, int> repoBreakdown;

  const ContributionDetailScreen({
    super.key,
    required this.username,
    required this.contributions,
    required this.totalContributions,
    required this.repoBreakdown,
  });

  @override
  State<ContributionDetailScreen> createState() => _ContributionDetailScreenState();
}

class _ContributionDetailScreenState extends State<ContributionDetailScreen> {
  String _selectedPeriod = 'Year';
  bool _showAllRepos = false;
  bool _showAllDays = false;
  bool _showAllMonths = false;
  
  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    final dailyBreakdown = _getDailyBreakdown();
    final weekdayStats = _getWeekdayStats();
    
    debugPrint('📊 Detail screen - repo breakdown count: ${widget.repoBreakdown.length}');
    
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Contributions'),
            centerTitle: true,
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total contributions card
                  GlassCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
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
                          child: const Icon(
                            CupertinoIcons.chart_bar_square_fill,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Contributions',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.totalContributions.toString(),
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'in the last year',
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
                  
                  // Stats grid
                  Row(
                    children: [
                      Expanded(
                        child: _StatMiniCard(
                          label: 'Longest Streak',
                          value: '${stats['longestStreak']} days',
                          icon: CupertinoIcons.flame_fill,
                          gradient: const LinearGradient(
                            colors: [AppColors.accentPink, AppColors.accentIndigo],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatMiniCard(
                          label: 'Current Streak',
                          value: '${stats['currentStreak']} days',
                          icon: CupertinoIcons.flame,
                          gradient: const LinearGradient(
                            colors: [AppColors.accentIndigo, AppColors.accentPurple],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _StatMiniCard(
                          label: 'Best Day',
                          value: '${stats['maxContributions']}',
                          icon: CupertinoIcons.star_fill,
                          gradient: const LinearGradient(
                            colors: [AppColors.accentTeal, AppColors.accentBlue],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatMiniCard(
                          label: 'Avg / Day',
                          value: '${stats['avgContributions']}',
                          icon: CupertinoIcons.chart_bar_fill,
                          gradient: const LinearGradient(
                            colors: [AppColors.accentPurple, AppColors.accentPink],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Repository breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Commits by Repository',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showAllRepos = !_showAllRepos;
                          });
                        },
                        child: Text(
                          _showAllRepos ? 'Show Less' : 'Show All (${widget.repoBreakdown.length})',
                          style: TextStyle(
                            color: AppColors.accentBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verify these match your GitHub activity',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ..._buildRepoBreakdown(),
                  
                  const SizedBox(height: 32),
                  
                  // Weekday activity
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
                        final maxCount = weekdayStats.values.reduce((a, b) => a > b ? a : b);
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
                  
                  // Full contribution grid
                  Text(
                    'Contribution Graph',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  GlassCard(
                    child: Column(
                      children: [
                        ContributionGridWidget(
                          contributions: widget.contributions,
                          compact: false,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.info_circle_fill,
                                size: 16,
                                color: AppColors.accentBlue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Scroll horizontally to see the full year',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.accentBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Most active days
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Most Active Days',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showAllDays = !_showAllDays;
                          });
                        },
                        child: Text(
                          _showAllDays ? 'Show Less' : 'Show All (${dailyBreakdown.length})',
                          style: TextStyle(
                            color: AppColors.accentBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ...(_showAllDays ? dailyBreakdown : dailyBreakdown.take(5)).map((day) {
                    final date = DateTime.parse(day['date']);
                    final count = day['count'] as int;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.accentBlue, AppColors.accentPurple],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                CupertinoIcons.calendar,
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
                                    DateFormat('EEEE, MMM d, yyyy').format(date),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$count commits',
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
                                count.toString(),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.accentBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 32),
                  
                  // Monthly breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monthly Breakdown',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showAllMonths = !_showAllMonths;
                          });
                        },
                        child: Text(
                          _showAllMonths ? 'Show Less' : 'Show All',
                          style: TextStyle(
                            color: AppColors.accentBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ..._buildMonthlyBreakdown(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Map<String, dynamic> _calculateStats() {
    int longestStreak = 0;
    int currentStreak = 0;
    int maxContributions = 0;
    int tempStreak = 0;
    
    final now = DateTime.now();
    final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
    
    // Sort dates in ascending order (oldest to newest)
    final sortedDates = widget.contributions.keys.toList()..sort();
    
    // Calculate max contributions
    for (var dateStr in sortedDates) {
      final count = widget.contributions[dateStr] ?? 0;
      if (count > maxContributions) {
        maxContributions = count;
      }
    }
    
    // Calculate streaks by going forward through dates
    DateTime? lastDate;
    for (var dateStr in sortedDates) {
      final date = DateTime.parse(dateStr);
      final count = widget.contributions[dateStr] ?? 0;
      
      if (count > 0) {
        if (lastDate == null) {
          // First commit day
          tempStreak = 1;
        } else {
          final daysDiff = date.difference(lastDate).inDays;
          if (daysDiff == 1) {
            // Consecutive day
            tempStreak++;
          } else {
            // Streak broken
            if (tempStreak > longestStreak) {
              longestStreak = tempStreak;
            }
            tempStreak = 1;
          }
        }
        lastDate = date;
      }
    }
    
    // Check final streak
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }
    
    // Calculate current streak (working backwards from today)
    final today = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(today);
    final yesterdayStr = DateFormat('yyyy-MM-dd').format(today.subtract(const Duration(days: 1)));
    
    // Check if streak is still active (committed today or yesterday)
    if (widget.contributions.containsKey(todayStr) || widget.contributions.containsKey(yesterdayStr)) {
      var checkDate = widget.contributions.containsKey(todayStr) ? today : today.subtract(const Duration(days: 1));
      currentStreak = 0;
      
      while (true) {
        final checkDateStr = DateFormat('yyyy-MM-dd').format(checkDate);
        if (widget.contributions.containsKey(checkDateStr) && (widget.contributions[checkDateStr] ?? 0) > 0) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }
    
    // Calculate average
    final totalDays = now.difference(oneYearAgo).inDays;
    final avgContributions = totalDays > 0 
        ? (widget.totalContributions / totalDays).toStringAsFixed(1)
        : '0';
    
    return {
      'longestStreak': longestStreak,
      'currentStreak': currentStreak,
      'maxContributions': maxContributions,
      'avgContributions': avgContributions,
    };
  }
  
  List<Map<String, dynamic>> _getDailyBreakdown() {
    final dailyList = <Map<String, dynamic>>[];
    
    for (var entry in widget.contributions.entries) {
      dailyList.add({
        'date': entry.key,
        'count': entry.value,
      });
    }
    
    // Sort by count descending
    dailyList.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    
    return dailyList;
  }
  
  Map<String, int> _getWeekdayStats() {
    final weekdayMap = {
      'Monday': 0,
      'Tuesday': 0,
      'Wednesday': 0,
      'Thursday': 0,
      'Friday': 0,
      'Saturday': 0,
      'Sunday': 0,
    };
    
    for (var entry in widget.contributions.entries) {
      final date = DateTime.parse(entry.key);
      final weekday = DateFormat('EEEE').format(date);
      weekdayMap[weekday] = (weekdayMap[weekday] ?? 0) + entry.value;
    }
    
    return weekdayMap;
  }
  
  List<Widget> _buildRepoBreakdown() {
    if (widget.repoBreakdown.isEmpty) {
      return [
        Text(
          'No repository data available',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textTertiaryLight,
          ),
        ),
      ];
    }
    
    final sortedRepos = widget.repoBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Show only first 5 if not expanded
    final reposToShow = _showAllRepos ? sortedRepos : sortedRepos.take(5);
    
    final maxCommits = widget.repoBreakdown.values.reduce((a, b) => a > b ? a : b);
    
    return reposToShow.map((entry) {
      final repoName = entry.key;
      final commitCount = entry.value;
      final percentage = maxCommits > 0 ? commitCount / maxCommits : 0.0;
      
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
                          repoName,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$commitCount commits',
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
                      commitCount.toString(),
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
    }).toList();
  }
  
  List<Widget> _buildMonthlyBreakdown() {
    final monthlyData = <String, int>{};
    
    for (var entry in widget.contributions.entries) {
      final date = DateTime.parse(entry.key);
      final monthKey = DateFormat('yyyy-MM').format(date);
      monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + entry.value;
    }
    
    final sortedMonths = monthlyData.keys.toList()..sort((a, b) => b.compareTo(a));
    
    // Show first 6 months if not expanded
    final monthsToShow = _showAllMonths ? sortedMonths : sortedMonths.take(6);
    
    return monthsToShow.map((monthKey) {
      final date = DateTime.parse('$monthKey-01');
      final monthName = DateFormat('MMMM yyyy').format(date);
      final count = monthlyData[monthKey] ?? 0;
      final maxMonth = monthlyData.values.reduce((a, b) => a > b ? a : b);
      final percentage = maxMonth > 0 ? (count / maxMonth) : 0.0;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$count contributions',
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
        ),
      );
    }).toList();
  }
}

class _StatMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.icon,
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
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryLight,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}