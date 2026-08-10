import 'package:flutter/material.dart';

/// An integer that animates from 0 to [target] using [TweenAnimationBuilder].
class AnimatedCount extends StatelessWidget {
  final int target;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCount({
    super.key,
    required this.target,
    this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: target.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          value.floor().toString(),
          style: style,
        );
      },
    );
  }
}

/// A checkmark that scales up with a bounce on screen entry.
class CheckmarkAnimation extends StatefulWidget {
  final double size;
  final Color color;

  const CheckmarkAnimation({
    super.key,
    this.size = 80,
    this.color = const Color(0xFFC4FF00),
  });

  @override
  State<CheckmarkAnimation> createState() => _CheckmarkAnimationState();
}

class _CheckmarkAnimationState extends State<CheckmarkAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check, size: widget.size * 0.6, color: Colors.black),
      ),
    );
  }
}

/// A floating/bobbing widget for empty states.
class FloatingEmptyState extends StatefulWidget {
  final IconData icon;
  final String message;
  final String? subtitle;

  const FloatingEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.subtitle,
  });

  @override
  State<FloatingEmptyState> createState() => _FloatingEmptyStateState();
}

class _FloatingEmptyStateState extends State<FloatingEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _float = Tween(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _float.value),
        child: child,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            widget.message,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.subtitle!,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}