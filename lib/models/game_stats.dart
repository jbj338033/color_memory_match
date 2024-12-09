import 'achievement.dart';
import '../services/storage_service.dart';

class GameStats {
  int highScore;
  int totalGamesPlayed;
  int maxCombo;
  List<Achievement> achievements;

  GameStats({
    this.highScore = 0,
    this.totalGamesPlayed = 0,
    this.maxCombo = 0,
    List<Achievement>? achievements,
  }) : achievements = achievements ?? Achievement.defaultAchievements;

  Future<void> saveStats() async {
    final storage = StorageService();
    await storage.setHighScore(highScore);
    await storage.setTotalGames(totalGamesPlayed);
    await storage.setMaxCombo(maxCombo);

    for (var i = 0; i < achievements.length; i++) {
      await storage.setAchievementUnlocked(i, achievements[i].unlocked);
    }
  }

  Future<void> loadStats() async {
    final storage = StorageService();
    highScore = storage.getHighScore();
    totalGamesPlayed = storage.getTotalGames();
    maxCombo = storage.getMaxCombo();

    for (var i = 0; i < achievements.length; i++) {
      achievements[i].unlocked = storage.isAchievementUnlocked(i);
    }
  }

  void updateHighScore(int newScore) {
    if (newScore > highScore) {
      highScore = newScore;
      saveStats();
    }
  }

  void incrementGamesPlayed() {
    totalGamesPlayed++;
    saveStats();
  }

  void updateMaxCombo(int newCombo) {
    if (newCombo > maxCombo) {
      maxCombo = newCombo;
      saveStats();
    }
  }

  Achievement? checkForNewAchievement(int score, int combo, int timeLeft) {
    for (var achievement in achievements) {
      if (!achievement.unlocked) {
        if (_hasMetRequirement(achievement, score, combo, timeLeft)) {
          achievement.unlocked = true;
          saveStats();
          return achievement;
        }
      }
    }
    return null;
  }

  bool _hasMetRequirement(
      Achievement achievement, int score, int combo, int timeLeft) {
    switch (achievement.title) {
      case 'High Scorer':
        return score >= achievement.requirement;
      case 'Combo Master':
        return combo >= achievement.requirement;
      case 'Speed Demon':
        return timeLeft >= achievement.requirement;
      case 'Perfect Memory':
        return true; // This is checked separately in game logic
      default:
        return false;
    }
  }
}
