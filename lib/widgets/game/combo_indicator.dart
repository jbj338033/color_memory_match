import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class ComboIndicator extends StatelessWidget {
  final int combo;

  const ComboIndicator({
    required this.combo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.flash_on,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Combo x$combo!',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
