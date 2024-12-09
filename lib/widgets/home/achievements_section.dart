import 'package:flutter/material.dart';
import '../../models/achievement.dart';
import '../../utils/theme.dart';

class AchievementsSection extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsSection({
    required this.achievements,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Achievements',
            style: AppTextStyles.headerMedium,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            itemBuilder: (context, index) => AchievementCard(
              achievement: achievements[index],
            ),
          ),
        ),
      ],
    );
  }
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({
    required this.achievement,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        color: achievement.unlocked
            ? AppColors.primary.withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: achievement.unlocked
                ? AppColors.primary
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => _showAchievementDetails(context),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  achievement.unlocked ? Icons.emoji_events : Icons.lock,
                  color: achievement.unlocked
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.3),
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: achievement.unlocked
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAchievementDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                achievement.unlocked ? Icons.emoji_events : Icons.lock,
                color: achievement.unlocked
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.3),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                achievement.title,
                style: AppTextStyles.headerMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                achievement.description,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
