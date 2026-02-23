import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Daily Journal.dart';
import 'games.dart';


class Today extends StatefulWidget {
  final String username;
/*  const Today({Key? key, required this.userId}) : super(key: key);*/

  const Today({super.key,required this.username});

  @override
  _TodayState createState() => _TodayState();
}
class _TodayState extends State<Today> {
  final List<String> quotes = [
    "'You are stronger than you think.'",
    "This moment too shall pass.",
    "Keep going — you’re doing great.",
    "Every day is a fresh start.",
    "You are loved, you are enough.",
    "Hope is the heartbeat of the soul.",
    "You’re not alone in this journey.",
    "Kindness begins with yourself.",
    "It’s okay to rest. You matter.",
    "Even small steps take you forward.",
    "You have survived 100% of your bad days.",
    "Let your light shine even on cloudy days.",
    "You are worthy of love and happiness.",
    "Progress is still progress, no matter how small.",
    "Your feelings are valid.",
    "Rest is productive too.",
    "Be gentle with yourself.",
    "Healing takes time — and that’s okay.",
    "You’ve got this.",
    "Believe in your inner strength.",
    "Joy can live even in small moments.",
    "You don’t need to have it all figured out.",
    "Your pace is perfect for your journey.",
    "You matter. Always.",
    "One breath at a time.",
    "You’re doing the best you can.",
    "Your journey is unfolding exactly as it should.",
    "Peace begins with you.",
    "It’s okay to ask for help.",
    "You bring value to the world.",
    "Let go of what you can’t control.",
    "Embrace the now.",
    "Growth often feels uncomfortable.",
    "You are a light in this world.",
    "Pause. Breathe. Begin again.",
    "Your story is important.",
    "Trust the process.",
    "You are capable of amazing things.",
    "You’re more than your struggles.",
    "Celebrate the small wins.",
    "Your heart knows the way.",
    "Choose kindness, always.",
    "The world is better with you in it.",
    "Silence is a place for healing.",
    "You are allowed to rest.",
    "You are more than enough.",
    "Be proud of how far you’ve come.",
    "Difficult roads often lead to beautiful destinations.",
    "Let yourself feel and heal.",
    "You are not broken.",
    "Every emotion teaches something.",
    "Keep showing up for yourself.",
    "Be your own safe place.",
    "Forgive yourself often.",
    "Don’t compare your path to others.",
    "Every sunrise is another chance.",
    "You’re allowed to grow beyond your past.",
    "It’s okay to start over.",
    "You are not a burden.",
    "Courage doesn't always roar.",
    "Trust your inner voice.",
    "Feel it. Heal it.",
    "You are a work in progress, and that’s beautiful.",
    "Be soft with yourself.",
    "You deserve good things.",
    "Self-love is not selfish.",
    "Your presence is powerful.",
    "Let your courage be bigger than your fear.",
    "You have permission to be happy.",
    "You don’t need to be perfect to be loved.",
    "Give yourself grace today.",
    "There’s beauty in becoming.",
    "You are not behind.",
    "Your best is enough.",
    "Take it one moment at a time.",
    "You are safe here.",
    "You are free to be yourself.",
    "Let yourself bloom.",
    "Joy is your birthright.",
    "It’s okay to not be okay.",
    "Be proud of your resilience.",
    "You are held in love.",
    "Let go of what no longer serves you.",
    "Trust that good things are coming.",
    "You are whole, just as you are.",
    "You’re growing, even when it’s invisible.",
    "Take time to recharge your soul.",
    "Let yourself be still.",
    "Your worth isn’t based on productivity.",
    "You’re making progress, even if it’s not visible.",
    "One gentle step at a time.",
    "Believe in your ability to overcome.",
    "Your presence is a gift.",
    "Let your heart lead the way.",
    "You are deeply loved.",
    "Be patient with your journey.",
    "You are not alone in your feelings.",
    "The storm will pass.",
    "You are your own home.",
    "Show up, even imperfectly.",
    "You are more than your mistakes.",
    "Let yourself unfold naturally.",
    "There’s strength in softness.",
    "You are doing sacred work by healing.",
    "You are worthy of the peace you seek.",
    "You are rewriting your story with love."
  ];
  late String selectedQuote;

  void getRandomQuote() {
    final random = Random();
    selectedQuote = quotes[random.nextInt('quotes'.length)];
  }
  String name = "";
  final auth = FirebaseAuth.instance;
  final dbRef = FirebaseDatabase.instance.ref('users');

