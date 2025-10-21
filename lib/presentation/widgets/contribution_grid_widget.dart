// lib/presentation/widgets/contribution_grid_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../presentation/screens/settings/settings_screen.dart';

class ContributionGridWidget extends ConsumerWidget {
  final Map<String, int> contributions;
  final bool compact;
  
  const ContributionGridWidget({
    super.key,
    required this.contributions,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = ref.watch(contributionColorSchemeProvider);
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels on the left
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: compact ? 22 : 28),
                _buildDayLabel('Mon', 0, context, compact),
                _buildDayLabel('', 1, context, compact),
                _buildDayLabel('Wed', 2, context, compact),
                _buildDayLabel('', 3, context, compact),
                _buildDayLabel('Fri', 4, context, compact),
                _buildDayLabel('', 5, context, compact),
                _buildDayLabel('Sun', 6, context, compact),
              ],
            ),
            const SizedBox(width: 8),
            // Contribution grid
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month labels at top
                    _buildScrollableMonthLabels(displayWeeks, compact),
                    const SizedBox(height: 4),
                    // Grid of contributions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: displayWeeks.map((week) {
                        return Container(
                          margin: EdgeInsets.only(right: compact ? 3 : 4),
                          child: Column(
                            children: week.map((date) {
                              // Empty cell for placeholder dates
                              if (date.year == 1970) {
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
                                    color: _getColorForCount(count, isDark, colorScheme),
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
                    color: _getColorForLevel(index, isDark, colorScheme),
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
  
  Color _getColorForCount(int count, bool isDark, String colorScheme) {
    if (count == 0) {
      return isDark ? const Color(0xFF161B22) : const Color(0xFFEBEDF0);
    } else if (count <= 3) {
      return _getLevel1Color(isDark, colorScheme);
    } else if (count <= 6) {
      return _getLevel2Color(isDark, colorScheme);
    } else if (count <= 9) {
      return _getLevel3Color(isDark, colorScheme);
    } else {
      return _getLevel4Color(isDark, colorScheme);
    }
  }
  
  Color _getColorForLevel(int level, bool isDark, String colorScheme) {
    switch (level) {
      case 0:
        return isDark ? const Color(0xFF161B22) : const Color(0xFFEBEDF0);
      case 1:
        return _getLevel1Color(isDark, colorScheme);
      case 2:
        return _getLevel2Color(isDark, colorScheme);
      case 3:
        return _getLevel3Color(isDark, colorScheme);
      case 4:
        return _getLevel4Color(isDark, colorScheme);
      default:
        return isDark ? const Color(0xFF161B22) : const Color(0xFFEBEDF0);
    }
  }

  // GitHub Green scheme
  Color _getLevel1Color(bool isDark, String colorScheme) {
    switch (colorScheme) {
      case 'github':
        return isDark ? const Color(0xFF0E4429) : const Color(0xFF9BE9A8);
      case 'ocean':
        return isDark ? const Color(0xFF0A2F51) : const Color(0xFF87CEEB);
      case 'sunset':
        return isDark ? const Color(0xFF4A2C2A) : const Color(0xFFFFB347);
      default:
        return isDark ? const Color(0xFF0E4429) : const Color(0xFF9BE9A8);
    }
  }

  Color _getLevel2Color(bool isDark, String colorScheme) {
    switch (colorScheme) {
      case 'github':
        return isDark ? const Color(0xFF006D32) : const Color(0xFF40C463);
      case 'ocean':
        return isDark ? const Color(0xFF0E4C92) : const Color(0xFF4682B4);
      case 'sunset':
        return isDark ? const Color(0xFF7C3A2D) : const Color(0xFFFF8C42);
      default:
        return isDark ? const Color(0xFF006D32) : const Color(0xFF40C463);
    }
  }

  Color _getLevel3Color(bool isDark, String colorScheme) {
    switch (colorScheme) {
      case 'github':
        return isDark ? const Color(0xFF26A641) : const Color(0xFF30A14E);
      case 'ocean':
        return isDark ? const Color(0xFF1E6BB8) : const Color(0xFF1E90FF);
      case 'sunset':
        return isDark ? const Color(0xFFA0522D) : const Color(0xFFFF6347);
      default:
        return isDark ? const Color(0xFF26A641) : const Color(0xFF30A14E);
    }
  }

  Color _getLevel4Color(bool isDark, String colorScheme) {
    switch (colorScheme) {
      case 'github':
        return isDark ? const Color(0xFF39D353) : const Color(0xFF216E39);
      case 'ocean':
        return isDark ? const Color(0xFF3A9BDC) : const Color(0xFF0047AB);
      case 'sunset':
        return isDark ? const Color(0xFFD2691E) : const Color(0xFFFF4500);
      default:
        return isDark ? const Color(0xFF39D353) : const Color(0xFF216E39);
    }
  }
}