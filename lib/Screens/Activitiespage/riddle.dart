import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mind_mirror/Screens/Activitiespage/riddlelevels.dart';
import 'package:mind_mirror/Screens/Activitiespage/riddlescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';




class RiddleQuizScreen extends StatefulWidget {
  final int level;
  RiddleQuizScreen({required this.level});

  @override
  _RiddleQuizScreenState createState() => _RiddleQuizScreenState();
}

class _RiddleQuizScreenState extends State<RiddleQuizScreen> {
  late List<Map<String, dynamic>> riddles;
  int currentRiddle = 0;
  int score = 0;
  int timer = 20;
  Timer? countdown;
  bool showSummary = false;

  String? selectedOption;
  bool isOptionTapped = false;

  @override
  void initState() {
    super.initState();
    riddles = levelRiddles[widget.level]!;
    startTimer();
  }

  void startTimer() {
    timer = 20;
    countdown?.cancel();
    countdown = Timer.periodic(Duration(seconds: 1), (timerObj) {
      if (timer == 0) {
        timerObj.cancel();
        goToNext(null);
      } else {
        setState(() => timer--);
      }
    });
  }

  void goToNext(String? selected) async {
    countdown?.cancel();

    final correct = riddles[currentRiddle]['answer'];

    if (selected != null && selected == correct) {
      score++;
    }

    setState(() {
      selectedOption = selected;
      isOptionTapped = true;
    });

    await Future.delayed(Duration(seconds: 2));

    if (currentRiddle < riddles.length - 1) {
      setState(() {
        currentRiddle++;
        selectedOption = null;
        isOptionTapped = false;
      });
      startTimer();
    } else {
      final prefs = await SharedPreferences.getInstance();
      int unlocked = prefs.getInt('unlockedLevel') ?? 1;
      if (widget.level == unlocked && widget.level < 50 && score >= 3) {
        prefs.setInt('unlockedLevel', unlocked + 1);
      }
      setState(() => showSummary = true);
    }
  }

  Color getOptionColor(String option) {
    final correct = riddles[currentRiddle]['answer'];
    if (!isOptionTapped) return Colors.deepPurple;
    if (option == correct) return Colors.green;
    if (option == selectedOption) return Colors.red;
    return Colors.grey;
  }

  Widget buildOption(String option) {
    return GestureDetector(
      onTap: isOptionTapped ? null : () => goToNext(option),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: getOptionColor(option),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Center(
          child: Text(
            option,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (showSummary) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Level ${widget.level} Complete"),
          backgroundColor: Colors.deepPurple,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "You scored $score out of ${riddles.length}!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LevelSelectionScreen()),
                  );
                },
                child: Text("Go to Levels"),
              ),
              SizedBox(height: 20),
              if (widget.level < 50)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RiddleQuizScreen(level: widget.level + 1),
                      ),
                    );
                  },
                  child: Text("Next Level"),
                ),
            ],
          ),
        ),
      );
    }

    final riddle = riddles[currentRiddle];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Level ${widget.level}'),
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "Time: $timer",
                style: TextStyle(fontSize: 18),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
              child: Text(
                riddle['question'],
                key: ValueKey(currentRiddle),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 30),
            ...riddle['options'].map<Widget>((option) {
              return buildOption(option);
            }).toList(),
            SizedBox(height: 30),
            LinearProgressIndicator(
              value: (currentRiddle + 1) / riddles.length,
              color: Colors.deepPurple,
              backgroundColor: Colors.grey.shade300,
            ),
            SizedBox(height: 10),
            Text(
              'Score: $score',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
