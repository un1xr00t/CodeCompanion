import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  static bool _isProcessingAuth = false; // Make it static to persist across widget rebuilds
  static String? _lastProcessedCode; // Make it static
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
    
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      debugPrint('Deep link error: $err');
    });

    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleDeepLink(uri);
      }
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Received deep link: $uri');
    
    if (_isProcessingAuth) {
      debugPrint('⚠️ Already processing authentication, ignoring...');
      return;
    }
    
    if (uri.scheme == 'codecompanion' && uri.host == 'callback') {
      final code = uri.queryParameters['code'];
      
      if (code != null) {
        if (code == _lastProcessedCode) {
          debugPrint('⚠️ Ignoring duplicate authorization code');
          return;
        }
        
        _isProcessingAuth = true;
        _lastProcessedCode = code;
        debugPrint('🔑 Processing authorization code...');
        
        _linkSubscription?.cancel();
        _linkSubscription = null;
        
        if (mounted) {
          setState(() => _isLoading = true);
        }
        
        ref.read(authProvider.notifier).handleAuthCallback(code).then((_) {
          debugPrint('✅ Authentication successful!');
          // Don't use ref or setState here - widget will be disposed after navigation
        }).catchError((err) {
          debugPrint('❌ Authentication failed: $err');
          if (mounted) {
            setState(() {
              _isLoading = false;
              _isProcessingAuth = false;
            });
            _showErrorDialog(err.toString());
          }
        });
      } else {
        final error = uri.queryParameters['error'];
        final errorDescription = uri.queryParameters['error_description'];
        if (error != null && mounted) {
          _showErrorDialog('Authentication error: ${errorDescription ?? error}');
        }
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final authUrl = ref.read(authProvider.notifier).getAuthorizationUrl();
      final uri = Uri.parse(authUrl);

      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched && mounted) {
          setState(() => _isLoading = false);
          _showErrorDialog('Could not launch browser');
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorDialog('Could not launch browser');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentBlue.withOpacity(0.1),
                  AppColors.accentPurple.withOpacity(0.1),
                  AppColors.accentPink.withOpacity(0.1),
                ],
              ),
            ),
          ),
          
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentBlue.withOpacity(0.3),
                    AppColors.accentBlue.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentPurple.withOpacity(0.3),
                    AppColors.accentPurple.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.accentBlue,
                                  AppColors.accentPurple,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              CupertinoIcons.hexagon_fill,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              AppColors.accentBlue,
                              AppColors.accentPurple,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'CodeCompanion',
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Text(
                          'Your coding companion',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 60),
                        
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFeature(
                                CupertinoIcons.chart_bar_square_fill,
                                'Track Contributions',
                                'View your GitHub activity in a beautiful grid',
                              ),
                              const SizedBox(height: 20),
                              _buildFeature(
                                CupertinoIcons.flame_fill,
                                'Monitor Streaks',
                                'Keep your coding momentum going',
                              ),
                              const SizedBox(height: 20),
                              _buildFeature(
                                CupertinoIcons.star_fill,
                                'Earn Achievements',
                                'Unlock badges as you code',
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        SizedBox(
                          width: double.infinity,
                          child: GlassButton(
                            label: _isLoading || authState.isLoading
                                ? 'Connecting...'
                                : 'Continue with GitHub',
                            icon: _isLoading || authState.isLoading
                                ? null
                                : CupertinoIcons.arrow_right_circle_fill,
                            onPressed: _isLoading || authState.isLoading
                                ? null
                                : _handleLogin,
                            isPrimary: true,
                            color: AppColors.accentBlue,
                          ),
                        ),
                        
                        if (_isLoading || authState.isLoading) ...[
                          const SizedBox(height: 20),
                          const CupertinoActivityIndicator(),
                          const SizedBox(height: 12),
                          Text(
                            'Authenticating with GitHub...',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiaryLight,
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        GlassCard(
                          padding: const EdgeInsets.all(16),
                          color: AppColors.accentBlue.withOpacity(0.1),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.lock_shield_fill,
                                color: AppColors.accentBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your data is secure and never shared',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.accentBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accentBlue, AppColors.accentPurple],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.41,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondaryLight.withOpacity(0.8),
                  letterSpacing: -0.24,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}