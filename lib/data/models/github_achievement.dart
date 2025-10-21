// lib/data/models/github_achievement.dart
import 'package:flutter/material.dart';

enum AchievementCategory {
  commits,
  streaks,
  repositories,
  milestones,
  special;

  String get displayName {
    switch (this) {
      case AchievementCategory.commits:
        return 'Commits';
      case AchievementCategory.streaks:
        return 'Streaks';
      case AchievementCategory.repositories:
        return 'Repositories';
      case AchievementCategory.milestones:
        return 'Milestones';
      case AchievementCategory.special:
        return 'Special';
    }
  }
}

class GitHubAchievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final Color color;
  final AchievementCategory category;
  final int xpReward;
  final int targetValue;
  final int currentValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  GitHubAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.color,
    required this.category,
    required this.xpReward,
    required this.targetValue,
    this.currentValue = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progress {
    if (isUnlocked) return 1.0;
    if (targetValue == 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  GitHubAchievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    Color? color,
    AchievementCategory? category,
    int? xpReward,
    int? targetValue,
    int? currentValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return GitHubAchievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      category: category ?? this.category,
      xpReward: xpReward ?? this.xpReward,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'colorValue': color.value,
      'category': category.name,
      'xpReward': xpReward,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory GitHubAchievement.fromJson(Map<String, dynamic> json) {
    return GitHubAchievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      color: Color(json['colorValue'] as int),
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      xpReward: json['xpReward'] as int,
      targetValue: json['targetValue'] as int,
      currentValue: json['currentValue'] as int? ?? 0,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }

  // 🏆 Predefined Achievements
  static List<GitHubAchievement> get allAchievements => [
        // Streak Achievements
        GitHubAchievement(
          id: 'streak_3',
          title: 'Getting Started',
          description: 'Commit for 3 days in a row',
          iconName: 'local_fire_department',
          color: const Color(0xFFFF6B35),
          category: AchievementCategory.streaks,
          xpReward: 50,
          targetValue: 3,
        ),
        GitHubAchievement(
          id: 'streak_7',
          title: 'Week Warrior',
          description: 'Maintain a 7-day commit streak',
          iconName: 'local_fire_department',
          color: const Color(0xFFFF8C42),
          category: AchievementCategory.streaks,
          xpReward: 100,
          targetValue: 7,
        ),
        GitHubAchievement(
          id: 'streak_14',
          title: 'Two Weeks Strong',
          description: 'Keep the streak alive for 14 days',
          iconName: 'whatshot',
          color: const Color(0xFFFFAA4D),
          category: AchievementCategory.streaks,
          xpReward: 250,
          targetValue: 14,
        ),
        GitHubAchievement(
          id: 'streak_30',
          title: 'Month Master',
          description: 'Commit every day for 30 days',
          iconName: 'whatshot',
          color: const Color(0xFFFFC857),
          category: AchievementCategory.streaks,
          xpReward: 500,
          targetValue: 30,
        ),
        GitHubAchievement(
          id: 'streak_90',
          title: 'Unstoppable Force',
          description: 'Achieve a 90-day commit streak',
          iconName: 'celebration',
          color: const Color(0xFFFFD700),
          category: AchievementCategory.streaks,
          xpReward: 1000,
          targetValue: 90,
        ),
        GitHubAchievement(
          id: 'streak_365',
          title: 'Year of Code',
          description: 'Commit every single day for a year',
          iconName: 'diamond',
          color: const Color(0xFFB19CD9),
          category: AchievementCategory.streaks,
          xpReward: 5000,
          targetValue: 365,
        ),

        // Commit Milestones
        GitHubAchievement(
          id: 'commits_10',
          title: 'First Steps',
          description: 'Make your first 10 commits',
          iconName: 'flag',
          color: const Color(0xFF10B981),
          category: AchievementCategory.commits,
          xpReward: 25,
          targetValue: 10,
        ),
        GitHubAchievement(
          id: 'commits_50',
          title: 'Contributor',
          description: 'Reach 50 total commits',
          iconName: 'trending_up',
          color: const Color(0xFF14B8A6),
          category: AchievementCategory.commits,
          xpReward: 75,
          targetValue: 50,
        ),
        GitHubAchievement(
          id: 'commits_100',
          title: 'Centurion',
          description: 'Make 100 commits',
          iconName: 'star',
          color: const Color(0xFF06B6D4),
          category: AchievementCategory.commits,
          xpReward: 150,
          targetValue: 100,
        ),
        GitHubAchievement(
          id: 'commits_500',
          title: 'Prolific Coder',
          description: 'Commit 500 times',
          iconName: 'rocket_launch',
          color: const Color(0xFF0EA5E9),
          category: AchievementCategory.commits,
          xpReward: 500,
          targetValue: 500,
        ),
        GitHubAchievement(
          id: 'commits_1000',
          title: 'Code Machine',
          description: 'Reach 1,000 commits',
          iconName: 'emoji_events',
          color: const Color(0xFF3B82F6),
          category: AchievementCategory.commits,
          xpReward: 1000,
          targetValue: 1000,
        ),
        GitHubAchievement(
          id: 'commits_5000',
          title: 'Commit Legend',
          description: 'Make an incredible 5,000 commits',
          iconName: 'military_tech',
          color: const Color(0xFF8B5CF6),
          category: AchievementCategory.commits,
          xpReward: 2500,
          targetValue: 5000,
        ),

        // Repository Achievements
        GitHubAchievement(
          id: 'repos_5',
          title: 'Project Starter',
          description: 'Create 5 repositories',
          iconName: 'folder',
          color: const Color(0xFF22C55E),
          category: AchievementCategory.repositories,
          xpReward: 50,
          targetValue: 5,
        ),
        GitHubAchievement(
          id: 'repos_10',
          title: 'Portfolio Builder',
          description: 'Own 10 repositories',
          iconName: 'folder_open',
          color: const Color(0xFF16A34A),
          category: AchievementCategory.repositories,
          xpReward: 100,
          targetValue: 10,
        ),
        GitHubAchievement(
          id: 'repos_25',
          title: 'Code Architect',
          description: 'Manage 25 repositories',
          iconName: 'account_tree',
          color: const Color(0xFF15803D),
          category: AchievementCategory.repositories,
          xpReward: 250,
          targetValue: 25,
        ),
        GitHubAchievement(
          id: 'repos_50',
          title: 'Open Source Hero',
          description: 'Create 50 repositories',
          iconName: 'source',
          color: const Color(0xFF166534),
          category: AchievementCategory.repositories,
          xpReward: 500,
          targetValue: 50,
        ),

        // Daily Activity
        GitHubAchievement(
          id: 'busy_day_10',
          title: 'Productive Day',
          description: 'Make 10 commits in a single day',
          iconName: 'today',
          color: const Color(0xFFF59E0B),
          category: AchievementCategory.milestones,
          xpReward: 100,
          targetValue: 10,
        ),
        GitHubAchievement(
          id: 'busy_day_25',
          title: 'Code Sprint',
          description: 'Make 25 commits in one day',
          iconName: 'speed',
          color: const Color(0xFFEA580C),
          category: AchievementCategory.milestones,
          xpReward: 250,
          targetValue: 25,
        ),
        GitHubAchievement(
          id: 'busy_day_50',
          title: 'Coding Marathon',
          description: 'Incredibly, commit 50 times in one day',
          iconName: 'flash_on',
          color: const Color(0xFFDC2626),
          category: AchievementCategory.milestones,
          xpReward: 500,
          targetValue: 50,
        ),

        // Follower Milestones
        GitHubAchievement(
          id: 'followers_10',
          title: 'Getting Noticed',
          description: 'Gain 10 followers',
          iconName: 'group',
          color: const Color(0xFF06B6D4),
          category: AchievementCategory.milestones,
          xpReward: 75,
          targetValue: 10,
        ),
        GitHubAchievement(
          id: 'followers_50',
          title: 'Rising Star',
          description: 'Reach 50 followers',
          iconName: 'groups',
          color: const Color(0xFF0EA5E9),
          category: AchievementCategory.milestones,
          xpReward: 200,
          targetValue: 50,
        ),
        GitHubAchievement(
          id: 'followers_100',
          title: 'Influencer',
          description: 'Gain 100 followers',
          iconName: 'diversity_3',
          color: const Color(0xFF3B82F6),
          category: AchievementCategory.milestones,
          xpReward: 500,
          targetValue: 100,
        ),

        // Special Achievements
        GitHubAchievement(
          id: 'first_commit',
          title: 'Hello World',
          description: 'Make your very first commit',
          iconName: 'celebration',
          color: const Color(0xFF10B981),
          category: AchievementCategory.special,
          xpReward: 10,
          targetValue: 1,
        ),
        GitHubAchievement(
          id: 'night_owl',
          title: 'Night Owl',
          description: 'Commit between midnight and 5 AM',
          iconName: 'dark_mode',
          color: const Color(0xFF4C1D95),
          category: AchievementCategory.special,
          xpReward: 50,
          targetValue: 1,
        ),
        GitHubAchievement(
          id: 'early_bird',
          title: 'Early Bird',
          description: 'Commit between 5 AM and 7 AM',
          iconName: 'wb_sunny',
          color: const Color(0xFFFBBF24),
          category: AchievementCategory.special,
          xpReward: 50,
          targetValue: 1,
        ),
        GitHubAchievement(
          id: 'weekend_warrior',
          title: 'Weekend Warrior',
          description: 'Commit on both Saturday and Sunday',
          iconName: 'weekend',
          color: const Color(0xFF8B5CF6),
          category: AchievementCategory.special,
          xpReward: 75,
          targetValue: 1,
        ),
        GitHubAchievement(
          id: 'polyglot',
          title: 'Polyglot',
          description: 'Use 5 different programming languages',
          iconName: 'translate',
          color: const Color(0xFFEC4899),
          category: AchievementCategory.special,
          xpReward: 200,
          targetValue: 5,
        ),
      ];
}