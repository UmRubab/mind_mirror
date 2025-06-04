import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_mirror/gmaes.dart';

import 'Today/dailyjournal.dart';
class Today extends StatefulWidget {
  const Today({Key? key}) : super(key: key);

  @override
  _TodayState createState() => _TodayState();
}

class _TodayState extends State<Today> {
  final DatabaseReference _moodRef = FirebaseDatabase.instance.ref('moods');
  String selectedDay = "";
  final days = ["S", "M", "T", "W", "T", "F", "S"];
  final fullDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

  @override
  void initState() {
    super.initState();
    final currentWeekday = DateTime.now().weekday;
    selectedDay = fullDays[currentWeekday % 7];
  }


  final Map<String, List<String>> _moodAffirmations = {
    'Happy': [
      "Your joy is contagious!",
      "Celebrate this happy moment!",
    ],
    'Calm': [
      "Peace begins with a calm mind.",
      "Breathe in calm, breathe out stress."
    ],
    'Sad': [
      "It's okay to slow down.",
      "You're safe here. Take deep breaths.",
      "This energy will pass. Be gentle with yourself."
    ],
    'Angry': [
      "Anger is just unmet needs speaking.",
      "Let's find the root of this together."
    ],
  };

  Future<void> _logMood(String mood) async {
    await _moodRef.push().set({

      'mood': mood,
      'timestamp': DateTime.now().toString(),
    });
  }
  void _showAffirmationDialog(String mood) {
    final affirmations = _moodAffirmations[mood] ?? [];
    final randomAffirmation = affirmations.isNotEmpty
        ? affirmations[DateTime.now().millisecondsSinceEpoch % affirmations.length]
        : "You're doing great!";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "$mood",
          style: GoogleFonts.poppins(
            color: _getMoodColor(mood),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          randomAffirmation,
          style: GoogleFonts.poppins(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: GoogleFonts.poppins(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Happy': return Colors.orange[400]!;
      case 'Calm': return Colors.teal[400]!;
      case 'Sad': return Colors.purple[400]!;
      case 'Angry': return Colors.red[400]!;
      default: return Colors.indigo;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Mind Mirror',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '',
              style: GoogleFonts.poppins(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'How are you feeling today?',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20),
            _buildMoodSelection(),
            SizedBox(height: 10),
            Text("Weekly Training Calendar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                String day = fullDays[index];
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: selectedDay == day ? Colors.blue : Colors.grey.shade300,
                        child: Text(
                          days[index],
                          style: TextStyle(color: selectedDay == day ? Colors.white : Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(day.substring(0, 3)),
                  ],
                );
              }),
            ),
          SizedBox(height: 30,),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.indigo[400]!, Colors.purple[400]!],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today s Brain Training',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Let's open up to the things that matter the most",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ), SizedBox(height: 15),

                ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CognitiveFlipGame()));

                },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Continue',
                        style: GoogleFonts.poppins(
                          color: Colors.indigo[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
            SizedBox(height: 30),
        Column(
          children: [
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddJournalPage()));
            }, child:Column
              (
                children: [
                  Icon(Icons.edit_note),
                  Text('Daily Journal')

                ]
            ),
            )
          ],),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
  Widget _buildMoodSelection() {
    final moods = [
      {'emoji': '😊', 'label': 'Happy'},
      {'emoji': '😌', 'label': 'Calm'},
      {'emoji': '😔', 'label': 'Sad'},
      {'emoji': '😠', 'label': 'Angry'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: moods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final mood = moods[index]['label']!;
          return GestureDetector(
            onTap: () async {
              await _logMood(mood);
              _showAffirmationDialog(mood);
            },
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: _getMoodColor(mood).withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    moods[index]['emoji']!,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    mood,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: _getMoodColor(mood),
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





