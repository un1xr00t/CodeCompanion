import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/constants/app_constants.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio _dio = Dio();
  final StorageService _storage = StorageService();

  // Generate GitHub OAuth URL
  String getAuthorizationUrl() {
    final clientId = dotenv.env['GITHUB_CLIENT_ID'] ?? '';
    final redirectUri = dotenv.env['GITHUB_REDIRECT_URI'] ?? '';
    final scopes = AppConstants.githubScopes.join(' ');
    
  return '${AppConstants.githubAuthUrl}?client_id=$clientId&redirect_uri=$redirectUri&scope=$scopes&prompt=consent';
  }

  // Exchange authorization code for access token
  Future<String> exchangeCodeForToken(String code) async {
  try {
    final clientId = dotenv.env['GITHUB_CLIENT_ID'] ?? '';
    final clientSecret = dotenv.env['GITHUB_CLIENT_SECRET'] ?? '';
    final redirectUri = dotenv.env['GITHUB_REDIRECT_URI'] ?? '';

    debugPrint('🔄 Exchanging code for token...');
    debugPrint('   Client ID: ${clientId.substring(0, 8)}...');
    debugPrint('   Redirect URI: $redirectUri');
    debugPrint('   Code: ${code.substring(0, 8)}...');

    final response = await _dio.post(
      AppConstants.githubTokenUrl,
      data: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'code': code,
        'redirect_uri': redirectUri,
      },
      options: Options(
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    debugPrint('📥 GitHub response: ${response.data}');

    if (response.data['access_token'] != null) {
      final token = response.data['access_token'] as String;
      await _storage.saveSecure(AppConstants.accessTokenKey, token);
      return token;
    } else {
      debugPrint('❌ No access_token in response. Error: ${response.data['error']}');
      debugPrint('❌ Error description: ${response.data['error_description']}');
      throw Exception('Failed to get access token: ${response.data['error'] ?? 'Unknown error'}');
    }
  } catch (e) {
    debugPrint('❌ Exception during token exchange: $e');
    throw Exception('Authentication failed: $e');
  }
}

  // Get current user info
  Future<UserModel> getCurrentUser(String token) async {
    try {
      final response = await _dio.get(
        '${AppConstants.githubApiBaseUrl}/user',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/vnd.github.v3+json',
          },
        ),
      );

      final user = UserModel.fromJson(response.data);
      await _storage.saveString(
        AppConstants.userDataKey,
        jsonEncode(user.toJson()),
      );
      return user;
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _storage.readSecure(AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  // Get stored access token
  Future<String?> getAccessToken() async {
    return await _storage.readSecure(AppConstants.accessTokenKey);
  }

  // Get cached user data
  Future<UserModel?> getCachedUser() async {
    final userData = _storage.getString(AppConstants.userDataKey);
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    await _storage.clearSecure();
    await _storage.remove(AppConstants.userDataKey);
  }
}