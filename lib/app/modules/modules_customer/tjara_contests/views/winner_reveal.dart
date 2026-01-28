import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:tjara/app/modules/modules_customer/tjara_contests/model/contest_model.dart';

class WinnerReveal extends StatefulWidget {
  final ContestModel contest;

  const WinnerReveal({super.key, required this.contest});

  @override
  State<WinnerReveal> createState() => _WinnerRevealState();
}

class _WinnerRevealState extends State<WinnerReveal>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _slotMachineController;
  late AnimationController _revealController;
  late AnimationController _glowController;
  late AnimationController _particleController;

  bool _isRevealing = false;
  bool _revealed = false;
  final List<int> _slotIndices = [0, 0, 0];
  Timer? _slotTimer;

  List<Participant> get eligibleParticipants {
    return widget.contest.participants?.participants
            ?.where((p) => p.isEligibleForPrize == true)
            .toList() ??
        [];
  }

  Participant? get winner {
    if (widget.contest.winnerId == null) return null;
    return widget.contest.participants?.participants
        ?.where((p) => p.userId == widget.contest.winnerId)
        .firstOrNull;
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    _slotMachineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _slotMachineController.dispose();
    _revealController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    _slotTimer?.cancel();
    super.dispose();
  }

  void _startReveal() async {
    if (eligibleParticipants.isEmpty || winner == null) return;

    setState(() {
      _isRevealing = true;
      _slotIndices[0] = 0;
      _slotIndices[1] = 0;
      _slotIndices[2] = 0;
    });

    final winnerIndex = eligibleParticipants.indexWhere(
      (p) => p.id == winner!.id,
    );
    int ticks = 0;

    _slotTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      ticks++;

      setState(() {
        // Slot 1 stops first (after 15 ticks)
        if (ticks < 15) {
          _slotIndices[0] = math.Random().nextInt(eligibleParticipants.length);
        }
        // Slot 2 stops second (after 25 ticks)
        if (ticks < 25) {
          _slotIndices[1] = math.Random().nextInt(eligibleParticipants.length);
        }
        // Slot 3 continues until winner
        if (ticks < 35) {
          _slotIndices[2] = math.Random().nextInt(eligibleParticipants.length);
        }
      });

      _slotMachineController.forward(from: 0);

      if (ticks == 15) {
        _slotIndices[0] = winnerIndex;
      }
      if (ticks == 25) {
        _slotIndices[1] = winnerIndex;
      }

      if (ticks >= 35) {
        timer.cancel();
        setState(() {
          _slotIndices[2] = winnerIndex;
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          _revealWinner();
        });
      }
    });
  }

  void _revealWinner() {
    setState(() {
      _revealed = true;
      _isRevealing = false;
    });
    _confettiController.play();
    _revealController.forward();
    _particleController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    if (winner == null) {
      return _buildNoWinnerState();
    }

    return Stack(
      children: [
        // Animated background
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  _revealed
                      ? [
                        const Color(0xFFFFD700).withOpacity(0.1),
                        const Color(0xFFFF6B6B).withOpacity(0.1),
                        const Color(0xFF4ECDC4).withOpacity(0.1),
                      ]
                      : [Colors.purple.shade50, Colors.blue.shade50],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 30),

              if (!_revealed && !_isRevealing)
                _buildRevealButton()
              else if (_isRevealing)
                _buildSlotMachine()
              else
                _buildWinnerReveal(),

              if (_revealed) ...[
                const SizedBox(height: 30),
                _buildLeaderboard(),
              ],
            ],
          ),
        ),

        // Confetti (left side)
        Positioned(
          top: 0,
          left: 50,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: math.pi / 4,
            emissionFrequency: 0.03,
            numberOfParticles: 15,
            gravity: 0.15,
            colors: const [
              Color(0xFFFFD700),
              Color(0xFFFF6B6B),
              Color(0xFF4ECDC4),
              Color(0xFFFF8C42),
              Color(0xFF95E1D3),
            ],
          ),
        ),

        // Confetti (right side)
        Positioned(
          top: 0,
          right: 50,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3 * math.pi / 4,
            emissionFrequency: 0.03,
            numberOfParticles: 15,
            gravity: 0.15,
            colors: const [
              Color(0xFFFFD700),
              Color(0xFFFF6B6B),
              Color(0xFF4ECDC4),
              Color(0xFFFF8C42),
              Color(0xFF95E1D3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Winner Announcement',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevealButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: InkWell(
        onTap: _startReveal,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 70),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8C42)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFFFF6B6B,
                    ).withOpacity(0.4 + (_glowController.value * 0.2)),
                    blurRadius: 20 + (_glowController.value * 10),
                    spreadRadius: 2 + (_glowController.value * 3),
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_circle_filled,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reveal Winner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Tap to start',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotMachine() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🎰 Finding the Winner...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 24),

          LinearProgressIndicator(
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildSlot(int slotIndex) {
    if (eligibleParticipants.isEmpty) return const SizedBox.shrink();

    final participant = eligibleParticipants[_slotIndices[slotIndex]];
    final name = participant.participant?.firstName ?? 'Unknown';

    return AnimatedBuilder(
      animation: _slotMachineController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -10 * _slotMachineController.value),
          child: Opacity(
            opacity: 1.0 - (_slotMachineController.value * 0.3),
            child: child,
          ),
        );
      },
      child: Container(
        width: 100,
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFF6B6B).withOpacity(0.1),
              const Color(0xFFFF8C42).withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF6B6B), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8C42)],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name.length > 8 ? '${name.substring(0, 8)}...' : name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerReveal() {
    return AnimatedBuilder(
      animation: _revealController,
      builder: (context, child) {
        final curvedValue = Curves.elasticOut.transform(
          _revealController.value,
        );

        return Transform.scale(
          scale: curvedValue,
          child: Opacity(opacity: _revealController.value, child: child),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glowing particles
          if (_revealed)
            ...List.generate(12, (index) {
              final angle = (index * 30) * math.pi / 180;
              return AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  final distance =
                      80 +
                      (30 * math.sin(_particleController.value * math.pi * 2));
                  return Transform.translate(
                    offset: Offset(
                      math.cos(angle) * distance,
                      math.sin(angle) * distance,
                    ),
                    child: Opacity(
                      opacity: 0.6 * (1 - (_particleController.value % 1)),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              [
                                const Color(0xFFFFD700),
                                const Color(0xFFFF6B6B),
                                const Color(0xFF4ECDC4),
                              ][index % 3],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: [
                                const Color(0xFFFFD700),
                                const Color(0xFFFF6B6B),
                                const Color(0xFF4ECDC4),
                              ][index % 3].withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

          // Winner card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFfea52d), Color(0xFFfea52d)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('👑', style: TextStyle(fontSize: 60)),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'WINNER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${winner!.participant?.firstName} ${winner!.participant?.lastName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFD700),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${winner!.correctAnswers}/${winner!.totalQuestions} Correct',
                        style: const TextStyle(
                          color: Color(0xFFFF6B6B),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    final topParticipants = eligibleParticipants.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.leaderboard, color: Colors.teal),
            SizedBox(width: 8),
            Text(
              'Top Performers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...topParticipants.asMap().entries.map((entry) {
          final index = entry.key;
          final participant = entry.value;
          final isWinner = participant.id == winner!.id;

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 100)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(50 * (1 - value), 0),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient:
                    isWinner
                        ? LinearGradient(
                          colors: [
                            const Color(0xFFfea52d).withOpacity(0.3),
                            const Color(0xFFfea52d).withOpacity(0.2),
                          ],
                        )
                        : null,
                color: isWinner ? null : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isWinner ? const Color(0xFFfea52d) : Colors.grey.shade200,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isWinner
                            ? const Color(0xFFFFD700).withOpacity(0.2)
                            : Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient:
                          isWinner
                              ? const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              )
                              : null,
                      color: isWinner ? null : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        index == 0
                            ? '🥇'
                            : index == 1
                            ? '🥈'
                            : index == 2
                            ? '🥉'
                            : '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: index < 3 ? 20 : 16,
                          color: isWinner ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${participant.participant?.firstName} ${participant.participant?.lastName}',
                          style: TextStyle(
                            fontWeight:
                                isWinner ? FontWeight.bold : FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        if (isWinner)
                          const Text(
                            'Winner',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFFF6B6B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isWinner
                              ? Colors.white
                              : const Color(0xFFFF6B6B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${participant.correctAnswers}/${participant.totalQuestions}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color:
                            isWinner ? const Color(0xFFFF6B6B) : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNoWinnerState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_empty,
              size: 50,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Winner Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Winner will be announced soon',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
