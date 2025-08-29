import 'package:flutter/material.dart';

class AnimatedMoodIcon extends StatefulWidget {
  final int score;
  final double size;

  const AnimatedMoodIcon({
    Key? key,
    required this.score,
    this.size = 60,
  }) : super(key: key);

  @override
  _AnimatedMoodIconState createState() => _AnimatedMoodIconState();
}

class _AnimatedMoodIconState extends State<AnimatedMoodIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIconForScore(int score) {
    if (score >= 80) return Icons.sentiment_very_satisfied;
    if (score >= 60) return Icons.sentiment_satisfied;
    if (score >= 40) return Icons.sentiment_neutral;
    if (score >= 20) return Icons.sentiment_dissatisfied;
    return Icons.sentiment_very_dissatisfied;
  }

  Color _getColorForScore(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    if (score >= 20) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconForScore(widget.score);
    final color = _getColorForScore(widget.score);

    return ScaleTransition(
      scale: _animation,
      child: Icon(
        icon,
        size: widget.size,
        color: color,
      ),
    );
  }
}
