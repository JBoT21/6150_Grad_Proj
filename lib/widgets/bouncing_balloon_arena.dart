import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:team_3_f25_project/widgets/balloon_widget.dart';

const double _balloonWidth = 90;
const double _balloonHeight = 110;
const double _speed = 90; // pixels per second

// Bounces each balloon around a fixed arena, reversing direction off the
// walls like a Pong ball. Positions/velocities reset whenever the word
// list changes (i.e. a new round starts).
class BouncingBalloonArena extends StatefulWidget {
  final List<String> words;
  final List<Color> colors;
  final String? poppedWord;
  final String? shakingWord;
  final void Function(String word) onTap;

  const BouncingBalloonArena({
    super.key,
    required this.words,
    required this.colors,
    required this.poppedWord,
    required this.shakingWord,
    required this.onTap,
  });

  @override
  State<BouncingBalloonArena> createState() => _BouncingBalloonArenaState();
}

class _BouncingBalloonArenaState extends State<BouncingBalloonArena>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  Size _arenaSize = Size.zero;

  final List<Offset> _positions = [];
  final List<Offset> _velocities = [];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant BouncingBalloonArena oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.words, widget.words)) {
      _initPositions();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _initPositions() {
    if (_arenaSize == Size.zero) return;
    final maxX = max(_arenaSize.width - _balloonWidth, 0.0);
    final maxY = max(_arenaSize.height - _balloonHeight, 0.0);

    _positions
      ..clear()
      ..addAll(
        widget.words.map(
          (_) => Offset(
            _random.nextDouble() * maxX,
            _random.nextDouble() * maxY,
          ),
        ),
      );

    _velocities
      ..clear()
      ..addAll(
        widget.words.map((_) {
          final angle = _random.nextDouble() * 2 * pi;
          return Offset(cos(angle), sin(angle)) * _speed;
        }),
      );
  }

  void _onTick(Duration elapsed) {
    final dt =
        (elapsed - _lastElapsed).inMicroseconds /
        Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;

    if (dt <= 0 || dt > 0.1 || _positions.length != widget.words.length) {
      return;
    }

    final maxX = max(_arenaSize.width - _balloonWidth, 0.0);
    final maxY = max(_arenaSize.height - _balloonHeight, 0.0);

    for (var i = 0; i < _positions.length; i++) {
      if (widget.words[i] == widget.poppedWord) continue;

      var pos = _positions[i] + _velocities[i] * dt;
      var vel = _velocities[i];

      if (pos.dx <= 0 || pos.dx >= maxX) {
        vel = Offset(-vel.dx, vel.dy);
        pos = Offset(pos.dx.clamp(0, maxX), pos.dy);
      }
      if (pos.dy <= 0 || pos.dy >= maxY) {
        vel = Offset(vel.dx, -vel.dy);
        pos = Offset(pos.dx, pos.dy.clamp(0, maxY));
      }

      _positions[i] = pos;
      _velocities[i] = vel;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (_arenaSize != size) {
          _arenaSize = size;
          if (_positions.isEmpty) _initPositions();
        }

        if (_positions.length != widget.words.length) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: List.generate(widget.words.length, (i) {
            final word = widget.words[i];
            final state = word == widget.poppedWord
                ? BalloonState.popped
                : (word == widget.shakingWord
                      ? BalloonState.shaking
                      : BalloonState.normal);
            return Positioned(
              left: _positions[i].dx,
              top: _positions[i].dy,
              child: Balloon(
                word: word,
                color: widget.colors[i % widget.colors.length],
                state: state,
                onTap: () => widget.onTap(word),
              ),
            );
          }),
        );
      },
    );
  }
}
