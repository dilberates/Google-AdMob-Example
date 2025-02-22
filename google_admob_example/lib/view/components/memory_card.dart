import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/game_provider.dart';

class MemoryCard extends StatelessWidget {
  final int index;

  const MemoryCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final isFlipped = gameProvider.isFlipped[index];
        final isMatched = gameProvider.isMatched[index];
        final color = gameProvider.colors[index];

        return GestureDetector(
          onTap: () => gameProvider.flipCard(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // 3D efekt için perspektif
                ..rotateY(isFlipped ? 3.14 : 0),
              alignment: Alignment.center,
              child: Card(
                elevation: isFlipped || isMatched ? 8 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                color: isFlipped || isMatched ? color : Colors.grey[300],
                child: Center(
                  child: isFlipped || isMatched
                      ? null
                      : Icon(
                          Icons.question_mark_rounded,
                          size: 40,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
