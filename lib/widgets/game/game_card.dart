import 'package:flutter/material.dart';
import 'dart:math' show pi, sin;
import '../../utils/theme.dart';

class GameCard extends StatelessWidget {
  final Color color;
  final bool isFlipped;
  final bool isMatched;
  final VoidCallback onTap;
  final Animation<double> scaleAnimation;

  const GameCard({
    required this.color,
    required this.isFlipped,
    required this.isMatched,
    required this.onTap,
    required this.scaleAnimation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                color: isMatched ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: _buildCardContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isFlipped || isMatched ? color : AppColors.surface,
            isFlipped || isMatched
                ? color.withOpacity(0.8)
                : AppColors.background,
          ],
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateY(isFlipped || isMatched ? pi : 0),
        transformAlignment: Alignment.center,
        child: Center(
          child: isFlipped || isMatched
              ? null
              : Icon(
                  Icons.pattern,
                  size: 30,
                  color: Colors.white.withOpacity(0.5),
                ),
        ),
      ),
    );
  }
}

class GameCardShakeEffect extends StatelessWidget {
  final Widget child;
  final Animation<double> shakeAnimation;

  const GameCardShakeEffect({
    required this.child,
    required this.shakeAnimation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            sin(shakeAnimation.value * pi * 20) * 5,
            0,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}
