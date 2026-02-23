import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Screens/Activitiespage/Activities.dart';
import 'Screens/Profile.dart';
import 'Screens/games.dart';
import 'Screens/homePage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedindex=0;
  void buttons(int index) {
    setState((){
      _selectedindex=index;
    });
  }
  List<dynamic> names=[
    Today(username: ''),
    CognitiveFlipGame(),
    ActivitiesScreen(),
    UserProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: names[_selectedindex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        index: _selectedindex,
        height: 60.0,
        color:  Color.fromRGBO(175, 103, 177, 1.0),
        buttonBackgroundColor: Color.fromRGBO(111, 74, 142, 1.0),

        animationDuration: Duration(milliseconds: 300),
        animationCurve: Curves.easeOutBack,
        items: [
          Icon(Icons.today, size: 20, ),
          Icon(Icons.fitness_center, size: 20, ),
          Icon(Icons.videogame_asset, size: 20, ),
          Icon(Icons.person, size: 20, ),
        ],
        onTap: buttons,
      ),
    );
  }
}


