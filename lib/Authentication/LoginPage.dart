import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mind_mirror/homepage.dart';

import 'ForgotPage.dart';
import 'Register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('users');
  final auth =FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _loginUser() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final snapshot = await _dbRef.get();

    bool found = false;

    if (snapshot.exists) {
      final data = snapshot.value as Map;

      data.forEach((key, value) {
        if (value['email'] == email && value['password'] == password) {
          found = true;
        }
      });
    }

    setState(() => _isLoading = false);

    if (found) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery=MediaQuery.of(context).size;
    final height=mediaquery.height;
    final widht= mediaquery.width;
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child:Card(
            elevation: 10,
        child:Container(
          height: 500,
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10,),
                Text('Login Here',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(height: 10),
                ),
        
                TextFormField(
                  controller: _emailController,
                  decoration:  InputDecoration(
                    prefixIcon: Icon(Icons.email),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color:Colors.teal,
        
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelText: 'Email'),
                  validator: (value) =>
                  value!.isEmpty ? 'Enter your email' : null,
        
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(height: 10,),
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.password),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color:Colors.teal,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 8) {
                      return 'Your password must be at least 8 characters long';
                    }
                    return null;
                  },
                ),
               SizedBox(height: 20,),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _loginUser();
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Homepage()),);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      child: Text('Login',style: TextStyle(color: Colors.white),),
                    ),
                      SizedBox(height: 10,),
                      Text("If you don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Register()));
                        },
                        child: Text(
                          'Sign up!',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(height: 10,),
                      TextButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder:(context)=>Forgot()));
                      },
                        child: Text("Forget Password?"),
                      )
                    ],
                  ),
            ),
          )
        ),
        ),
      ),
    );
  }
}



