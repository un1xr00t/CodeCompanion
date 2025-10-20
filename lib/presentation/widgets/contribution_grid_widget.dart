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
    
    // For compact mode on home screen, show last 26 weeks (6 months)
    final displayWeeks = compact ? weeks.sublist(weeks.length > 26 ? weeks.length - 26 : 0) : weeks;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid with day labels and month labels
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels column with space for month labels
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Month label spacer
                if (!compact) SizedBox(height: 24, width: 32),
                if (!compact) const SizedBox(height: 8),
                // Day labels
                _buildDayLabel('Mon', 0, context, compact),
                _buildDayLabel('', 1, context, compact),
                _buildDayLabel('Wed', 2, context, compact),
                _buildDayLabel('', 3, context, compact),
                _buildDayLabel('Fri', 4, context, compact),
                _buildDayLabel('', 5, context, compact),
                _buildDayLabel('', 6, context, compact),
              ],
            ),
            const SizedBox(width: 8),
            // Scrollable grid with month labels
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: compact 
                    ? const NeverScrollableScrollPhysics() 
                    : const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month labels
                    if (!compact && displayWeeks.isNotEmpty) 
                      SizedBox(
                        height: 24,
                        child: _buildScrollableMonthLabels(displayWeeks, compact),
                      ),
                    if (!compact) const SizedBox(height: 8),
                    // Contribution grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: displayWeeks.map((week) {
                        return Padding(
                          padding: EdgeInsets.only(right: compact ? 3 : 4),
                          child: Column(
                            children: week.map((date) {
                              if (date.year == 1970) {
                                // Empty cell
                                return Container(
                                  width: compact ? 12 : 14,
                                  height: compact ? 12 : 14,
                                  margin: EdgeInsets.only(bottom: compact ? 3 : 4),
                                );
                              }
                              
                              final dateKey = DateFormat('yyyy-MM-dd').format(date);
                              final count = contributions[dateKey] ?? 0;
                              final borderColor = isDark 
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.black.withOpacity(0.08);
                              
                              return Tooltip(
                                message: '$count contributions on ${DateFormat('MMM d, yyyy').format(date)}',
                                child: Container(
                                  width: compact ? 12 : 14,
                                  height: compact ? 12 : 14,
                                  margin: EdgeInsets.only(bottom: compact ? 3 : 4),
                                  decoration: BoxDecoration(
                                    color: _getColorForCount(count, isDark),
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      color: borderColor,
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
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 12 : 16),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Less',
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                color: AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(width: 6),
            ...List.generate(5, (index) {
              final borderColor = isDark 
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08);
              
              return Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Container(
                  width: compact ? 11 : 12,
                  height: compact ? 11 : 12,
                  decoration: BoxDecoration(
                    color: _getColorForLevel(index, isDark),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: borderColor,
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
                fontSize: compact ? 10 : 11,
                color: AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildDayLabel(String label, int index, BuildContext context, bool compact) {
    return SizedBox(
      height: compact ? 12 : 14,
      width: compact ? 28 : 32,
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          label,
          style: TextStyle(
            fontSize: compact ? 9 : 10,
            color: AppColors.textTertiaryLight,
          ),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
  
  Widget _buildScrollableMonthLabels(List<List<DateTime>> weeks, bool compact) {
    if (weeks.isEmpty) return const SizedBox.shrink();
    
    final cellWidth = compact ? 12.0 : 14.0;
    final spacing = compact ? 3.0 : 4.0;
    final totalWidth = cellWidth + spacing;
    
    final monthLabels = <Widget>[];
    var currentMonth = '';
    
    for (int weekIndex = 0; weekIndex < weeks.length; weekIndex++) {
      final week = weeks[weekIndex];
      if (week.isEmpty) continue;
      
      // Find first valid date in week (should be Monday, index 0)
      DateTime? firstDate;
      for (var date in week) {
        if (date.year != 1970) {
          firstDate = date;
          break;
        }
      }
      
      if (firstDate != null) {
        final monthName = DateFormat('MMM').format(firstDate);
        if (monthName != currentMonth && monthName.isNotEmpty) {
          currentMonth = monthName;
          final position = weekIndex * totalWidth;
          
          monthLabels.add(
            Positioned(
              left: position,
              top: 0,
              child: Text(
                monthName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiaryLight,
                ),
              ),
            ),
          );
        }
      }
    }
    
    // Calculate total width for the stack
    final stackWidth = weeks.length * totalWidth;
    
    return SizedBox(
      width: stackWidth,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: monthLabels,
      ),
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