
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../Authentication/LoginPage.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final auth = FirebaseAuth.instance;
  final dbRef = FirebaseDatabase.instance.ref('users');
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  Map<String, dynamic>? userData;
  bool isLoading = true;
  File? _profileImage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        final snapshot = await dbRef.child(user.uid).get();
        if (snapshot.exists) {
          setState(() {
            userData = Map<String, dynamic>.from(snapshot.value as Map);
            _nameController.text = userData?['name'] ?? '';
            _emailController.text = userData?['email'] ?? '';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = auth.currentUser;
        if (user != null) {
          setState(() {
            _isEditing = true;
          });

          // Update profile image if selected
          String? imageUrl;
          if (_profileImage != null) {
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('profile_images')
                .child('${user.uid}.jpg');

            await storageRef.putFile(_profileImage!);
            imageUrl = await storageRef.getDownloadURL();
          }

          // Update user data in Realtime Database
          await dbRef.child(user.uid).update({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            if (imageUrl != null) 'profileImage': imageUrl,
          });

          // Update email in Firebase Auth if changed
          if (_emailController.text.trim() != user.email) {
            await user.updateEmail(_emailController.text.trim());
          }

          // Refresh data
          await fetchUserData();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      } finally {
        setState(() {
          _isEditing = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (userData?['profileImage'] != null
                          ? NetworkImage(userData!['profileImage'] as String)
                          : const AssetImage('images/default_profile.jpg')) as ImageProvider,
                      child: _profileImage == null && userData?['profileImage'] == null
                          ? const Icon(Icons.camera_alt, size: 30)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your email' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isEditing ? null : _updateProfile,
              child: _isEditing
                  ? const CircularProgressIndicator()
                  : const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
          ),
        ],
      ),
      body:  SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: userData?['profileImage'] != null
                    ? NetworkImage(userData!['profileImage'] as String)
                    : const AssetImage('images/default_profile.jpg') as ImageProvider,
                child: userData?['profileImage'] == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              userData?['name'] ?? 'No Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              userData?['email'] ?? 'No Email',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            _buildInfoCard(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(Icons.person, 'Username', userData?['name'] ?? 'Not set'),
            const Divider(),
            _buildInfoRow(Icons.email, 'Email', userData?['email'] ?? 'Not set'),
            const Divider(),
            _buildInfoRow(Icons.calendar_today, 'Member since',
                'Joined ${DateTime.now().toString().substring(0, 10)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/*
import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mind_mirror/Authentication/LoginPage.dart';
import 'package:mind_mirror/theme/newtheme.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final auth = FirebaseAuth.instance;
  final dbRef = FirebaseDatabase.instance.ref('users');
  Map<String, dynamic>? userData;
  bool isLoading = true;
// Add this method to your _UserProfilePageState class
  Future<void> _uploadProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        final user = auth.currentUser;
        if (user != null) {
          setState(() {
            isLoading = true;
          });

          // Upload to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${user.uid}.jpg');

          await storageRef.putFile(File(pickedFile.path));
          final imageUrl = await storageRef.getDownloadURL();

          // Update Realtime Database
          await dbRef.child(user.uid).update({
            'profileImage': imageUrl,
          });

          // Refresh UI
          await fetchUserData();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        final snapshot = await dbRef.child(user.uid).get();
        if (snapshot.exists) {
          setState(() {
            userData = Map<String, dynamic>.from(snapshot.value as Map);
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Add edit functionality here
            },
          ),
        ],
      ),
      body:  SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
              GestureDetector(
                onTap: _uploadProfileImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: userData?['profileImage'] != null
                      ? NetworkImage(userData!['profileImage'] as String)
                      : const AssetImage('images/default_profile.jpg') as ImageProvider,
                  child: userData?['profileImage'] == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              userData?['name'] ?? 'No Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              userData?['email'] ?? 'No Email',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            _buildInfoCard(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add logout functionality
                auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text('Logout'),
            ),
      ],
        ),
    ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(Icons.person, 'Username', userData?['name'] ?? 'Not set'),
            const Divider(),
            _buildInfoRow(Icons.email, 'Email', userData?['email'] ?? 'Not set'),
            const Divider(),
            _buildInfoRow(Icons.calendar_today, 'Member since',
                'Joined ${DateTime.now().toString().substring(0, 10)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
*/
/*class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final List<String> quotes = [
    "You are stronger than you think.",
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
    "Be here now.",
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

  @override
  void initState() {
    super.initState();
    getRandomQuote();
  }

  void getRandomQuote() {
    final random = Random();
    selectedQuote = quotes[random.nextInt(quotes.length)];
  }
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Affirmation'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
     body: Column(children: [

     ],),
    );
  }
}*/