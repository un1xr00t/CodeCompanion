// lib/data/services/github_api_service.dart
import 'package:dio/dio.dart';
import 'api_service.dart';
import 'storage_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/api_constants.dart';

class GitHubApiService {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  Future<Options> _getAuthOptions() async {
    final token = await _storage.readSecure(AppConstants.accessTokenKey);
    if (token == null) {
      throw Exception('No access token available');
    }

    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': ApiConstants.acceptHeader,
      },
    );
  }

  // Get authenticated user
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final options = await _getAuthOptions();
      final response = await _apiService.get(
        ApiConstants.user,
        options: options,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  // Get user repositories
  Future<List<dynamic>> getUserRepositories({
    int page = 1,
    int perPage = 30,
    String sort = 'updated',
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _apiService.get(
        ApiConstants.userRepos,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'sort': sort,
          'visibility': 'all', // Include private repos
        },
        options: options,
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to get repositories: $e');
    }
  }

  // Get user events (commits, PRs, etc.)
  Future<List<dynamic>> getUserEvents(String username, {int page = 1}) async {
    try {
      final options = await _getAuthOptions();
      final endpoint = ApiConstants.userEvents.replaceAll('{username}', username);
      
      final response = await _apiService.get(
        endpoint,
        queryParameters: {
          'page': page,
          'per_page': ApiConstants.defaultPerPage,
        },
        options: options,
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to get user events: $e');
    }
  }

  // Get repository details
  Future<Map<String, dynamic>> getRepository(String owner, String repo) async {
    try {
      final options = await _getAuthOptions();
      final endpoint = ApiConstants.repos
          .replaceAll('{owner}', owner)
          .replaceAll('{repo}', repo);
      
      final response = await _apiService.get(endpoint, options: options);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get repository: $e');
    }
  }

  // Get repository languages
  Future<Map<String, dynamic>> getRepositoryLanguages(
    String owner,
    String repo,
  ) async {
    try {
      final options = await _getAuthOptions();
      final endpoint = ApiConstants.repoLanguages
          .replaceAll('{owner}', owner)
          .replaceAll('{repo}', repo);
      
      final response = await _apiService.get(endpoint, options: options);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get repository languages: $e');
    }
  }

  // Get repository commits - UPDATED TO FETCH MORE
  Future<List<dynamic>> getRepositoryCommits(
    String owner,
    String repo, {
    int page = 1,
    String? author,
    String? since,
    String? until,
  }) async {
    try {
      final options = await _getAuthOptions();
      final endpoint = ApiConstants.repoCommits
          .replaceAll('{owner}', owner)
          .replaceAll('{repo}', repo);

      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': 100, // Max allowed by GitHub API
      };

      if (author != null) queryParams['author'] = author;
      if (since != null) queryParams['since'] = since;
      if (until != null) queryParams['until'] = until;

      final response = await _apiService.get(
        endpoint,
        queryParameters: queryParams,
        options: options,
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to get repository commits: $e');
    }
  }

  // Get commit activity stats (for contribution grid)
  Future<List<dynamic>> getCommitActivity(String owner, String repo) async {
    try {
      final options = await _getAuthOptions();
      final endpoint = ApiConstants.commitActivity
          .replaceAll('{owner}', owner)
          .replaceAll('{repo}', repo);
      
      final response = await _apiService.get(endpoint, options: options);
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to get commit activity: $e');
    }
  }

  // Get all languages across user's repositories
  Future<Map<String, int>> getAllLanguages() async {
    try {
      final repos = await getUserRepositories();
      final languageMap = <String, int>{};

      for (var repo in repos) {
        if (repo['fork'] == true) continue; // Skip forks
        
        final owner = repo['owner']['login'] as String;
        final repoName = repo['name'] as String;

        try {
          final languages = await getRepositoryLanguages(owner, repoName);
          languages.forEach((language, bytes) {
            languageMap[language] = (languageMap[language] ?? 0) + (bytes as int);
          });
        } catch (e) {
          // Skip if languages can't be fetched for this repo
          continue;
        }
      }

      return languageMap;
    } catch (e) {
      throw Exception('Failed to get all languages: $e');
    }
  }

  // Get contribution data for a specific time range
  Future<Map<String, dynamic>> getContributions({
    required String username,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final events = await getUserEvents(username);
      
      // Filter and process events to calculate contributions
      final contributions = <String, int>{};
      
      for (var event in events) {
        if (event['type'] == 'PushEvent') {
          final date = DateTime.parse(event['created_at'] as String);
          final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          
          contributions[dateKey] = (contributions[dateKey] ?? 0) + 1;
        }
      }

      return contributions;
    } catch (e) {
      throw Exception('Failed to get contributions: $e');
    }
  }
}