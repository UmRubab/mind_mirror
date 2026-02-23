import 'dart:async';

import 'package:flutter/material.dart';
class BreathingScreen extends StatefulWidget {
  @override
  _BreathingScreenState createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  String instructionText = "Press Start to Begin";
  int countdown = 0;
  bool isBreathing = false;
  Timer? _phaseTimer;
  Timer? _countdownTimer;

  final int inhaleTime = 4;
  final int holdTime = 4;
  final int exhaleTime = 4;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: inhaleTime),
    );

    _animation = Tween<double>(begin: 100, end: 200).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void startBreathing() {
    if (isBreathing) return;

    setState(() {
      isBreathing = true;
    });

    _runInhalePhase();
  }

  void stopBreathing() {
    setState(() {
      instructionText = "Stopped";
      countdown = 0;
      isBreathing = false;
    });

    _controller.stop();
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
  }

  void _runCountdown(int seconds) {
    countdown = seconds;
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown > 1) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          countdown = 0;
        });
      }
    });
  }

  void _runInhalePhase() {
    _controller.forward(from: 0);
    setState(() {
      instructionText = "Inhale";
    });
    _runCountdown(inhaleTime);

    _phaseTimer = Timer(Duration(seconds: inhaleTime), _runHoldPhase);
  }

  void _runHoldPhase() {
    setState(() {
      instructionText = "Hold";
    });
    _runCountdown(holdTime);

    _phaseTimer = Timer(Duration(seconds: holdTime), _runExhalePhase);
  }

  void _runExhalePhase() {
    setState(() {
      instructionText = "Exhale";
    });
    _runCountdown(exhaleTime);
    _controller.reverse();

    _phaseTimer = Timer(Duration(seconds: exhaleTime), () {
      setState(() {
        instructionText = "Well Done 🎉";
        isBreathing = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(seconds: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isBreathing
                ? [Colors.teal.shade900, Colors.teal.shade600]
                : [Colors.blueGrey.shade900, Colors.black87],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  countdown > 0
                      ? "$instructionText - ${countdown}s"
                      : instructionText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      width: _animation.value,
                      height: _animation.value,
                      decoration: BoxDecoration(
                        color: Colors.tealAccent.withOpacity(0.7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.tealAccent.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: startBreathing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        "Start",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: stopBreathing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        "Stop",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}