import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_colors.dart';

/// Glass morphism card with backdrop blur effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? color;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.width,
    this.height,
    this.color,
    this.borderRadius,
    this.blur = 10.0,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark 
        ? AppColors.glassSurfaceDark.withOpacity(opacity)
        : AppColors.glassSurfaceLight.withOpacity(opacity);

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? defaultColor,
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            border: Border.all(
              color: isDark 
                  ? AppColors.glassBorderDark 
                  : AppColors.glassBorderLight,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Glass morphism button with gradient and blur effect
class GlassButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final Color? color;
  final double? width;
  final double? height;

  const GlassButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isPrimary = false,
    this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    final buttonColor = color ?? AppColors.accentBlue;

    if (isPrimary) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: width,
            height: height ?? 56,
            decoration: BoxDecoration(
              gradient: isDisabled
                  ? LinearGradient(
                      colors: [
                        Colors.grey.withOpacity(0.5),
                        Colors.grey.withOpacity(0.3),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        buttonColor,
                        buttonColor.withOpacity(0.8),
                      ],
                    ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: isDisabled
                  ? []
                  : [
                      BoxShadow(
                        color: buttonColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.41,
                        ),
                      ),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Secondary button style
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: width,
            height: height ?? 56,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: buttonColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: buttonColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.41,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass morphism container with custom child
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.5,
    this.borderRadius,
    this.color,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? 
                  (isDark 
                      ? Colors.white.withOpacity(opacity * 0.1)
                      : Colors.white.withOpacity(opacity)),
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}