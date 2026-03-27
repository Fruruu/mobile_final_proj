import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

class AuthGradientBackdrop extends StatelessWidget {
  const AuthGradientBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          top: -170,
          left: -150,
          child: _GradientCircle(
            size: 380,
            colors: [Color(0x66FF6169), Color(0x40FFD5D8), Color(0x00FFFFFF)],
          ),
        ),
        Positioned(
          top: 220,
          right: -140,
          child: _GradientCircle(
            size: 330,
            colors: [Color(0x664EC1F5), Color(0x33DBF3FF), Color(0x00FFFFFF)],
          ),
        ),
        Positioned(
          bottom: -130,
          left: -90,
          child: _GradientCircle(
            size: 280,
            colors: [Color(0x66FFDE71), Color(0x33FFF3CF), Color(0x00FFFFFF)],
          ),
        ),
      ],
    );
  }
}

class _GradientCircle extends StatelessWidget {
  const _GradientCircle({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors, stops: const [0, 0.55, 1]),
      ),
    );
  }
}

class AnimatedMoodPathLogo extends StatefulWidget {
  const AnimatedMoodPathLogo({
    super.key,
    this.size = 74,
    this.iconSize = 64,
    this.interval = const Duration(milliseconds: 1200),
    this.animate = true,
  });

  final double size;
  final double iconSize;
  final Duration interval;
  final bool animate;

  @override
  State<AnimatedMoodPathLogo> createState() => _AnimatedMoodPathLogoState();
}

class _AnimatedMoodPathLogoState extends State<AnimatedMoodPathLogo> {
  static const List<String> _logos = [
    'assets/logos/very-happy-face.svg',
    'assets/logos/happy-face.svg',
    'assets/logos/neutral-face.svg',
    'assets/logos/sad-face.svg',
    'assets/logos/very-sad-face.svg',
  ];

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!widget.animate) {
      return;
    }

    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted || _logos.isEmpty) {
        return;
      }
      setState(() {
        _index = (_index + 1) % _logos.length;
      });
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedMoodPathLogo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animate == widget.animate &&
        oldWidget.interval == widget.interval) {
      return;
    }

    _timer?.cancel();
    _timer = null;

    if (!widget.animate) {
      return;
    }

    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted || _logos.isEmpty) {
        return;
      }
      setState(() {
        _index = (_index + 1) % _logos.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_logos.isEmpty) {
      return const SizedBox.shrink();
    }

    final safeIndex = _index % _logos.length;
    final currentLogo = _logos[safeIndex];

    final logoWidget = SvgPicture.asset(
      currentLogo,
      key: ValueKey<String>(currentLogo),
      width: widget.iconSize,
      height: widget.iconSize,
      fit: BoxFit.contain,
    );

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Center(
        child: widget.animate
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: logoWidget,
              )
            : logoWidget,
      ),
    );
  }
}
