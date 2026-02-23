import 'package:flutter/material.dart';
import 'package:mind_mirror/Screens/Activitiespage/riddle.dart';
import 'package:shared_preferences/shared_preferences.dart';



class LevelSelectionScreen extends StatefulWidget {
  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen>
{  int unlockedLevel = 1;

@override
void initState() {
  super.initState();
  loadProgress();
}

Future<void> loadProgress() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    unlockedLevel = prefs.getInt('unlockedLevel') ?? 1;
  });
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
        title: Text('Riddles',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
      centerTitle: true,),
    body: GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: 50,
      itemBuilder: (context, index) {
        int level = index + 1;
        bool isUnlocked = level <= unlockedLevel;

        return GestureDetector(
          onTap: isUnlocked
              ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RiddleQuizScreen(level: level),
              ),
            );
          }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.purple.shade500 : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                "Level $level",
                style: TextStyle(
                  color: isUnlocked ? Colors.white : Colors.black45,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
}
