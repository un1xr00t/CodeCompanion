class AppConstants {
  // App Info
  static const String appName = 'CodeCompanion';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String onboardingCompleteKey = 'onboarding_complete';
  
  // GitHub OAuth
  static const String githubAuthUrl = 'https://github.com/login/oauth/authorize';
  static const String githubTokenUrl = 'https://github.com/login/oauth/access_token';
  static const String githubApiBaseUrl = 'https://api.github.com';
  
  // OAuth Scopes
  static const List<String> githubScopes = [
    'user',
    'repo',
    'read:org',
  ];
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}