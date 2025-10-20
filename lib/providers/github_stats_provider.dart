// lib/providers/github_stats_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/services/github_api_service.dart';
import 'auth_provider.dart';

class GitHubStats {
  final int totalRepos;
  final int publicRepos;
  final int privateRepos;
  final Map<String, int> contributions;
  final int totalContributions;
  final Map<String, int> repoBreakdown; // NEW: commits per repo
  final bool isLoading;
  final String? error;

  GitHubStats({
    this.totalRepos = 0,
    this.publicRepos = 0,
    this.privateRepos = 0,
    this.contributions = const {},
    this.totalContributions = 0,
    this.repoBreakdown = const {},
    this.isLoading = false,
    this.error,
  });

  GitHubStats copyWith({
    int? totalRepos,
    int? publicRepos,
    int? privateRepos,
    Map<String, int>? contributions,
    int? totalContributions,
    Map<String, int>? repoBreakdown,
    bool? isLoading,
    String? error,
  }) {
    return GitHubStats(
      totalRepos: totalRepos ?? this.totalRepos,
      publicRepos: publicRepos ?? this.publicRepos,
      privateRepos: privateRepos ?? this.privateRepos,
      contributions: contributions ?? this.contributions,
      totalContributions: totalContributions ?? this.totalContributions,
      repoBreakdown: repoBreakdown ?? this.repoBreakdown,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class GitHubStatsNotifier extends StateNotifier<GitHubStats> {
  final GitHubApiService _apiService;
  final String username;

  GitHubStatsNotifier(this._apiService, this.username) : super(GitHubStats()) {
    fetchStats();
  }

  Future<void> fetchStats() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Get current user info to get their email
      final currentUser = await _apiService.getCurrentUser();
      final userEmail = currentUser['email'] as String?;
      
      debugPrint('🔍 Authenticated user email: $userEmail');

      // Fetch ALL repos (public + private) with pagination
      final repos = <dynamic>[];
      var page = 1;
      var hasMore = true;
      
      while (hasMore) {
        final pageRepos = await _apiService.getUserRepositories(
          page: page,
          perPage: 100,
        );
        
        if (pageRepos.isEmpty) {
          hasMore = false;
        } else {
          repos.addAll(pageRepos);
          debugPrint('📦 Fetched page $page: ${pageRepos.length} repos (total so far: ${repos.length})');
          
          if (pageRepos.length < 100) {
            hasMore = false;
          } else {
            page++;
          }
        }
      }
      
      debugPrint('✅ Total repos fetched: ${repos.length}');

      final publicCount = repos.where((repo) => repo['private'] == false).length;
      final privateCount = repos.where((repo) => repo['private'] == true).length;

      // Fetch contribution data from all repos
      final contributionData = await _fetchContributionsFromRepos(repos, userEmail);

      state = state.copyWith(
        totalRepos: repos.length,
        publicRepos: publicCount,
        privateRepos: privateCount,
        contributions: contributionData['contributions'],
        totalContributions: contributionData['total'],
        repoBreakdown: contributionData['repoBreakdown'],
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Error fetching stats: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> _fetchContributionsFromRepos(List<dynamic> repos, String? userEmail) async {
    try {
      final now = DateTime.now();
      // Fetch commits from last 400 days to ensure we get everything
      final fetchFrom = now.subtract(const Duration(days: 400));
      
      final contributions = <String, int>{};
      final repoBreakdown = <String, int>{}; // Track commits per repo
      var total = 0;

      debugPrint('🔍 Fetching commits from ${repos.length} repositories...');
      debugPrint('📅 Date range: ${fetchFrom.toIso8601String()} to ${now.toIso8601String()}');

      // Fetch commits from each repo
      for (var repo in repos) {
        try {
          final owner = repo['owner']['login'] as String;
          final repoName = repo['name'] as String;
          final isPrivate = repo['private'] ?? false;
          
          // Check if this repo is owned by the user
          final isOwnedByUser = owner.toLowerCase() == username.toLowerCase();
          
          debugPrint('📦 Checking repo: $owner/$repoName ${isPrivate ? "(PRIVATE)" : "(PUBLIC)"} ${isOwnedByUser ? "[OWNED BY USER]" : ""}');

          // Fetch ALL commits from this repo for the past year (paginated)
          var page = 1;
          var hasMore = true;
          var repoCommitCount = 0;
          final maxPages = 50; // Prevent infinite loops, 50 pages * 100 commits = 5000 commits max per repo

          while (hasMore && page <= maxPages) {
            try {
              // Don't filter by author in the API call, we'll filter ourselves
              final commits = await _apiService.getRepositoryCommits(
                owner,
                repoName,
                page: page,
                since: fetchFrom.toIso8601String(),
                until: now.toIso8601String(),
              );

              if (commits.isEmpty) {
                hasMore = false;
                break;
              }

              debugPrint('   Page $page: ${commits.length} commits (before filtering)');

              var pageCommitCount = 0;
              var skippedCommits = 0;
              // Process each commit and filter by author
              for (var commit in commits) {
                try {
                  // Check if this commit is by the current user
                  final author = commit['author'];
                  final commitData = commit['commit'];
                  final commitAuthor = commitData?['author'];
                  
                  final authorLogin = author?['login'] as String?;
                  final commitAuthorName = commitAuthor?['name'] as String?;
                  final commitAuthorEmail = commitAuthor?['email'] as String?;
                  
                  // Check if this is the user's commit by checking multiple fields
                  bool isUserCommit = false;
                  String matchReason = '';
                  
                  // If this is the user's own repo, count ALL commits
                  if (isOwnedByUser) {
                    isUserCommit = true;
                    matchReason = 'owned repo';
                  }
                  // Match by login
                  else if (authorLogin != null && authorLogin.toLowerCase() == username.toLowerCase()) {
                    isUserCommit = true;
                    matchReason = 'username match';
                  } 
                  // Match by name
                  else if (commitAuthorName != null && commitAuthorName.toLowerCase() == username.toLowerCase()) {
                    isUserCommit = true;
                    matchReason = 'name match';
                  } 
                  // Match by email
                  else if (userEmail != null && commitAuthorEmail != null && 
                           commitAuthorEmail.toLowerCase() == userEmail.toLowerCase()) {
                    isUserCommit = true;
                    matchReason = 'email match';
                  }
                  // Also match if email contains username
                  else if (commitAuthorEmail != null && commitAuthorEmail.toLowerCase().contains(username.toLowerCase())) {
                    isUserCommit = true;
                    matchReason = 'email contains username';
                  }
                  
                  // Only count commits by this user
                  if (isUserCommit && commitData != null && commitAuthor != null) {
                    final dateStr = commitAuthor['date'] as String?;
                    if (dateStr != null) {
                      final commitDate = DateTime.parse(dateStr);
                      final dateKey = DateFormat('yyyy-MM-dd').format(commitDate);
                      
                      // Count this commit
                      contributions[dateKey] = (contributions[dateKey] ?? 0) + 1;
                      total++;
                      repoCommitCount++;
                      pageCommitCount++;
                      
                      // Log first few commits for verification
                      if (pageCommitCount <= 3) {
                        debugPrint('      ✓ Commit by $commitAuthorName <$commitAuthorEmail> on $dateKey (matched: $matchReason)');
                      }
                    }
                  } else {
                    skippedCommits++;
                    if (skippedCommits <= 2) {
                      debugPrint('      ✗ Skipped commit by $commitAuthorName <$commitAuthorEmail> (login: $authorLogin)');
                    }
                  }
                } catch (e) {
                  debugPrint('   ⚠️ Error processing commit: $e');
                  continue;
                }
              }
              
              if (skippedCommits > 0) {
                debugPrint('   📊 Skipped $skippedCommits commits (not by $username)');
              }
              debugPrint('   ✅ Page $page: $pageCommitCount commits counted');

              // Check if we should fetch more pages
              if (commits.length < 100) {
                hasMore = false;
                debugPrint('   📌 Last page reached (less than 100 commits)');
              } else {
                page++;
                if (page > maxPages) {
                  debugPrint('   ⚠️ Max pages reached ($maxPages), stopping pagination');
                }
              }
            } catch (e) {
              debugPrint('   ❌ Error fetching page $page: $e');
              hasMore = false;
            }
          }

          debugPrint('   ✅ Total commits in $repoName: $repoCommitCount');
          
          // Store repo breakdown
          if (repoCommitCount > 0) {
            repoBreakdown[repoName] = repoCommitCount;
          }
        } catch (e) {
          debugPrint('   ⚠️ Error fetching commits from repo: $e');
          continue;
        }
      }

      debugPrint('✅ Total contributions found: $total');
      debugPrint('📊 Contribution days: ${contributions.length}');
      debugPrint('📅 Date range covered: ${contributions.keys.isNotEmpty ? contributions.keys.reduce((a, b) => a.compareTo(b) < 0 ? a : b) : "none"} to ${contributions.keys.isNotEmpty ? contributions.keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b) : "none"}');
      debugPrint('🗂️  Repo breakdown: ${repoBreakdown.length} repos');
      repoBreakdown.forEach((repo, count) {
        debugPrint('   📁 $repo: $count commits');
      });

      return {
        'contributions': contributions,
        'total': total,
        'repoBreakdown': repoBreakdown,
      };
    } catch (e) {
      debugPrint('❌ Error fetching contributions: $e');
      return {
        'contributions': <String, int>{},
        'total': 0,
        'repoBreakdown': <String, int>{},
      };
    }
  }

  Future<void> refresh() async {
    await fetchStats();
  }
}

// Provider
final githubStatsProvider = StateNotifierProvider.family<GitHubStatsNotifier, GitHubStats, String>(
  (ref, username) {
    final apiService = GitHubApiService();
    return GitHubStatsNotifier(apiService, username);
  },
);