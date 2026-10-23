import 'package:flutter/material.dart';
import 'package:scupporo_crew_app/utils/constants/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final bool showDecorativeCircles;

  const AppBackground({
    super.key,
    required this.child,
    this.showDecorativeCircles = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!showDecorativeCircles) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppColors.appBackgroundDecoration,
        child: child,
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: AppColors.appBackgroundDecoration,
      child: Stack(
        children: [
          // Soft Glow - Top Left
          Positioned(
            top: -100,
            left: -100,
            child: _glowCircle(
              size: 330,
              color: const Color(0xFFE4DFFF),
              opacity: 0.55,
            ),
          ),

          // Soft Glow - Top Right
          Positioned(
            top: 80,
            right: -130,
            child: _glowCircle(
              size: 350,
              color: const Color(0xFFC9E6FF),
              opacity: 0.55,
            ),
          ),

          // Soft Glow - Center
          Positioned(
            top: 350,
            left: -120,
            child: _glowCircle(
              size: 300,
              color: const Color(0xFFFFD9D0),
              opacity: 0.45,
            ),
          ),

          // Main Screen Content
          child,
        ],
      ),
    );
  }

  Widget _glowCircle({
    required double size,
    required Color color,
    required double opacity,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity * 0.7),
            blurRadius: 80,
            spreadRadius: 30,
          ),
        ],
      ),
    );
  }
}
