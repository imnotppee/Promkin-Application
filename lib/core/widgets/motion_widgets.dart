import 'package:flutter/material.dart';

/// A small entrance transition for content panels. Rebuilds do not replay it.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset startOffset;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 360),
    this.startOffset = const Offset(0, .035),
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _show());
    } else {
      Future<void>.delayed(widget.delay, _show);
    }
  }

  void _show() {
    if (mounted) setState(() => _visible = true);
  }

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: _visible ? 1 : 0,
    duration: widget.duration,
    curve: Curves.easeOutCubic,
    child: AnimatedSlide(
      offset: _visible ? Offset.zero : widget.startOffset,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: widget.child,
    ),
  );
}

/// Adds the short press scale and ripple used by the Stitch prototypes.
class AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final Color? splashColor;

  const AnimatedPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.splashColor,
  });

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: _pressed ? .975 : 1,
    duration: const Duration(milliseconds: 110),
    curve: Curves.easeOut,
    child: Material(
      color: Colors.transparent,
      borderRadius: widget.borderRadius,
      child: InkWell(
        borderRadius: widget.borderRadius,
        splashColor: widget.splashColor,
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: widget.child,
      ),
    ),
  );
}
