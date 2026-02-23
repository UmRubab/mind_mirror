import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
class PuzzleScreen extends StatefulWidget {
  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}
class _PuzzleScreenState extends State<PuzzleScreen> {
  List<List<String>> puzzleGrid = [
    ["",     "",   "",    "",    ""],
    ["6",    "+",  "16",  "=",   ""],
    ["15",   "",   "",    "",    ""],
    ["=",    "",   "=",   "",    "10"],
    ["2",    "*",  "",    "-",   ""],
    ["=",    "3",  "7",   "-",   "8"],
  ];

  void swapNumbers(int r1, int c1, int r2, int c2) {
    setState(() {
      final temp = puzzleGrid[r1][c1];
      puzzleGrid[r1][c1] = puzzleGrid[r2][c2];
      puzzleGrid[r2][c2] = temp;
    });
  }

  Widget buildCell(int row, int col) {
    String value = puzzleGrid[row][col];
    return GestureDetector(
      onTap: () {
        // Example: Swap (1,0) with (1,2) when either is tapped (for demo only)
        if ((row == 1 && col == 0) || (row == 1 && col == 2)) {
          swapNumbers(1, 0, 1, 2);
        }
      },
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.purple.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double gridWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "LEVEL 1 ",
              style: TextStyle(
                fontSize: 24,
                color: Colors.cyanAccent,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Container(
                  width: gridWidth * 0.95,
                  child: AspectRatio(
                    aspectRatio: 5 / 6,
                    child: GridView.builder(
                      padding: EdgeInsets.all(8),
                      itemCount: puzzleGrid.length * puzzleGrid[0].length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        int row = index ~/ 5;
                        int col = index % 5;
                        return buildCell(row, col);
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.pause_circle_filled, color: Colors.cyanAccent),
                  Icon(Icons.search, color: Colors.cyanAccent),
                  Icon(Icons.help_outline, color: Colors.cyanAccent),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/*class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  bool isInhaling = false;
  double containerSize = 150;

  void performInhale() {
    setState(() {
      isInhaling = true;
      containerSize = 200;
    });

    Timer(const Duration(seconds: 3), () {
      setState(() {
        isInhaling = false;
        containerSize = 150;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.015,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.arrow_back_ios, color: Colors.grey),
                  Icon(Icons.favorite_border, color: Colors.red),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              const Text(
                '5 Minutes',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              const Text(
                'Inhale Exhale for\nBalance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(seconds: 3),
                    curve: Curves.easeInOut,
                    width: containerSize,
                    height: containerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.air, size: 60, color: Colors.grey),
                  ),
                  Positioned(
                    left: 0,
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: Column(
                        children: [
                          const Icon(Icons.volume_up, color: Colors.grey),
                          Container(
                            height: 100,
                            width: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade300,
                            ),
                            child: FractionallySizedBox(
                              heightFactor: 0.6,
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text.rich(
                  TextSpan(
                    text: 'Envying others can blind us to our own treasures, ',
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'leading to loss',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      TextSpan(
                        text: ', as seen in the story of the greedy dog.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.square, color: Colors.grey),
                  GestureDetector(
                    onTap: performInhale,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.deepPurple,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white),
                    ),
                  ),
                  const Icon(Icons.close, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}*/

