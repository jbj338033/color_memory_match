import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum GameMode { story, timeAttack, zen }

class GameModeData {
  final GameMode mode;
  final String title;
  final IconData icon;
  final String description;
  final Color color;
  final int requirement;

  const GameModeData({
    required this.mode,
    required this.title,
    required this.icon,
    required this.description,
    required this.color,
    required this.requirement,
  });

  static final List<GameModeData> allModes = [
    const GameModeData(
      mode: GameMode.story,
      title: AppStrings.storyMode,
      icon: Icons.auto_stories,
      description: 'Progress through challenging stages',
      color: Color(0xFFFF6B6B),
      requirement: 0,
    ),
    const GameModeData(
      mode: GameMode.timeAttack,
      title: AppStrings.timeAttack,
      icon: Icons.timer,
      description: 'Race against the clock',
      color: Color(0xFF4ECDC4),
      requirement: GameConstants.kTimeAttackUnlockScore,
    ),
    const GameModeData(
      mode: GameMode.zen,
      title: AppStrings.zenMode,
      icon: Icons.spa,
      description: 'Practice at your own pace',
      color: Color(0xFFFFBE0B),
      requirement: GameConstants.kZenModeUnlockScore,
    ),
  ];
}
