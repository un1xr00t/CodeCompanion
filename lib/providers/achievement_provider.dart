// lib/providers/achievement_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/github_achievement.dart';
import '../data/services/achievement_service.dart';
import 'github_stats_provider.dart';
import 'auth_provider.dart';

class AchievementState {
  final List<GitHubAchievement> achievements;
  final List<GitHubAchievement> newlyUnlocked;
  final int totalXP;
  final int level;
  final bool isLoading;
  final String? error;

  AchievementState({
    this.achievements = const [],
    this.newlyUnlocked = const [],
    this.totalXP = 0,
    this.level = 1,
    this.isLoading = false,
    this.error,
  });

  AchievementState copyWith({
    List<GitHubAchievement>? achievements,
    List<GitHubAchievement>? newlyUnlocked,
    int? totalXP,
    int? level,
    bool? isLoading,
    String? error,
  }) {
    return AchievementState(
      achievements: achievements ?? this.achievements,
      newlyUnlocked: newlyUnlocked ?? this.newlyUnlocked,
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Get unlocked achievements
  List<GitHubAchievement> get unlockedAchievements {
    return achievements.where((a) => a.isUnlocked).toList();
  }

  // Get locked achievements
  List<GitHubAchievement> get lockedAchievements {
    return achievements.where((a) => !a.isUnlocked).toList();
  }

  // Get achievements by category
  List<GitHubAchievement> getByCategory(AchievementCategory category) {
    return achievements.where((a) => a.category == category).toList();
  }

  // Get completion percentage
  double get completionPercentage {
    if (achievements.isEmpty) return 0.0;
    return unlockedAchievements.length / achievements.length;
  }
}

final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService();
});

final achievementProvider = StateNotifierProvider<AchievementNotifier, AchievementState>((ref) {
  return AchievementNotifier(ref);
});

class AchievementNotifier extends StateNotifier<AchievementState> {
  final Ref ref;
  final AchievementService _service = AchievementService();

  AchievementNotifier(this.ref) : super(AchievementState()) {
    _init();
  }

  Future<void> _init() async {
    await _service.init();
    await loadAchievements();
  }

  // Load all achievements with current progress
  Future<void> loadAchievements() async {
    state = state.copyWith(isLoading: true);

    try {
      final authState = ref.read(authProvider);
      final user = authState.user;

      if (user == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final statsState = ref.read(githubStatsProvider(user.login));
      
      // Calculate stats for achievement checking
      final stats = _calculateStreaks(statsState.contributions);
      
      // Get language breakdown
      final languageBreakdown = <String, int>{};
      // We'll need to fetch this from the stats provider
      // For now, use a placeholder count based on repos
      
      final achievements = await _service.getAllAchievements(
        totalCommits: statsState.totalContributions,
        currentStreak: _calculateStreaks(statsState.contributions)['currentStreak'] ?? 0,
        longestStreak: _calculateStreaks(statsState.contributions)['longestStreak'] ?? 0,
        totalRepos: statsState.totalRepos,
        followers: user.followers,
        contributions: statsState.contributions,
        languageBreakdown: languageBreakdown,
        commitTimestamps: null, // TODO: Add timestamp tracking
      );

      final totalXP = await _service.getTotalXP();
      final level = _service.getLevelFromXP(totalXP);

      state = state.copyWith(
        achievements: achievements,
        totalXP: totalXP,
        level: level,
        isLoading: false,
      );

      debugPrint('📊 Loaded ${achievements.length} achievements');
      debugPrint('🏆 ${state.unlockedAchievements.length} unlocked');
      debugPrint('⭐ Total XP: $totalXP (Level $level)');
    } catch (e) {
      debugPrint('❌ Error loading achievements: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Check and unlock new achievements
  Future<void> checkAchievements() async {
    try {
      final authState = ref.read(authProvider);
      final user = authState.user;

      if (user == null) return;

      final statsState = ref.read(githubStatsProvider(user.login));
      final stats = _calculateStreaks(statsState.contributions);

      final languageBreakdown = <String, int>{};

      final newlyUnlocked = await _service.checkAndUnlockAchievements(
        totalCommits: statsState.totalContributions,
        currentStreak: _calculateStreaks(statsState.contributions)['currentStreak'] ?? 0,
        longestStreak: _calculateStreaks(statsState.contributions)['longestStreak'] ?? 0,
        totalRepos: statsState.totalRepos,
        followers: user.followers,
        contributions: statsState.contributions,
        languageBreakdown: languageBreakdown,
        commitTimestamps: null,
      );

      if (newlyUnlocked.isNotEmpty) {
        debugPrint('🎉 ${newlyUnlocked.length} new achievements unlocked!');
        
        // Reload to get updated state
        await loadAchievements();
        
        // Update newly unlocked list
        state = state.copyWith(newlyUnlocked: newlyUnlocked);
      }
    } catch (e) {
      debugPrint('❌ Error checking achievements: $e');
    }
  }

  // Clear newly unlocked achievements (after showing popups)
  void clearNewlyUnlocked() {
    state = state.copyWith(newlyUnlocked: []);
  }

  // Get achievement by ID
  GitHubAchievement? getAchievementById(String id) {
    try {
      return state.achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get next achievement to unlock (closest to completion)
  GitHubAchievement? getNextAchievement() {
    final locked = state.lockedAchievements;
    if (locked.isEmpty) return null;

    // Sort by progress (highest first)
    locked.sort((a, b) => b.progress.compareTo(a.progress));
    return locked.first;
  }

  // Calculate streaks from contributions
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
    final todayStr = today.toIso8601String().split('T')[0];
    final yesterdayStr = today.subtract(const Duration(days: 1)).toIso8601String().split('T')[0];

    if (contributions.containsKey(todayStr) || contributions.containsKey(yesterdayStr)) {
      var checkDate = contributions.containsKey(todayStr) 
          ? today 
          : today.subtract(const Duration(days: 1));
      currentStreak = 0;

      while (true) {
        final checkDateStr = checkDate.toIso8601String().split('T')[0];
        if (contributions.containsKey(checkDateStr) && (contributions[checkDateStr] ?? 0) > 0) {
          currentStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  // Reset all achievements (for testing)
  Future<void> resetAllAchievements() async {
    await _service.resetAllAchievements();
    await loadAchievements();
    debugPrint('🔄 All achievements reset');
  }
}

// Quick access providers
final totalXPProvider = Provider<int>((ref) {
  return ref.watch(achievementProvider).totalXP;
});

final userLevelProvider = Provider<int>((ref) {
  return ref.watch(achievementProvider).level;
});

final unlockedAchievementsCountProvider = Provider<int>((ref) {
  return ref.watch(achievementProvider).unlockedAchievements.length;
});

final achievementCompletionProvider = Provider<double>((ref) {
  return ref.watch(achievementProvider).completionPercentage;
});