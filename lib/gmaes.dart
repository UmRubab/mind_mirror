import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CognitiveFlipGame extends StatefulWidget {
  const CognitiveFlipGame({Key? key}) : super(key: key);

  @override
  _CognitiveFlipGameState createState() => _CognitiveFlipGameState();
}

class _CognitiveFlipGameState extends State<CognitiveFlipGame> {
  // Game configuration
  final List<Map<String, dynamic>> _gameModes = [
    {
      "title": "Memory",
      "icon": Icons.memory,
      "color": Colors.purple,
      "cards": ["🍎", "🌻", "🚗",]
    },
    {
      "title": "Logic",
      "icon": Icons.psychology,
      "color": Colors.blue,
      "cards": ["≠", "⊂", "⇒"]
    },
  ];

  // Game state
  late List<String> _cards;
  late List<bool> _flipped;
  int? _firstCardIndex;
  int _score = 0;
  int _level = 1;
  bool _gameStarted = false;
  int _remainingTime = 60;
  late Timer _timer;
  String _currentMode = "Memory";

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _initializeGame() {
    final mode = _gameModes.firstWhere((m) => m["title"] == _currentMode);
    _cards = [...mode["cards"], ...mode["cards"]]..shuffle();
    _flipped = List<bool>.filled(_cards.length, false);
    _firstCardIndex = null;
    _score = 0;
    _remainingTime = 60;
    _gameStarted = false;
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer.cancel();
        _showGameOverDialog();
      }
    });
  }

  void _flipCard(int index) {
    if (!_gameStarted) _startGame();
    if (_flipped[index] ||
        (_firstCardIndex != null && _firstCardIndex == index)) {
      return;
    }
    setState(() {
      _flipped[index] = true;
    });

    if (_firstCardIndex == null) {
      _firstCardIndex = index;
    } else {
      // Check for match
      if (_cards[index] == _cards[_firstCardIndex!]) {
        _score += 10 * _level;
        _firstCardIndex = null;

        // Check level completion
        if (_flipped.every((f) => f)) {
          _timer.cancel();
          Future.delayed(const Duration(milliseconds: 500), () {
            _showLevelCompleteDialog();
          });
        }
      } else {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _flipped[index] = false;
              _flipped[_firstCardIndex!] = false;
              _firstCardIndex = null;
              _score = (_score - 2).clamp(0, double.infinity).toInt();
            });
          }
        });
      }
    }
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(
                "Level $_level Complete!", style: GoogleFonts.poppins()),
            content: Text("Score: $_score\nTime remaining: $_remainingTime sec",
                style: GoogleFonts.poppins()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _nextLevel();
                },
                child: Text("Next Level", style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text("Time's Up!", style: GoogleFonts.poppins()),
            content: Text("Final Score: $_score", style: GoogleFonts.poppins()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _initializeGame();
                },
                child: Text("Play Again", style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }

  void _nextLevel() {
    setState(() {
      _level++;
      _remainingTime += 15; // Bonus time
      final mode = _gameModes.firstWhere((m) => m["title"] == _currentMode);
      _cards =
      [...mode["cards"], ...mode["cards"], ...mode["cards"]]..shuffle();
      _flipped = List<bool>.filled(_cards.length, false);
      _firstCardIndex = null;
      _gameStarted = false;
    });
  }

  void _changeMode(String mode) {
    setState(() {
      _currentMode = mode;
      _level = 1;
      _initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentModeData = _gameModes.firstWhere((m) =>
    m["title"] == _currentMode);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Mind Flip: $_currentMode", style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeGame,
          ),
        ],
      ),
      body: Column(
        children: [
          // Game stats
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard("Level", "$_level", Icons.star, Colors.amber),
                _buildStatCard(
                    "Score", "$_score", Icons.leaderboard, Colors.green),
                _buildStatCard(
                    "Time", "$_remainingTime", Icons.timer, Colors.red),
              ],
            ),
          ),

          // Mode selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _gameModes.map((mode) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(mode["title"]),
                    selected: _currentMode == mode["title"],
                    onSelected: (selected) => _changeMode(mode["title"]),
                    backgroundColor: mode["color"].withOpacity(0.1),
                    selectedColor: mode["color"].withOpacity(0.3),
                    labelStyle: GoogleFonts.poppins(
                      color: _currentMode == mode["title"]
                          ? mode["color"]
                          : Colors.grey[700],
                    ),
                    avatar: Icon(mode["icon"], color: mode["color"]),
                  ),
                );
              }).toList(),
            ),
          ),

          // Game board
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.9,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, index) => _buildGameCard(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon,
      Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 12)),
              Text(value, style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(int index) {
    final currentModeData = _gameModes.firstWhere((m) =>
    m["title"] == _currentMode);

    return GestureDetector(
      onTap: () => _flipCard(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _flipped[index]
              ? Colors.white
              : currentModeData["color"].withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _flipped[index]
                ? currentModeData["color"].withOpacity(0.5)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: _flipped[index]
              ? Text(
            _cards[index],
            style: TextStyle(
              fontSize: _cards[index].length > 1 ? 28 : 36,
              color: currentModeData["color"],
            ),
          )
              : Icon(
            Icons.question_mark,
            color: currentModeData["color"].withOpacity(0.5),
            size: 28,
          ),
        ),
      ),
    );
  }

}

