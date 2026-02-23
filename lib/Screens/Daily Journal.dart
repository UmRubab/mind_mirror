import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class JournalHomePage extends StatefulWidget {
  const JournalHomePage({super.key});

  @override
  State<JournalHomePage> createState() => _JournalHomePageState();
}
class _JournalHomePageState extends State<JournalHomePage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final _searchController = TextEditingController();
  late User _currentUser;
  late DatabaseReference _userEntriesRef;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _userEntriesRef = _databaseRef.child('journal_entries/${_currentUser.uid}');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title:  Text('Daily Journal'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Your Thoughts Today',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple[800],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _userEntriesRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return  Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book,
                          size: 64,
                          color: Colors.purple[200],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No entries yet\nTap + to add your first entry',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.purple[400],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final entriesMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final entries = entriesMap.entries.toList();

                // Sort by date (newest first)
                entries.sort((a, b) => b.value['date'].compareTo(a.value['date']));

                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entryKey = entries[index].key;
                    final entry = entries[index].value;
                    return _buildJournalCard(entry, entryKey);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditEntryDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildJournalCard(Map entry, String entryKey) {
    final date = DateTime.parse(entry['date']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);
    final formattedTime = DateFormat('h:mm a').format(date);

    return GestureDetector(
      onTap: () => _showAddEditEntryDialog(entry, entryKey: entryKey),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        color: Colors.purple[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  entry['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry['content'],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddEditEntryDialog(Map? entry, {String? entryKey}) {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController(text: entry?['title'] ?? '');
    final _contentController = TextEditingController(text: entry?['content'] ?? '');
    final _dateController = TextEditingController(
      text: entry != null
          ? DateFormat('MMM dd, yyyy').format(DateTime.parse(entry['date']))
          : DateFormat('MMM dd, yyyy').format(DateTime.now()),
    );
    DateTime _selectedDate = entry != null
        ? DateTime.parse(entry['date'])
        : DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.purple[50],
          title: Text(
            entry == null ? 'New Journal Entry' : 'Edit Entry',
            style: TextStyle(color: Colors.purple[800]),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(color: Colors.teal[700]),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal[700]!),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Colors.purple,
                                onPrimary: Colors.white,
                                surface: Colors.teal[100]!,
                                onSurface: Colors.black,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.purple,
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                          _dateController.text =
                              DateFormat('MMM dd, yyyy').format(pickedDate);
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          labelStyle: TextStyle(color: Colors.teal[700]),
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            color: Colors.purple[400],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Your thoughts',
                      labelStyle: TextStyle(color: Colors.teal[700]),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.teal[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.teal[700]!),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please write something';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.purple[600]),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newEntry = {
                    'title': _titleController.text,
                    'content': _contentController.text,
                    'date': _selectedDate.toIso8601String(),
                  };

                  if (entry == null) {
                    _userEntriesRef.push().set(newEntry);
                  } else {
                    _userEntriesRef.child(entryKey!).update(newEntry);
                  }

                  Navigator.pop(context);
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
            if (entry != null)
              TextButton(
                onPressed: () {
                  _userEntriesRef.child(entryKey!).remove();
                  Navigator.pop(context);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red[600]),
                ),
              ),
          ],
        );
      },
    );
  }
}