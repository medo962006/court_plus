import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A tactile button wrapper that scales down on press with spring physics
/// and triggers haptic feedback. Wraps any child widget.
class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double scaleAmount;
  final bool hapticFeedback;

  const BouncingButton({
    super.key,
    required this.child,
    this.onPressed,
    this.scaleAmount = 0.96,
    this.hapticFeedback = true,
  });

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: widget.scaleAmount,
      upperBound: 1.0,
    )..value = 1.0;
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.fastLinearToSlowEaseIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    if (widget.hapticFeedback) HapticFeedback.lightImpact();
    _controller.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed == null) return;
    _controller.forward();
  }

  void _onTapCancel() {
    if (widget.onPressed == null) return;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// A convenience wrapper for [BouncingButton] that looks like an ElevatedButton.
class BouncingElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double scaleAmount;
  final bool hapticFeedback;

  const BouncingElevatedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.scaleAmount = 0.96,
    this.hapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      scaleAmount: scaleAmount,
      hapticFeedback: hapticFeedback,
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}