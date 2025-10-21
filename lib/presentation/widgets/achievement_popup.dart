// lib/presentation/widgets/achievement_popup.dart
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../data/models/github_achievement.dart';
import '../../core/theme/app_colors.dart';

class AchievementPopup extends StatefulWidget {
  final GitHubAchievement achievement;
  final VoidCallback onClose;

  const AchievementPopup({
    super.key,
    required this.achievement,
    required this.onClose,
  });

  @override
  State<AchievementPopup> createState() => _AchievementPopupState();

  // Show the popup
  static void show(BuildContext context, GitHubAchievement achievement) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => AchievementPopup(
        achievement: achievement,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _AchievementPopupState extends State<AchievementPopup>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _confettiController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;

  final List<ConfettiParticle> _confettiParticles = [];
  final int _confettiCount = 50;

  @override
  void initState() {
    super.initState();

    // Scale & fade animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeIn,
    );

    // Rotate animation for badge glow
    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotateController);

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Initialize confetti particles
    _initConfetti();

    // Start animations
    _scaleController.forward();
    _confettiController.forward();
  }

  void _initConfetti() {
    final random = math.Random();
    for (int i = 0; i < _confettiCount; i++) {
      _confettiParticles.add(
        ConfettiParticle(
          color: _getRandomConfettiColor(random),
          x: random.nextDouble(),
          y: -random.nextDouble() * 0.3,
          size: 4 + random.nextDouble() * 6,
          speedY: 0.3 + random.nextDouble() * 0.4,
          speedX: -0.15 + random.nextDouble() * 0.3,
          rotation: random.nextDouble() * 2 * math.pi,
          rotationSpeed: -0.1 + random.nextDouble() * 0.2,
        ),
      );
    }
  }

  Color _getRandomConfettiColor(math.Random random) {
    final colors = [
      AppColors.accentBlue,
      AppColors.accentPurple,
      AppColors.accentPink,
      AppColors.accentTeal,
      AppColors.accentIndigo,
      const Color(0xFFFBBF24),
      const Color(0xFF10B981),
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              color: Colors.transparent,
            ),
          ),

          // Confetti layer
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: ConfettiPainter(
                  particles: _confettiParticles,
                  progress: _confettiController.value,
                ),
                child: Container(),
              );
            },
          ),

          // Achievement card
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildAchievementCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      constraints: const BoxConstraints(maxWidth: 400),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.glassSurfaceDark.withOpacity(0.95)
                  : AppColors.glassSurfaceLight.withOpacity(0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: widget.achievement.color.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.achievement.color.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: widget.onClose,
                    icon: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: AppColors.textTertiaryLight,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),

                const SizedBox(height: 8),

                // Achievement badge with glow
                _buildBadge(),

                const SizedBox(height: 24),

                // "Achievement Unlocked" text
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.achievement.color.withOpacity(0.8),
                        widget.achievement.color,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.achievement.color.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'ACHIEVEMENT UNLOCKED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Achievement title
                Text(
                  widget.achievement.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Achievement description
                Text(
                  widget.achievement.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // XP reward
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF10B981),
                        Color(0xFF059669),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.star_fill,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '+${widget.achievement.xpReward} XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Celebrate button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.achievement.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Awesome! 🎉',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Rotating glow
            Transform.rotate(
              angle: _rotateAnimation.value,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.achievement.color.withOpacity(0.5),
                      widget.achievement.color.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Badge circle
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.achievement.color,
                    widget.achievement.color.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.achievement.color.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _getIconData(widget.achievement.iconName),
                size: 70,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_fire_department':
        return CupertinoIcons.flame_fill;
      case 'whatshot':
        return CupertinoIcons.flame;
      case 'celebration':
        return CupertinoIcons.sparkles;
      case 'diamond':
        return CupertinoIcons.hexagon_fill;
      case 'flag':
        return CupertinoIcons.flag_fill;
      case 'trending_up':
        return CupertinoIcons.graph_circle_fill;
      case 'star':
        return CupertinoIcons.star_fill;
      case 'rocket_launch':
        return CupertinoIcons.rocket_fill;
      case 'emoji_events':
        return CupertinoIcons.shield_fill;
      case 'military_tech':
        return CupertinoIcons.rosette;
      case 'folder':
        return CupertinoIcons.folder_fill;
      case 'folder_open':
        return CupertinoIcons.folder_open;
      case 'account_tree':
        return CupertinoIcons.chart_bar_alt_fill;
      case 'source':
        return CupertinoIcons.doc_on_doc_fill;
      case 'today':
        return CupertinoIcons.calendar_today;
      case 'speed':
        return CupertinoIcons.speedometer;
      case 'flash_on':
        return CupertinoIcons.bolt_fill;
      case 'group':
        return CupertinoIcons.person_2_fill;
      case 'groups':
        return CupertinoIcons.person_3_fill;
      case 'diversity_3':
        return CupertinoIcons.person_3_fill;
      case 'dark_mode':
        return CupertinoIcons.moon_stars_fill;
      case 'wb_sunny':
        return CupertinoIcons.sun_max_fill;
      case 'weekend':
        return CupertinoIcons.calendar;
      case 'translate':
        return CupertinoIcons.textformat_abc;
      default:
        return CupertinoIcons.star_fill;
    }
  }
}

// Confetti particle class
class ConfettiParticle {
  final Color color;
  double x;
  double y;
  final double size;
  final double speedY;
  final double speedX;
  double rotation;
  final double rotationSpeed;

  ConfettiParticle({
    required this.color,
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.rotation,
    required this.rotationSpeed,
  });

  void update() {
    y += speedY * 0.016; // Approximate 60fps
    x += speedX * 0.016;
    rotation += rotationSpeed * 0.016;
  }
}

// Confetti painter
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Update particle position
      particle.update();

      // Don't draw if particle is off screen
      if (particle.y > 1.2) continue;

      final paint = Paint()
        ..color = particle.color.withOpacity(1.0 - progress * 0.5)
        ..style = PaintingStyle.fill;

      final centerX = particle.x * size.width;
      final centerY = particle.y * size.height;

      canvas.save();
      canvas.translate(centerX, centerY);
      canvas.rotate(particle.rotation);

      // Draw confetti rectangle
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size * 1.5,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}