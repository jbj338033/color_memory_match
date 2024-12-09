import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Memory Match',
      theme: ThemeData(
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF6C63FF),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Color\nMemory',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              MenuButton(
                title: 'Story Mode',
                icon: Icons.auto_stories,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const GameScreen(mode: GameMode.story),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              MenuButton(
                title: 'Time Attack',
                icon: Icons.timer,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const GameScreen(mode: GameMode.timeAttack),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              MenuButton(
                title: 'Zen Mode',
                icon: Icons.spa,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameScreen(mode: GameMode.zen),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const MenuButton({
    required this.title,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF6C63FF)),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum GameMode { story, timeAttack, zen }

class GameScreen extends StatefulWidget {
  final GameMode mode;

  const GameScreen({required this.mode, super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int kBonusTime = 30;
  static const int kStoryModeInitialTime = 120;
  static const int kTimeAttackInitialTime = 60;
  static const int kBaseScore = 10;
  static const int kPerfectBonus = 50;

  final List<List<Color>> _stagePalettes = const [
    [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ],
    [
      Color(0xFFFF6B6B),
      Color(0xFF4ECDC4),
      Color(0xFFFFBE0B),
      Color(0xFF95E1D3),
      Color(0xFFFF70A6),
      Color(0xFF70D6FF),
      Color(0xFFB5FF7D),
      Color(0xFFE7C6FF),
    ],
    [
      Color(0xFF2D00F7),
      Color(0xFF6A00F4),
      Color(0xFF8900F2),
      Color(0xFFA100F2),
      Color(0xFFB100E8),
      Color(0xFFBC00DD),
      Color(0xFFC500D3),
      Color(0xFFCE00C8),
      Color(0xFFD100BD),
      Color(0xFFDB00B6),
    ],
  ];

  late final GameStats _gameStats;
  late List<Color> _gameColors;
  late List<bool> _flippedCards;
  late List<bool> _matchedCards;
  int _score = 0;
  int _moves = 0;
  int _stage = 0;
  int? _firstFlippedIndex;
  bool _canFlip = true;
  Timer? _timer;
  int _timeLeft = 0;
  int _combo = 0;
  final bool _isPaused = false;
  bool _isFirstGame = true;

  @override
  void initState() {
    super.initState();
    _gameStats = GameStats();
    _loadGameStats();
    _initializeGame();
    _showTutorialIfFirstTime();
  }

  Future<void> _loadGameStats() async {
    await _gameStats.loadStats();
  }

  void _showTutorialIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('hasSeenTutorial') ?? false;

    if (!hasSeenTutorial && _isFirstGame) {
      _isFirstGame = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => TutorialOverlay(
            onSkip: () async {
              await prefs.setBool('hasSeenTutorial', true);
              Navigator.pop(context);
            },
          ),
        );
      });
    }
  }

  void _initializeGame() {
    switch (widget.mode) {
      case GameMode.story:
        _timeLeft = kStoryModeInitialTime;
        break;
      case GameMode.timeAttack:
        _timeLeft = kTimeAttackInitialTime;
        break;
      case GameMode.zen:
        _timeLeft = -1;
        break;
    }
    _initializeStage();
    if (_timeLeft > 0) {
      _startTimer();
    }
  }

  void _initializeStage() {
    final colors = _stagePalettes[_stage];
    _gameColors = [...colors, ...colors];
    _gameColors.shuffle(Random());
    _flippedCards = List.generate(_gameColors.length, (_) => false);
    _matchedCards = List.generate(_gameColors.length, (_) => false);
    _firstFlippedIndex = null;
    _combo = 0;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _timer?.cancel();
            _checkForAchievements();
            _showGameOver();
          }
        });
      }
    });
  }

  void _checkForAchievements() {
    if (_combo >= 5) {
      _gameStats.achievements[1].unlocked = true;
    }
    if (_moves == _gameColors.length ~/ 2) {
      _gameStats.achievements[3].unlocked = true;
    }
    _gameStats.saveStats();
  }

  void _showGameOver() {
    final bool isNewHighScore = _score > _gameStats.highScore;
    if (isNewHighScore) {
      _gameStats.highScore = _score;
      _gameStats.saveStats();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        title: Column(
          children: [
            const Text(
              'Game Over!',
              style: TextStyle(color: Color(0xFF6C63FF)),
              textAlign: TextAlign.center,
            ),
            if (isNewHighScore)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'New High Score!',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 18,
                  ),
                ),
              ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $_score',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            Text(
              'Moves: $_moves',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            if (widget.mode == GameMode.story)
              Text(
                'Stage: ${_stage + 1}',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Main Menu'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _score = 0;
                _moves = 0;
                _stage = 0;
                _initializeGame();
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _onCardTap(int index) {
    if (!_canFlip ||
        _flippedCards[index] ||
        _matchedCards[index] ||
        (_timeLeft == 0 && widget.mode != GameMode.zen)) return;

    setState(() {
      _flippedCards[index] = true;

      if (_firstFlippedIndex == null) {
        _firstFlippedIndex = index;
      } else {
        _moves++;
        _canFlip = false;

        if (_gameColors[_firstFlippedIndex!] == _gameColors[index]) {
          _matchedCards[_firstFlippedIndex!] = true;
          _matchedCards[index] = true;
          _combo++;
          _score += kBaseScore * _combo;

          if (_combo > _gameStats.maxCombo) {
            _gameStats.maxCombo = _combo;
            _gameStats.saveStats();
          }

          _canFlip = true;
          _firstFlippedIndex = null;

          if (_matchedCards.every((matched) => matched)) {
            if (_moves == _gameColors.length ~/ 2) {
              _score += kPerfectBonus;
            }

            if (widget.mode == GameMode.story &&
                _stage < _stagePalettes.length - 1) {
              _stage++;
              _timeLeft += kBonusTime;
              _initializeStage();
            } else {
              _timer?.cancel();
              _checkForAchievements();
              _showGameOver();
            }
          }
        } else {
          _combo = 0;
          Timer(const Duration(milliseconds: 1000), () {
            setState(() {
              _flippedCards[_firstFlippedIndex!] = false;
              _flippedCards[index] = false;
              _canFlip = true;
              _firstFlippedIndex = null;
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _timer?.cancel();
        return true;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          _timer?.cancel();
                          Navigator.pop(context);
                        },
                      ),
                      Row(
                        children: [
                          if (_timeLeft >= 0) ...[
                            const Icon(Icons.timer, color: Color(0xFF6C63FF)),
                            const SizedBox(width: 8),
                            Text(
                              '$_timeLeft',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          const Icon(Icons.stars, color: Color(0xFF6C63FF)),
                          const SizedBox(width: 8),
                          Text(
                            '$_score',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.mode == GameMode.story)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Stage ${_stage + 1}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                    ),
                    itemCount: _gameColors.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _onCardTap(index),
                        child: Card(
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                              color: _matchedCards[index]
                                  ? const Color(0xFF6C63FF)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _flippedCards[index] || _matchedCards[index]
                                      ? _gameColors[index]
                                      : const Color(0xFF2A2A4A),
                                  _flippedCards[index] || _matchedCards[index]
                                      ? _gameColors[index].withOpacity(0.8)
                                      : const Color(0xFF1A1A2E),
                                ],
                              ),
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              transform: Matrix4.rotationY(
                                _flippedCards[index] || _matchedCards[index]
                                    ? pi
                                    : 0,
                              ),
                              child: Center(
                                child: _flippedCards[index] ||
                                        _matchedCards[index]
                                    ? null
                                    : Icon(
                                        Icons.pattern,
                                        size: 30,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_combo > 1)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF6C63FF),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'Combo x$_combo!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        floatingActionButton: widget.mode != GameMode.zen
            ? null
            : FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _initializeStage();
                  });
                },
                backgroundColor: const Color(0xFF6C63FF),
                child: const Icon(Icons.refresh),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class Achievement {
  final String title;
  final String description;
  final int requirement;
  bool unlocked;

  Achievement({
    required this.title,
    required this.description,
    required this.requirement,
    this.unlocked = false,
  });
}

class GameStats {
  int highScore = 0;
  int totalGamesPlayed = 0;
  int maxCombo = 0;
  List<Achievement> achievements = [
    Achievement(
      title: 'First Steps',
      description: 'Complete your first game',
      requirement: 1,
    ),
    Achievement(
      title: 'Combo Master',
      description: 'Achieve a 5x combo',
      requirement: 5,
    ),
    Achievement(
      title: 'Speed Demon',
      description: 'Complete a stage in under 30 seconds',
      requirement: 30,
    ),
    Achievement(
      title: 'Perfect Memory',
      description: 'Complete a stage without any mistakes',
      requirement: 1,
    ),
  ];

  Future<void> saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', highScore);
    await prefs.setInt('totalGamesPlayed', totalGamesPlayed);
    await prefs.setInt('maxCombo', maxCombo);

    for (var i = 0; i < achievements.length; i++) {
      await prefs.setBool('achievement_$i', achievements[i].unlocked);
    }
  }

  Future<void> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('highScore') ?? 0;
    totalGamesPlayed = prefs.getInt('totalGamesPlayed') ?? 0;
    maxCombo = prefs.getInt('maxCombo') ?? 0;

    for (var i = 0; i < achievements.length; i++) {
      achievements[i].unlocked = prefs.getBool('achievement_$i') ?? false;
    }
  }
}

class TutorialOverlay extends StatelessWidget {
  final VoidCallback onSkip;

  const TutorialOverlay({required this.onSkip, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'How to Play',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              '1. Tap cards to flip them\n'
              '2. Find matching color pairs\n'
              '3. Build combos for bonus points\n'
              '4. Complete stages before time runs out',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: onSkip,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Got it!',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
