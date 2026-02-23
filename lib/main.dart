import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mind_mirror/Screens/Animatedscreen.dart';

import 'firebase_options.dart';

void main() async {
  // Ensure that Firebase is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Fdart pub global activate flutterfire_cliirebase
  runApp
  /*ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ));*/
    (const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /*final themeProvider = Provider.of<ThemeProvider>(context);*/
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      /* theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,*/
      title: 'Mind Mirror',
      home:StartPage(),



    );
  }
}


