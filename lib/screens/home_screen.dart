import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../models/game_stats.dart';
import '../services/storage_service.dart';
import '../widgets/common/gradient_background.dart';
import '../widgets/home/game_mode_card.dart';
import '../widgets/home/stats_section.dart';
import '../widgets/home/achievements_section.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late GameStats _gameStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadStats();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _loadStats() async {
    _gameStats = GameStats();
    await _gameStats.loadStats();
    setState(() => _isLoading = false);
    _controller.forward();
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 30),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: AppTextStyles.headerLarge,
              ),
              Text(
                AppStrings.tagline,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 28),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          );
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Text(
                'Game Modes',
                style: AppTextStyles.headerMedium,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: GameModeData.allModes
                      .map(
                        (mode) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GameModeCard(
                            data: mode,
                            stats: _gameStats,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              StatsSection(stats: _gameStats),
              const SizedBox(height: 20),
              AchievementsSection(achievements: _gameStats.achievements),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  double _musicVolume = 0.7;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = StorageService();
    setState(() {
      _soundEnabled = storage.getSoundEnabled();
      _vibrationEnabled = storage.getVibrationEnabled();
      _musicVolume = storage.getMusicVolume();
    });
  }

  Future<void> _saveSettings() async {
    final storage = StorageService();
    await storage.setSoundEnabled(_soundEnabled);
    await storage.setVibrationEnabled(_vibrationEnabled);
    await storage.setMusicVolume(_musicVolume);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
            Text(
              'Settings',
              style: AppTextStyles.headerMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            _buildSettingsList(),
            const SizedBox(height: 16),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Sound Effects'),
          value: _soundEnabled,
          onChanged: (value) => setState(() => _soundEnabled = value),
          activeColor: AppColors.primary,
        ),
        SwitchListTile(
          title: const Text('Vibration'),
          value: _vibrationEnabled,
          onChanged: (value) => setState(() => _vibrationEnabled = value),
          activeColor: AppColors.primary,
        ),
        ListTile(
          title: const Text('Music Volume'),
          subtitle: Slider(
            value: _musicVolume,
            onChanged: (value) => setState(() => _musicVolume = value),
            activeColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            _saveSettings();
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
