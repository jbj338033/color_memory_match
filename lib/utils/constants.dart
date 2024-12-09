class GameConstants {
  // Time settings
  static const int kBonusTime = 30;
  static const int kStoryModeInitialTime = 120;
  static const int kTimeAttackInitialTime = 60;

  // Score settings
  static const int kBaseScore = 10;
  static const int kPerfectBonus = 50;
  static const int kTimeAttackUnlockScore = 5000;
  static const int kZenModeUnlockScore = 10000;

  // Animation durations
  static const int kCardFlipDuration = 300;
  static const int kComboAnimationDuration = 500;
  static const int kScreenTransitionDuration = 800;

  // Storage keys
  static const String kHighScoreKey = 'highScore';
  static const String kTotalGamesKey = 'totalGames';
  static const String kMaxComboKey = 'maxCombo';
  static const String kHasSeenIntroKey = 'hasSeenIntro';
  static const String kAchievementPrefix = 'achievement_';
}

class AppStrings {
  static const String appName = 'Color Memory Match';
  static const String tagline = 'Train your memory';

  // Game modes
  static const String storyMode = 'Story Mode';
  static const String timeAttack = 'Time Attack';
  static const String zenMode = 'Zen Mode';

  // Messages
  static const String gameOver = 'Game Over!';
  static const String newHighScore = 'New High Score!';
  static const String pausedMessage = 'PAUSED';
}
