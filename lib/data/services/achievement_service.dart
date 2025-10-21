// lib/data/services/achievement_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/github_achievement.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  SharedPreferences? _prefs;
  
  static const String _achievementsKey = 'unlocked_achievements';
  static const String _totalXPKey = 'total_xp';
  static const String _lastCheckKey = 'last_achievement_check';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get all achievements with current progress
  Future<List<GitHubAchievement>> getAllAchievements({
    required int totalCommits,
    required int currentStreak,
    required int longestStreak,
    required int totalRepos,
    required int followers,
    required Map<String, int> contributions,
    required Map<String, int> languageBreakdown,
    List<DateTime>? commitTimestamps, // New parameter for time-based achievements
  }) async {
    final unlockedIds = await getUnlockedAchievementIds();
    final unlockedData = await _getUnlockedAchievementData();

    return GitHubAchievement.allAchievements.map((achievement) {
      final isUnlocked = unlockedIds.contains(achievement.id);
      final unlockedAt = unlockedData[achievement.id];
      
      int currentValue = 0;

      // Calculate current progress based on achievement type
      switch (achievement.id) {
        // Streak achievements
        case 'streak_3':
        case 'streak_7':
        case 'streak_14':
        case 'streak_30':
        case 'streak_90':
        case 'streak_365':
          currentValue = currentStreak;
          break;

        // Commit achievements
        case 'commits_10':
        case 'commits_50':
        case 'commits_100':
        case 'commits_500':
        case 'commits_1000':
        case 'commits_5000':
          currentValue = totalCommits;
          break;

        // Repository achievements
        case 'repos_5':
        case 'repos_10':
        case 'repos_25':
        case 'repos_50':
          currentValue = totalRepos;
          break;

        // Follower achievements
        case 'followers_10':
        case 'followers_50':
        case 'followers_100':
          currentValue = followers;
          break;

        // Busy day achievements
        case 'busy_day_10':
        case 'busy_day_25':
        case 'busy_day_50':
          currentValue = _getMaxCommitsInOneDay(contributions);
          break;

        // Special achievements
        case 'first_commit':
          currentValue = totalCommits > 0 ? 1 : 0;
          break;

        case 'night_owl':
          currentValue = (commitTimestamps != null && checkNightOwl(commitTimestamps)) ? 1 : 0;
          break;

        case 'early_bird':
          currentValue = (commitTimestamps != null && checkEarlyBird(commitTimestamps)) ? 1 : 0;
          break;

        case 'weekend_warrior':
          currentValue = _checkWeekendWarrior(contributions) ? 1 : 0;
          break;

        case 'polyglot':
          currentValue = languageBreakdown.length;
          break;
      }

      return achievement.copyWith(
        currentValue: currentValue,
        isUnlocked: isUnlocked,
        unlockedAt: unlockedAt,
      );
    }).toList();
  }

  // Check and unlock achievements
  Future<List<GitHubAchievement>> checkAndUnlockAchievements({
    required int totalCommits,
    required int currentStreak,
    required int longestStreak,
    required int totalRepos,
    required int followers,
    required Map<String, int> contributions,
    required Map<String, int> languageBreakdown,
    List<DateTime>? commitTimestamps, // New parameter
  }) async {
    final achievements = await getAllAchievements(
      totalCommits: totalCommits,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalRepos: totalRepos,
      followers: followers,
      contributions: contributions,
      languageBreakdown: languageBreakdown,
      commitTimestamps: commitTimestamps,
    );

    final newlyUnlocked = <GitHubAchievement>[];
    final unlockedIds = await getUnlockedAchievementIds();

    for (final achievement in achievements) {
      if (!achievement.isUnlocked && achievement.currentValue >= achievement.targetValue) {
        // Unlock this achievement!
        await _unlockAchievement(achievement);
        newlyUnlocked.add(achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        ));
        
        debugPrint('🏆 Achievement unlocked: ${achievement.title} (+${achievement.xpReward} XP)');
      }
    }

    return newlyUnlocked;
  }

  // Unlock achievement and award XP
  Future<void> _unlockAchievement(GitHubAchievement achievement) async {
    final unlockedIds = await getUnlockedAchievementIds();
    if (!unlockedIds.contains(achievement.id)) {
      unlockedIds.add(achievement.id);
      
      // Save unlocked achievement with timestamp
      final unlockedData = await _getUnlockedAchievementData();
      unlockedData[achievement.id] = DateTime.now();
      
      await _prefs?.setStringList(_achievementsKey, unlockedIds);
      await _prefs?.setString(
        '${_achievementsKey}_data',
        jsonEncode(unlockedData.map((k, v) => MapEntry(k, v.toIso8601String()))),
      );
      
      // Award XP
      await addXP(achievement.xpReward);
    }
  }

  // Get unlocked achievement IDs
  Future<List<String>> getUnlockedAchievementIds() async {
    return _prefs?.getStringList(_achievementsKey) ?? [];
  }

  // Get unlocked achievement data with timestamps
  Future<Map<String, DateTime>> _getUnlockedAchievementData() async {
    final dataStr = _prefs?.getString('${_achievementsKey}_data');
    if (dataStr == null) return {};
    
    final Map<String, dynamic> decoded = jsonDecode(dataStr);
    return decoded.map((k, v) => MapEntry(k, DateTime.parse(v as String)));
  }

  // XP Management
  Future<int> getTotalXP() async {
    return _prefs?.getInt(_totalXPKey) ?? 0;
  }

  Future<void> addXP(int amount) async {
    final currentXP = await getTotalXP();
    await _prefs?.setInt(_totalXPKey, currentXP + amount);
  }

  Future<void> resetXP() async {
    await _prefs?.setInt(_totalXPKey, 0);
  }

  // Get level from XP (similar to your XPService)
  int getLevelFromXP(int totalXP) {
    if (totalXP < 100) return 1;
    if (totalXP < 350) return 2; // 100 + 250
    if (totalXP < 850) return 3; // 350 + 500
    if (totalXP < 1850) return 4; // 850 + 1000
    if (totalXP < 3850) return 5; // 1850 + 2000
    
    // Level 6+: 2000 XP per level
    return 5 + ((totalXP - 3850) ~/ 2000);
  }

  // Helper: Get max commits in one day
  int _getMaxCommitsInOneDay(Map<String, int> contributions) {
    if (contributions.isEmpty) return 0;
    return contributions.values.reduce((a, b) => a > b ? a : b);
  }

  // Helper: Check if user has committed at night (12 AM - 5 AM)
  // Note: This now requires commit timestamps to be passed separately
  bool checkNightOwl(List<DateTime> commitTimestamps) {
    for (final timestamp in commitTimestamps) {
      final hour = timestamp.hour;
      if (hour >= 0 && hour < 5) {
        return true;
      }
    }
    return false;
  }

  // Helper: Check if user has committed early morning (5 AM - 7 AM)
  bool checkEarlyBird(List<DateTime> commitTimestamps) {
    for (final timestamp in commitTimestamps) {
      final hour = timestamp.hour;
      if (hour >= 5 && hour < 7) {
        return true;
      }
    }
    return false;
  }

  // Helper: Check if user committed on both weekend days
  bool _checkWeekendWarrior(Map<String, int> contributions) {
    // Check for Saturday and Sunday commits in recent data
    bool hasSaturdayCommit = false;
    bool hasSundayCommit = false;
    
    for (final dateStr in contributions.keys) {
      final date = DateTime.parse(dateStr);
      if (date.weekday == DateTime.saturday && contributions[dateStr]! > 0) {
        hasSaturdayCommit = true;
      }
      if (date.weekday == DateTime.sunday && contributions[dateStr]! > 0) {
        hasSundayCommit = true;
      }
    }
    
    return hasSaturdayCommit && hasSundayCommit;
  }

  // Get achievement stats
  Future<Map<String, dynamic>> getAchievementStats() async {
    final unlockedIds = await getUnlockedAchievementIds();
    final totalAchievements = GitHubAchievement.allAchievements.length;
    final totalXP = await getTotalXP();
    final level = getLevelFromXP(totalXP);
    
    return {
      'unlockedCount': unlockedIds.length,
      'totalCount': totalAchievements,
      'percentageComplete': (unlockedIds.length / totalAchievements * 100).toInt(),
      'totalXP': totalXP,
      'level': level,
    };
  }

  // Reset all achievements (for testing)
  Future<void> resetAllAchievements() async {
    await _prefs?.remove(_achievementsKey);
    await _prefs?.remove('${_achievementsKey}_data');
    await _prefs?.remove(_totalXPKey);
    debugPrint('🔄 All achievements reset');
  }
}