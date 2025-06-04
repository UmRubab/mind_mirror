import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_mirror/Authentication/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class StartPage extends StatefulWidget {
  @override
  State<StartPage> createState() => _StartPageState();
}
class _StartPageState extends State<StartPage> with TickerProviderStateMixin {
  late final AnimationController _controller1;
  late final AnimationController _controller2;
  late final AnimationController _controller3;
  @override
  void initState() {
    super.initState();
    _controller1 =
    AnimationController(vsync: this, duration: Duration(seconds: 10))
      ..forward();
    _controller2 =
    AnimationController(vsync: this, duration: Duration(seconds: 10))
      ..forward();
    _controller3 =
    AnimationController(vsync: this, duration: Duration(seconds: 10))
      ..forward();
  }
  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  Widget buildCard(AnimationController controller, String text, IconData icon,
      Color color) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
      child: Card(
        color: color.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: ListTile(
          leading: Icon(icon, size: 40, color: Colors.white),
          title: Text(
            text,
            style: GoogleFonts.lato(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Mind Mirror\n Reflect, Heal & Grow",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),

            Column(
              children: [
                Container(
                  child: buildCard(
                      _controller1, "Train your mind daily", Icons.psychology,
                      Colors.deepPurple),
                ),
                Container(
                  child: buildCard(
                      _controller2, "Reflect with journaling", Icons.edit_note,
                      Colors.teal),
                ),
                Container(
                  child: buildCard(_controller3, "Boost peace with meditation",
                      Icons.self_improvement, Colors.indigo),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
               child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text('Get Started'),
                )
            )
          ],
        ),
      ),
    );
  }
}
