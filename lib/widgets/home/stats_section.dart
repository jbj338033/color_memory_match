import 'package:flutter/material.dart';
import '../../models/game_stats.dart';
import '../../utils/theme.dart';

class StatsSection extends StatelessWidget {
  final GameStats stats;

  const StatsSection({
    required this.stats,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            Icons.emoji_events,
            stats.highScore.toString(),
            'High Score',
          ),
          _buildDivider(),
          _buildStatItem(
            context,
            Icons.speed,
            stats.maxCombo.toString(),
            'Best Combo',
          ),
          _buildDivider(),
          _buildStatItem(
            context,
            Icons.games,
            stats.totalGamesPlayed.toString(),
            'Games Played',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.bodyLarge,
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.1),
    );
  }
}
