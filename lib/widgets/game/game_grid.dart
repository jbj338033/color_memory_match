import 'package:flutter/material.dart';
import 'game_card.dart';

class GameGrid extends StatelessWidget {
  final List<Color> colors;
  final List<bool> flippedCards;
  final List<bool> matchedCards;
  final Function(int) onCardTap;
  final Animation<double> scaleAnimation;
  final Animation<double> shakeAnimation;

  const GameGrid({
    required this.colors,
    required this.flippedCards,
    required this.matchedCards,
    required this.onCardTap,
    required this.scaleAnimation,
    required this.shakeAnimation,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GameCardShakeEffect(
      shakeAnimation: shakeAnimation,
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) => GameCard(
          color: colors[index],
          isFlipped: flippedCards[index],
          isMatched: matchedCards[index],
          onTap: () => onCardTap(index),
          scaleAnimation: scaleAnimation,
        ),
      ),
    );
  }
}
