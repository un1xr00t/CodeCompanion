import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../services/storage_service.dart';
import '../../core/constants/app_constants.dart';

class GitHubRepository {
  final Dio _dio = Dio();
  final StorageService _storage = StorageService();

  GitHubRepository() {
    _dio.options.baseUrl = ApiConstants.githubApiBase;
    _dio.options.connectTimeout = ApiConstants.connectTimeout;
    _dio.options.receiveTimeout = ApiConstants.receiveTimeout;
  }

  Future<String?> _getToken() async {
    return await _storage.readSecure(AppConstants.accessTokenKey);
  }

  Map<String, dynamic> _getHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': ApiConstants.acceptHeader,
    };
  }

  // Get user repositories
  Future<List<dynamic>> getUserRepositories({
    int page = 1,
    int perPage = ApiConstants.defaultPerPage,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No access token found');

      final response = await _dio.get(
        ApiConstants.userRepos,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'sort': 'updated',
        },
        options: Options(headers: _getHeaders(token)),
      );

      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch repositories: $e');
    }
  }

  // Get user events (commits, PRs, issues, etc.)
  Future<List<dynamic>> getUserEvents(String username, {int page = 1}) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No access token found');

      final endpoint = ApiConstants.userEvents.replaceAll('{username}', username);
      
      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'page': page,
          'per_page': ApiConstants.defaultPerPage,
        },
        options: Options(headers: _getHeaders(token)),
      );

      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  // Get repository languages
  Future<Map<String, dynamic>> getRepositoryLanguages(
    String owner,
    String repo,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No access token found');

      final endpoint = ApiConstants.repoLanguages
          .replaceAll('{owner}', owner)
          .replaceAll('{repo}', repo);

      final response = await _dio.get(
        endpoint,
        options: Options(headers: _getHeaders(token)),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch languages: $e');
    }
  }

  // Get repository commits
  Future<List<dynamic>> getRepositoryCommits(
    String owner,
    String repo, {
    int page = 1,
    String? since,
    String? until,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No access token found');

      final endpoint = ApiConstants.repoCommits
          .replaceAll('{owner}', owner)
          .replaceAll('{repo}', repo);

      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': ApiConstants.defaultPerPage,
      };

      if (since != null) queryParams['since'] = since;
      if (until != null) queryParams['until'] = until;

      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(headers: _getHeaders(token)),
      );

      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch commits: $e');
    }
  }

  // Get commit activity stats
  Future<List<dynamic>> getCommitActivity(String owner, String repo) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No access token found');

      final endpoint = ApiConstants.commitActivity
          .replaceAll('{owner}', owner)
          .replaceAll('{repo}', repo);

      final response = await _dio.get(
        endpoint,
        options: Options(headers: _getHeaders(token)),
      );

      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch commit activity: $e');
    }
  }

  // Get repository contributors
  Future<List<dynamic>> getRepositoryContributors(
    String owner,
    String repo,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No access token found');

      final endpoint = ApiConstants.contributors
          .replaceAll('{owner}', owner)
          .replaceAll('{repo}', repo);

      final response = await _dio.get(
        endpoint,
        options: Options(headers: _getHeaders(token)),
      );

      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch contributors: $e');
    }
  }
}