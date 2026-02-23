import 'package:flutter/material.dart';

class ScoreSummaryScreen extends StatefulWidget {
  final int score;
  final int total;
  final VoidCallback onRestart;

  const ScoreSummaryScreen({
    Key? key,
    required this.score,
    required this.total,
    required this.onRestart,
  }) : super(key: key);

  @override
  State<ScoreSummaryScreen> createState() => _ScoreSummaryScreenState();
}

class _ScoreSummaryScreenState extends State<ScoreSummaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _scoreAnimation = IntTween(
      begin: 0,
      end: widget.score,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getFeedbackMessage(int score, int total) {
    double percent = score / total;
    if (percent == 1) return "Perfect! 🎉";
    if (percent >= 0.8) return "Awesome job! 💪";
    if (percent >= 0.5) return "Well done! 👍";
    return "Keep practicing! 🌱";
  }

  @override
  Widget build(BuildContext context) {
    final feedback = getFeedbackMessage(widget.score, widget.total);

    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Your Score",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              AnimatedBuilder(
                animation: _scoreAnimation,
                builder: (context, child) {
                  return Text(
                    "${_scoreAnimation.value} / ${widget.total}",
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                feedback,
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: widget.onRestart,
                child: Text("Try Again"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
