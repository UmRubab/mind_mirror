import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mind_mirror/Activities.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_mirror/Today/dailyjournal.dart';

import 'Today.dart';
import 'gmaes.dart';
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
    Today(),
    CognitiveFlipGame(),
    ActivitiesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: names[_selectedindex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromRGBO(148, 23, 151, 1.0),
        type: BottomNavigationBarType.fixed,
        items:[
          BottomNavigationBarItem(icon: Icon(Icons.today,color: Colors.white,), label: 'Today',),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center,color: Colors.white,), label: 'Activities'),
          BottomNavigationBarItem(icon: Icon(Icons.videogame_asset,color: Colors.white,), label: 'Games'),
          BottomNavigationBarItem(icon: Icon(Icons.person,color: Colors.white,), label: 'Profile'),
        ] ,
        selectedItemColor: Colors.teal.shade300,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedindex,
        onTap:buttons,
      ),
    );
  }
}

