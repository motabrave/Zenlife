import 'package:flutter/material.dart';

class ScoreGauge extends StatelessWidget {
  final int score;
  final double size;

  const ScoreGauge({super.key, required this.score, this.size = 180});

  @override
  Widget build(BuildContext context) {
    final value = (score.clamp(0, 100)) / 100.0;
    final Color start = Colors.redAccent;
    final Color mid = Colors.amber;
    final Color end = Colors.green;

    Color lerp(double t) {
      if (t < 0.5) {
        return Color.lerp(start, mid, t * 2)!;
      } else {
        return Color.lerp(mid, end, (t - 0.5) * 2)!;
      }
    }

    final ringColor = lerp(value);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: v,
                  strokeWidth: 14,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(lerp(v)),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${(v * 100).round()}",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    "/100",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
