// lib/presentation/widgets/contribution_grid_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';

class ContributionGridWidget extends StatelessWidget {
  final Map<String, int> contributions;
  final bool compact;
  
  const ContributionGridWidget({
    super.key,
    required this.contributions,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Go back exactly 52 weeks (364 days) to show a full year
    final weeksAgo = now.subtract(const Duration(days: 364));
    // Start from the beginning of that week (Sunday)
    final startDate = weeksAgo.subtract(Duration(days: weeksAgo.weekday % 7));
    
    // Generate all dates from start to now
    final dates = <DateTime>[];
    var currentDate = startDate;
    while (currentDate.isBefore(now) || currentDate.isAtSameMomentAs(now)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    // Group dates by week
    final weeks = <List<DateTime>>[];
    var currentWeek = <DateTime>[];
    
    // Add empty cells to align first week properly
    final firstDayWeekday = dates.first.weekday;
    for (int i = 0; i < firstDayWeekday % 7; i++) {
      currentWeek.add(DateTime(1970)); // Placeholder date
    }
    
    for (var date in dates) {
      if (currentWeek.length == 7) {
        weeks.add(List.from(currentWeek));
        currentWeek.clear();
      }
      currentWeek.add(date);
    }
    
    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(DateTime(1970)); // Placeholder
      }
      weeks.add(currentWeek);
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month labels
        SizedBox(
          height: 20,
          child: Row(
            children: [
              const SizedBox(width: 30), // Space for day labels
              Expanded(
                child: _buildMonthLabels(dates, weeks.length),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Grid with day labels
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels (Mon, Wed, Fri)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildDayLabel('Mon', 0, context),
                _buildDayLabel('', 1, context),
                _buildDayLabel('Wed', 2, context),
                _buildDayLabel('', 3, context),
                _buildDayLabel('Fri', 4, context),
                _buildDayLabel('', 5, context),
                _buildDayLabel('', 6, context),
              ],
            ),
            const SizedBox(width: 8),
            // Contribution grid
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: compact ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                child: Row(
                  children: compact 
                      ? weeks.take(20).map((week) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 3),
                            child: Column(
                              children: week.map((date) {
                                if (date.year == 1970) {
                                  // Empty cell
                                  return Container(
                                    width: 11,
                                    height: 11,
                                    margin: const EdgeInsets.only(bottom: 2.5),
                                  );
                                }
                                
                                final dateKey = DateFormat('yyyy-MM-dd').format(date);
                                final count = contributions[dateKey] ?? 0;
                                
                                return Container(
                                  width: 11,
                                  height: 11,
                                  margin: const EdgeInsets.only(bottom: 2.5),
                                  decoration: BoxDecoration(
                                    color: _getColorForCount(count, isDark),
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border.all(
                                      color: isDark 
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.black.withOpacity(0.05),
                                      width: 0.5,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList()
                      : weeks.map((week) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 3),
                            child: Column(
                              children: week.map((date) {
                                if (date.year == 1970) {
                                  // Empty cell
                                  return Container(
                                    width: 12,
                                    height: 12,
                                    margin: const EdgeInsets.only(bottom: 3),
                                  );
                                }
                                
                                final dateKey = DateFormat('yyyy-MM-dd').format(date);
                                final count = contributions[dateKey] ?? 0;
                                
                                return Tooltip(
                                  message: '$count contributions on ${DateFormat('MMM d, yyyy').format(date)}',
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    margin: const EdgeInsets.only(bottom: 3),
                                    decoration: BoxDecoration(
                                      color: _getColorForCount(count, isDark),
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(
                                        color: isDark 
                                            ? Colors.white.withOpacity(0.05)
                                            : Colors.black.withOpacity(0.05),
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Less',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(width: 6),
            ...List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getColorForLevel(index, isDark),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: isDark 
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      width: 0.5,
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(width: 6),
            Text(
              'More',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildDayLabel(String label, int index, BuildContext context) {
    return SizedBox(
      height: 11,
      width: 25,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: AppColors.textTertiaryLight,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }
  
  Widget _buildMonthLabels(List<DateTime> dates, int weekCount) {
    final months = <String, double>{};
    var currentMonth = '';
    
    for (int i = 0; i < dates.length; i++) {
      final date = dates[i];
      final monthName = DateFormat('MMM').format(date);
      
      if (monthName != currentMonth) {
        final weekIndex = i / 7;
        months[monthName] = weekIndex;
        currentMonth = monthName;
      }
    }
    
    return Stack(
      children: months.entries.map((entry) {
        final position = (entry.value * 15); // 12px cell + 3px margin
        return Positioned(
          left: position,
          child: Text(
            entry.key,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textTertiaryLight,
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Color _getColorForCount(int count, bool isDark) {
    if (count == 0) {
      return isDark ? AppColors.contributionLevel0Dark : AppColors.contributionLevel0;
    } else if (count <= 3) {
      return isDark ? AppColors.contributionLevel1Dark : AppColors.contributionLevel1;
    } else if (count <= 6) {
      return isDark ? AppColors.contributionLevel2Dark : AppColors.contributionLevel2;
    } else if (count <= 9) {
      return isDark ? AppColors.contributionLevel3Dark : AppColors.contributionLevel3;
    } else {
      return isDark ? AppColors.contributionLevel4Dark : AppColors.contributionLevel4;
    }
  }
  
  Color _getColorForLevel(int level, bool isDark) {
    switch (level) {
      case 0:
        return isDark ? AppColors.contributionLevel0Dark : AppColors.contributionLevel0;
      case 1:
        return isDark ? AppColors.contributionLevel1Dark : AppColors.contributionLevel1;
      case 2:
        return isDark ? AppColors.contributionLevel2Dark : AppColors.contributionLevel2;
      case 3:
        return isDark ? AppColors.contributionLevel3Dark : AppColors.contributionLevel3;
      case 4:
        return isDark ? AppColors.contributionLevel4Dark : AppColors.contributionLevel4;
      default:
        return isDark ? AppColors.contributionLevel0Dark : AppColors.contributionLevel0;
    }
  }
}