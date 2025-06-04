import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mind_mirror/homepage.dart';
import 'package:mind_mirror/startpage.dart';

import 'firebase_options.dart';
void main() async {
  // Ensure that Firebase is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
  runApp(MyApp()); // Run the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mind Mirror',
     /* home: Homepage(),*/
     /*home: MentalHealthDashboard(),*/
   home:StartPage(),


    );
  }
}