  final DatabaseReference _moodRef = FirebaseDatabase.instance.ref('moods');
  String selectedDay = "";
  final fullDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

  @override
  void initState() {
    super.initState();
    getRandomQuote();
    fetchUsername();

    final currentWeekday = DateTime.now().year;
    selectedDay = fullDays[currentWeekday % 7];
    _logDailyStreak();
  }

  void fetchUsername() async {
    final snapshot = await dbRef.child(widget.username).get();
    if (snapshot.exists) {
      setState(() {
        name = snapshot.child('name').value.toString();
      });
    }
  }

  void _logDailyStreak() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final today = DateTime.now();
    final dateKey = "${today.year}-${today.month}-${today.day}";
    final streakRef = FirebaseDatabase.instance.ref('streaks/${user.uid}/$dateKey');
    final snapshot = await streakRef.get();
    if (!snapshot.exists) {
      await streakRef.set({'logged': true});
    }
  }
  final Map<String, List<String>> _moodAffirmations = {
    'Happy': ["Your joy is contagious!", "Celebrate this happy moment!"],
    'Calm': ["Peace begins with a calm mind.", "Breathe in calm, breathe out stress."],
    'Sad': ["It's okay to slow down.", "Take deep breaths,", "This energy will pass. Be gentle with yourself."],
    'Angry': ["Anger is just unmet needs speaking.", "Let's find the root of this together."],
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => JournalHomePage()));
            },
            child: Text("Share Your Thoughts", style: GoogleFonts.poppins(color: Colors.indigo, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Happy':
        return Colors.orange[400]!;
      case 'Calm':
        return Colors.teal[400]!;
      case 'Sad':
        return Colors.purple[400]!;
      case 'Angry':
        return Colors.red[400]!;
      default:
        return Colors.indigo;
    }
  }

  Widget _buildStreakCalendar() {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday % 7));
    final daysOfWeek = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DataSnapshot>(
      future: FirebaseDatabase.instance.ref('streaks/${user?.uid}').get(),
      builder: (context, snapshot) {
        final loggedDates = <String>{};
        if (snapshot.hasData && snapshot.data!.exists) {
          final rawData = snapshot.data!.value as Map<dynamic, dynamic>;
          loggedDates.addAll(rawData.keys.map((e) => e.toString()));
        }

        int streakCount = 0;
        for (final date in daysOfWeek) {
          final key = "${date.year}-${date.month}-${date.day}";
          if (loggedDates.contains(key)) {
            streakCount++;
          }
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: daysOfWeek.map((date) {
            final dateKey = "${date.year}-${date.month}-${date.day}";
            final isToday = date.day == today.day &&
                date.month == today.month &&
                date.year == today.year;
            final isLogged = loggedDates.contains(dateKey);

            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday
                        ? Colors.blue
                        : (isLogged ? Colors.green : Colors.grey.shade300),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Text(
                      "${date.day}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isToday
                            ? Colors.blue
                            : (isLogged ? Colors.green : Colors.black),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  fullDays[date.weekday % 7].substring(0, 3),
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 4),
                isToday && isLogged
                    ? Text(
                  "Streak: $streakCount🔥",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    :  SizedBox(height: 14),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*  appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('images/logoo.jpg'),),
        title: Text('MindMirror', style: TextStyle(fontWeight: FontWeight.bold)),
      ),*/
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good Morning, $name',

                style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.grey[600])),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                selectedQuote,
                textAlign: TextAlign.center,
                style:
                GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold,color:Colors.grey.shade800
                ),
              ),
            ),
            SizedBox(height: 5),
            Text('How are you feeling today?',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 5),
            _buildMoodSelection(),
            SizedBox(height: 5),
            Text("Weekly Streak Calendar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            _buildStreakCalendar(),
            SizedBox(height: 5),
            Container(
              padding:  EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.indigo[400]!, Colors.purple[400]!],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.2), blurRadius: 15, spreadRadius: 2)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today\'s Brain Training',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 8),
                  Text("'Let's open up to the things that matter the most'",
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                  SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CognitiveFlipGame()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Continue',
                            style: GoogleFonts.poppins(color: Colors.indigo[800], fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height:5),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => JournalHomePage()));
              },
              child: Column(
                children: [
                  Icon(Icons.edit_note),
                  Text('Daily Journal'),
                ],
              ),
            ),

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
                  Text(moods[index]['emoji']!, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 5),
                  Text(
                    mood,
                    style: GoogleFonts.poppins(fontSize: 14, color: _getMoodColor(mood)),
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
