import 'package:flutter/material.dart';
import 'dart:async';

class AnimatedTextList extends StatefulWidget {
  final List<String> texts;
  final Duration duration;

  const AnimatedTextList({
    super.key,
    required this.texts,
    this.duration = const Duration(seconds: 2),
  });

  @override
  _AnimatedTextListState createState() => _AnimatedTextListState();
}

class _AnimatedTextListState extends State<AnimatedTextList> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    if (widget.texts.isEmpty) return; // Prevents division by zero

    _timer = Timer.periodic(widget.duration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.texts.length;
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
    if (widget.texts.isEmpty) {
      return const SizedBox(); // Return an empty widget if no text is available
    }

    return SizedBox(
      height: 50,
      child: Stack(
        alignment: Alignment.centerLeft,
        children:
            widget.texts.asMap().entries.map((entry) {
              final int index = entry.key;
              final String text = entry.value;
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                top: index == _currentIndex ? 0 : 50,
                bottom: index == _currentIndex ? 0 : -50,
                child: Opacity(
                  opacity: index == _currentIndex ? 1.0 : 0.0,
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
