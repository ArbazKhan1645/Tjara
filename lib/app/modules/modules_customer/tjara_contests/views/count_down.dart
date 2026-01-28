import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final String? endTime;
  final VoidCallback? onExpired;

  const CountdownTimer({super.key, required this.endTime, this.onExpired});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration? _remaining;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const Color primaryTeal = Color(0xFF008080);
  static const Color accentTeal = Color(0xFF00A5A5);
  static const Color darkTeal = Color(0xFF006666);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startTimer();
  }

  void _startTimer() {
    if (widget.endTime == null) return;

    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    if (widget.endTime == null) return;

    try {
      final end = DateTime.parse(widget.endTime!);
      final now = DateTime.now();

      if (end.isBefore(now)) {
        setState(() => _remaining = null);
        _timer?.cancel();
        widget.onExpired?.call();
        return;
      }

      setState(() => _remaining = end.difference(now));
    } catch (e) {
      setState(() => _remaining = null);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == null) return const SizedBox();

    final days = _remaining!.inDays;
    final hours = _remaining!.inHours % 24;
    final minutes = _remaining!.inMinutes % 60;
    final seconds = _remaining!.inSeconds % 60;

    final isUrgent = _remaining!.inHours < 24;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isUrgent ? _pulseAnimation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isUrgent
                    ? [Colors.orange.shade500, Colors.deepOrange.shade600]
                    : [primaryTeal, accentTeal],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isUrgent ? Colors.orange : primaryTeal).withAlpha(77),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isUrgent ? Icons.alarm_rounded : Icons.timer_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isUrgent ? 'Hurry! Contest Ends In' : 'Contest Ends In',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (days > 0) ...[
                  _TimeUnit(value: days, label: 'Days', isUrgent: isUrgent),
                  _TimeSeparator(isUrgent: isUrgent),
                ],
                _TimeUnit(value: hours, label: 'Hrs', isUrgent: isUrgent),
                _TimeSeparator(isUrgent: isUrgent),
                _TimeUnit(value: minutes, label: 'Min', isUrgent: isUrgent),
                _TimeSeparator(isUrgent: isUrgent),
                _TimeUnit(value: seconds, label: 'Sec', isUrgent: isUrgent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeUnit extends StatelessWidget {
  final int value;
  final String label;
  final bool isUrgent;

  const _TimeUnit({
    required this.value,
    required this.label,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withAlpha(26), width: 1),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              fontFeatures: [FontFeature.tabularFigures()],
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(204),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _TimeSeparator extends StatelessWidget {
  final bool isUrgent;

  const _TimeSeparator({this.isUrgent = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(179),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(179),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
