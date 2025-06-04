import 'package:flutter/material.dart';
import 'package:mind_mirror/puzzles.dart';
class ActivitiesScreen extends StatefulWidget {
  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final List<ActivityItem> activities = [
    ActivityItem(
      title: "Visual Puzzles",
      subtitle: "Test your skills by finding the hidden clues",
      icon: Icons.remove_red_eye,
      color: Colors.green,


    ),
    ActivityItem(
      title: "Brain and Personality Tests",
      subtitle: "Know your traits and abilities",
      icon: Icons.psychology,
      color: Colors.blueAccent,
    ),
    ActivityItem(
      title: "Meditations",
      subtitle: "Relax with isochronic tones and solfeggio frequencies",
      icon: Icons.self_improvement,
      color: Colors.pinkAccent,
    ),
    ActivityItem(
      title: "Breathing",
      subtitle: "Breathing exercises perfect before preparing to train",
      icon: Icons.air,
      color: Colors.teal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Activities")),
      body: ListView.builder(
        itemCount: activities.length,
        padding: EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final item = activities[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => puzzle()),
              );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(item.icon, color: item.color, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(item.subtitle,
                            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ActivityItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  /*final VoidCallback onTap;*/



  ActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    /*required this.onTap,*/

  });
}

