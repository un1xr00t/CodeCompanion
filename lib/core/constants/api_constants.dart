class ApiConstants {
  // GitHub API Base URL
  static const String githubApiBase = 'https://api.github.com';
  
  // API Version
  static const String acceptHeader = 'application/vnd.github.v3+json';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPerPage = 30;
  static const int maxPerPage = 100;
  
  // GitHub API Endpoints
  static const String user = '/user';
  static const String userRepos = '/user/repos';
  static const String userEvents = '/users/{username}/events';
  static const String repos = '/repos/{owner}/{repo}';
  static const String repoLanguages = '/repos/{owner}/{repo}/languages';
  static const String repoCommits = '/repos/{owner}/{repo}/commits';
  static const String commitActivity = '/repos/{owner}/{repo}/stats/commit_activity';
  static const String contributors = '/repos/{owner}/{repo}/contributors';
  static const String userOrgs = '/user/orgs';
  static const String userGists = '/users/{username}/gists';
  
  // Rate Limiting
  static const String rateLimitEndpoint = '/rate_limit';
  static const int rateLimit = 5000; // Per hour for authenticated requests
  
  // Search Endpoints
  static const String searchRepos = '/search/repositories';
  static const String searchUsers = '/search/users';
  static const String searchCode = '/search/code';
  
  // Helper method to replace path parameters
  static String buildEndpoint(String endpoint, Map<String, String> params) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}