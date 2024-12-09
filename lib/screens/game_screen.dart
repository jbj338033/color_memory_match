import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/game_mode.dart';
import '../models/game_stats.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/common/gradient_background.dart';
import '../widgets/game/game_card.dart';
import '../widgets/game/game_grid.dart';
import '../widgets/game/combo_indicator.dart';
import '../widgets/game/achievement_notification.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;

  const GameScreen({
    required this.mode,
    super.key,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Controllers and Animations
  late AnimationController _scaleController;
  late AnimationController _shakeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  // Game State
  final List<List<Color>> _stagePalettes = [
    [
      const Color(0xFFFF6B6B), // Red
      const Color(0xFF4ECDC4), // Cyan
      const Color(0xFFFFBE0B), // Yellow
      const Color(0xFF95E1D3), // Mint
      const Color(0xFFFF70A6), // Pink
      const Color(0xFF70D6FF), // Sky
    ],
    [
      const Color(0xFFE84545),
      const Color(0xFF903749),
      const Color(0xFF53354A),
      const Color(0xFF40514E),
      const Color(0xFF2B2E4A),
      const Color(0xFF84A9AC),
      const Color(0xFFE08E45),
      const Color(0xFF907FA4),
    ],
    [
      const Color(0xFF2D00F7),
      const Color(0xFF6A00F4),
      const Color(0xFF8900F2),
      const Color(0xFFA100F2),
      const Color(0xFFB100E8),
      const Color(0xFFBC00DD),
      const Color(0xFFC500D3),
      const Color(0xFFCE00C8),
      const Color(0xFFD100BD),
      const Color(0xFFDB00B6),
    ],
  ];

  late GameStats _gameStats;
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
  bool _isPaused = false;
  String _currentAchievement = '';
  bool _showAchievement = false;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeGame();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: GameConstants.kCardFlipDuration),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration:
          const Duration(milliseconds: GameConstants.kComboAnimationDuration),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _initializeGame() {
    _gameStats = GameStats();

    switch (widget.mode) {
      case GameMode.story:
        _timeLeft = GameConstants.kStoryModeInitialTime;
        break;
      case GameMode.timeAttack:
        _timeLeft = GameConstants.kTimeAttackInitialTime;
        break;
      case GameMode.zen:
        _timeLeft = -1; // No time limit
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
    _canFlip = true;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
            if (_timeLeft <= 10) {
              _shakeController.forward(from: 0);
            }
          } else {
            _timer?.cancel();
            _showGameOver();
          }
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  // Game Screen 클래스 계속...

  void _onCardTap(int index) {
    if (!_canFlip ||
        _flippedCards[index] ||
        _matchedCards[index] ||
        (_timeLeft == 0 && widget.mode != GameMode.zen)) return;

    _scaleController.forward().then((_) => _scaleController.reverse());

    setState(() {
      _flippedCards[index] = true;

      if (_firstFlippedIndex == null) {
        _firstFlippedIndex = index;
      } else {
        _moves++;
        _canFlip = false;

        if (_gameColors[_firstFlippedIndex!] == _gameColors[index]) {
          _handleMatch(index);
        } else {
          _handleMismatch(index);
        }
      }
    });
  }

  void _handleMatch(int index) {
    _matchedCards[_firstFlippedIndex!] = true;
    _matchedCards[index] = true;
    _combo++;
    _score += GameConstants.kBaseScore * _combo;

    if (_combo > _gameStats.maxCombo) {
      _gameStats.maxCombo = _combo;
      _gameStats.saveStats();
    }

    _canFlip = true;
    _firstFlippedIndex = null;

    _checkAchievement();

    if (_matchedCards.every((matched) => matched)) {
      _handleStageComplete();
    }
  }

  void _handleMismatch(int index) {
    _combo = 0;
    _shakeController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && !_isGameOver) {
        setState(() {
          _flippedCards[_firstFlippedIndex!] = false;
          _flippedCards[index] = false;
          _canFlip = true;
          _firstFlippedIndex = null;
        });
      }
    });
  }

  void _handleStageComplete() {
    if (widget.mode == GameMode.story && _stage < _stagePalettes.length - 1) {
      setState(() {
        _stage++;
        _timeLeft += GameConstants.kBonusTime;
        Future.delayed(const Duration(milliseconds: 500), () {
          _initializeStage();
        });
      });
    } else {
      _timer?.cancel();
      _showGameOver();
    }
  }

  void _checkAchievement() {
    if (_combo >= 5) {
      _unlockAchievement('Combo Master');
    }
    if (_moves == _gameColors.length ~/ 2) {
      _unlockAchievement('Perfect Memory');
    }
  }

  void _unlockAchievement(String title) {
    setState(() {
      _currentAchievement = title;
      _showAchievement = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showAchievement = false);
      }
    });
  }

  void _showGameOver() {
    _isGameOver = true;
    final bool isNewHighScore = _score > _gameStats.highScore;

    if (isNewHighScore) {
      _gameStats.highScore = _score;
      _gameStats.saveStats();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
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
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGameOverHeader(isNewHighScore),
              const SizedBox(height: 24),
              _buildGameOverStats(),
              const SizedBox(height: 32),
              _buildGameOverButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (_) {
        _timer?.cancel();
      },
      child: Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(),
                    if (widget.mode == GameMode.story) _buildStageProgress(),
                    Expanded(
                      child: GameGrid(
                        colors: _gameColors,
                        flippedCards: _flippedCards,
                        matchedCards: _matchedCards,
                        onCardTap: _onCardTap,
                        scaleAnimation: _scaleAnimation,
                        shakeAnimation: _shakeAnimation,
                      ),
                    ),
                    if (_combo > 1) ComboIndicator(combo: _combo),
                    const SizedBox(height: 16),
                  ],
                ),
                if (_showAchievement)
                  AchievementNotification(achievement: _currentAchievement),
                if (_isPaused) _buildPauseOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
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
                Icon(
                  Icons.timer,
                  color: _timeLeft <= 10 ? Colors.red : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_timeLeft',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _timeLeft <= 10 ? Colors.red : Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              const Icon(Icons.stars, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '$_score',
                style: AppTextStyles.bodyLarge,
              ),
            ],
          ),
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: _togglePause,
          ),
        ],
      ),
    );
  }

  Widget _buildStageProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Text(
            'Stage ${_stage + 1}',
            style: AppTextStyles.headerMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_stage + 1) / _stagePalettes.length,
              backgroundColor: AppColors.surface,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PAUSED',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _togglePause,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Resume'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverHeader(bool isNewHighScore) {
    return Column(
      children: [
        const Icon(
          Icons.emoji_events,
          color: AppColors.primary,
          size: 48,
        ),
        const SizedBox(height: 16),
        const Text(
          'Game Over!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        if (isNewHighScore) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.amber,
                width: 1,
              ),
            ),
            child: const Text(
              'New High Score!',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGameOverStats() {
    return Column(
      children: [
        _buildStatRow(Icons.stars, 'Score', _score.toString()),
        const SizedBox(height: 8),
        _buildStatRow(Icons.touch_app, 'Moves', _moves.toString()),
        if (widget.mode == GameMode.story) ...[
          const SizedBox(height: 8),
          _buildStatRow(Icons.flag, 'Stage', '${_stage + 1}'),
        ],
      ],
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop(); // 다이얼로그 닫기
            Navigator.of(context).pop(); // 게임 화면 닫기
          },
          icon: const Icon(Icons.home),
          label: const Text('Main Menu'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {
              _isGameOver = false;
              _score = 0;
              _moves = 0;
              _stage = 0;
              _initializeGame();
            });
          },
          icon: const Icon(Icons.replay),
          label: const Text('Play Again'),
        ),
      ],
    );
  }
}
