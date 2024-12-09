import 'package:flutter/material.dart';
import '../../models/game_mode.dart';
import '../../models/game_stats.dart';
import '../../utils/theme.dart';
import '../../screens/game_screen.dart';

class GameModeCard extends StatefulWidget {
  final GameModeData data;
  final GameStats stats;

  const GameModeCard({
    required this.data,
    required this.stats,
    super.key,
  });

  @override
  State<GameModeCard> createState() => _GameModeCardState();
}

class _GameModeCardState extends State<GameModeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  bool get _isUnlocked => widget.stats.highScore >= widget.data.requirement;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    if (_isUnlocked) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isUnlocked) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isUnlocked) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _startGame(BuildContext context) {
    if (_isUnlocked) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              GameScreen(mode: widget.data.mode),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      _showLockedDialog(context);
    }
  }

  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Mode Locked'),
        content: Text(
          'Reach ${widget.data.requirement} points in Story Mode to unlock this mode!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: () => _startGame(context),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildCard(),
          );
        },
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _isUnlocked
                ? widget.data.color.withOpacity(0.8)
                : Colors.grey.withOpacity(0.5),
            _isUnlocked ? widget.data.color : Colors.grey,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_isUnlocked ? widget.data.color : Colors.grey)
                .withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            _buildCardContent(),
            if (!_isUnlocked) _buildLockedOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextContent(),
          ),
          Icon(
            _isUnlocked ? Icons.arrow_forward_ios : Icons.lock,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        widget.data.icon,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.data.title,
          style: AppTextStyles.bodyLarge,
        ),
        const SizedBox(height: 4),
        Text(
          widget.data.description,
          style: AppTextStyles.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLockedOverlay() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Text(
        'Score ${widget.data.requirement} to unlock',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
      ),
    );
  }
}
