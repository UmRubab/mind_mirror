import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // import the model

class AddJournalPage extends StatefulWidget {
  const AddJournalPage({super.key});

  @override
  State<AddJournalPage> createState() => _AddJournalPageState();
}

class _AddJournalPageState extends State<AddJournalPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final _database = FirebaseDatabase.instance.ref('journal');
  final _auth = FirebaseAuth.instance;

  Future<void> _saveJournalEntry() async {
    final users = _auth.currentUser;
    if (users == null) return;
    final entry = JournalEntry(
      title: titleController.text.trim(),
      content: contentController.text.trim(),
      date: DateTime.now().toIso8601String(),
    );

    final journalRef = _database
        .child('journals')
        .push();

    await journalRef.set(entry.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Journal saved')),
    );

    titleController.clear();
    contentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Daily Journal')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                 SizedBox(height: 10),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'What’s on your mind?'),
                  maxLines: 5,
                ),
                 SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saveJournalEntry,
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

