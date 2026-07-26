import 'package:flutter/material.dart';

enum BalloonState { normal, shaking, popped }

// Movement is driven externally (see BouncingBalloonArena) so this widget
// only renders the visual + the shake/pop reactions to a tap.
class Balloon extends StatelessWidget {
  final String word;
  final Color color;
  final BalloonState state;
  final VoidCallback onTap;

  const Balloon({
    super.key,
    required this.word,
    required this.color,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final balloon = GestureDetector(
      onTap: state == BalloonState.popped ? null : onTap,
      child: Container(
        width: 90,
        height: 110,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .15),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        child: Text(
          word,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );

    switch (state) {
      case BalloonState.popped:
        return AnimatedScale(
          scale: 0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedOpacity(
            opacity: 0,
            duration: const Duration(milliseconds: 300),
            child: balloon,
          ),
        );
      case BalloonState.shaking:
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: -1, end: 1),
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticIn,
          builder: (context, value, child) =>
              Transform.rotate(angle: value * 0.1, child: child),
          child: balloon,
        );
      case BalloonState.normal:
        return balloon;
    }
  }
}
