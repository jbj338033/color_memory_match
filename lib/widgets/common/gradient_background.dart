import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({
    required this.child,
    this.colors,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ??
              [
                AppColors.background,
                AppColors.cardBackground,
              ],
        ),
      ),
      child: child,
    );
  }
}
