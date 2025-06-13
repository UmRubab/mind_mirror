import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'journal list.dart';
class dailyjouranl extends StatefulWidget {
  const dailyjouranl({super.key});

  @override
  State<dailyjouranl> createState() => _dailyjouranlState();
}
class _dailyjouranlState extends State<dailyjouranl> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final DatabaseReference _journalRef = FirebaseDatabase.instance.ref('journal');
  final auth = FirebaseAuth.instance;
  List<JournalEntry> data = [];
  Future<JournalEntry> saveJournalEntry() async {
    final entry = JournalEntry(
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      date: DateTime.now().toIso8601String(),
    );
    final journalRef =  _journalRef
        .push();
    await journalRef.set(entry.toMap());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Journal saved')),
    );

    titleController.clear();
    contentController.clear();
    return entry;
  }
  Future<List<JournalEntry>> fetchJournalEntries() async {
    final snapshot = await _journalRef.get();

    List<JournalEntry> entries = [];

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        entries.add(JournalEntry(
          title: value['title'] ?? '',
          content: value['content'] ?? '',
          date: value['Date'] ?? '',
        ));
      });
    }

    return entries;
  }




  @override
  Widget build(BuildContext context) {
    final mediaquery=MediaQuery.of(context).size;
    final height=mediaquery.height;
    final widht= mediaquery.width;

    return Scaffold(
      body:
      Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage('images/journal.jpg'),),
        ),
        child: Center(
          child: Container(
            child: Column(
              children: [
                Text('My daily Journal'),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(labelText: 'What’s on your mind?'),
                  maxLines: 5,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    final entry = await saveJournalEntry();
                    data.add(entry);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => readData(entry: data),
                      ),
                    );
                  },


                  child: Text('Save Journal'),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
class JournalEntry{
  final String title;
  final String content;
  final String date;

  JournalEntry({
    required this.title,
    required this.content,
    required this.date,
  });
  Map<String,dynamic>toMap(){
    return{
      'title':title,
      'content':content,
      'Date':date,
    };
  }
}

