import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  // Settings keys
  static const String _soundEnabledKey = 'soundEnabled';
  static const String _vibrationEnabledKey = 'vibrationEnabled';
  static const String _musicVolumeKey = 'musicVolume';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Game Stats Methods
  Future<void> setHighScore(int score) async {
    await _prefs.setInt(GameConstants.kHighScoreKey, score);
  }

  int getHighScore() {
    return _prefs.getInt(GameConstants.kHighScoreKey) ?? 0;
  }

  Future<void> setTotalGames(int total) async {
    await _prefs.setInt(GameConstants.kTotalGamesKey, total);
  }

  int getTotalGames() {
    return _prefs.getInt(GameConstants.kTotalGamesKey) ?? 0;
  }

  Future<void> setMaxCombo(int combo) async {
    await _prefs.setInt(GameConstants.kMaxComboKey, combo);
  }

  int getMaxCombo() {
    return _prefs.getInt(GameConstants.kMaxComboKey) ?? 0;
  }

  // Settings Methods
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_soundEnabledKey, enabled);
  }

  bool getSoundEnabled() {
    return _prefs.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    await _prefs.setBool(_vibrationEnabledKey, enabled);
  }

  bool getVibrationEnabled() {
    return _prefs.getBool(_vibrationEnabledKey) ?? true;
  }

  Future<void> setMusicVolume(double volume) async {
    await _prefs.setDouble(_musicVolumeKey, volume);
  }

  double getMusicVolume() {
    return _prefs.getDouble(_musicVolumeKey) ?? 0.7;
  }

  // Tutorial Methods
  Future<void> setHasSeenIntro(bool seen) async {
    await _prefs.setBool(GameConstants.kHasSeenIntroKey, seen);
  }

  bool hasSeenIntro() {
    return _prefs.getBool(GameConstants.kHasSeenIntroKey) ?? false;
  }

  // Achievement Methods
  Future<void> setAchievementUnlocked(int index, bool unlocked) async {
    await _prefs.setBool('${GameConstants.kAchievementPrefix}$index', unlocked);
  }

  bool isAchievementUnlocked(int index) {
    return _prefs.getBool('${GameConstants.kAchievementPrefix}$index') ?? false;
  }

  // Clear all data
  Future<void> clear() async {
    await _prefs.clear();
  }
}
