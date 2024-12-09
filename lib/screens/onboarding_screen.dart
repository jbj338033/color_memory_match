import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/common/gradient_background.dart';
import '../utils/theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Welcome to Color Memory',
      description: 'Train your memory with this exciting color matching game!',
      icon: Icons.games,
      color: const Color(0xFFFF6B6B),
    ),
    OnboardingData(
      title: 'Multiple Game Modes',
      description: 'Choose from Story Mode, Time Attack, or Zen Mode',
      icon: Icons.extension,
      color: const Color(0xFF4ECDC4),
    ),
    OnboardingData(
      title: 'Track Your Progress',
      description: 'Earn achievements and compete for high scores!',
      icon: Icons.emoji_events,
      color: const Color(0xFFFFBE0B),
    ),
  ];

  Future<void> _finishOnboarding() async {
    await StorageService().setHasSeenIntro(true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) => OnboardingPage(
                    data: _pages[index],
                  ),
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPageIndicator(),
          const SizedBox(height: 32),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Theme.of(context).primaryColor
                : Colors.white.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentPage > 0)
          TextButton(
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Text('Back'),
          )
        else
          const SizedBox.shrink(),
        ElevatedButton(
          onPressed: _currentPage == _pages.length - 1
              ? _finishOnboarding
              : () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
          child: Text(
            _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
          ),
        ),
      ],
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({
    required this.data,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(height: 40),
          _buildTitle(),
          const SizedBox(height: 20),
          _buildDescription(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: data.color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              data.icon,
              size: 60,
              color: data.color,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Text(
      data.title,
      style: AppTextStyles.headerMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Text(
      data.description,
      style: AppTextStyles.bodyMedium.copyWith(
        color: Colors.white.withOpacity(0.8),
      ),
      textAlign: TextAlign.center,
    );
  }
}
