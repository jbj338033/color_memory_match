import 'package:flutter/material.dart';
import 'dart:math' show sin;
import '../../utils/theme.dart';

class AchievementNotification extends StatelessWidget {
  final String achievement;

  const AchievementNotification({
    required this.achievement,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildShiningIcon(),
                    const SizedBox(width: 8),
                    _buildText(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShiningIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14,
          child: const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 28,
          ),
        );
      },
    );
  }

  Widget _buildText() {
    return Text(
      'Achievement Unlocked: $achievement',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}

class AchievementOverlay extends StatelessWidget {
  final String achievement;
  final VoidCallback onDismiss;

  const AchievementOverlay({
    required this.achievement,
    required this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimatedIcon(),
                const SizedBox(height: 16),
                Text(
                  'Achievement Unlocked!',
                  style: AppTextStyles.headerMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  achievement,
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onDismiss,
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + sin(value * 3.14 * 2) * 0.1,
          child: Icon(
            Icons.emoji_events,
            size: 64,
            color: AppColors.primary.withOpacity(value),
          ),
        );
      },
    );
  }
}
