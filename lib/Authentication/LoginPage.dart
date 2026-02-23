import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Buttom navigationbar.dart';
import '../Screens/homePage.dart';
import 'ForgotPage.dart';
import 'Register.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('users');
  final auth =FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void loginUser() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      // Optionally fetch user name from database
      final snapshot = await dbRef.child(uid).get();
      String name = snapshot.child("name").value.toString();

      setState(() => _isLoading = false);

      // If login successful, show success and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage(),
      ));
    } on FirebaseAuthException catch (e) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${e.message}")),
        );
      }
    }

  @override
  Widget build(BuildContext context) {
    final mediaquery=MediaQuery.of(context).size;
    final height=mediaquery.height;
    final widht= mediaquery.width;
    return Scaffold(

      body: SingleChildScrollView(
        child: Expanded(
          child: Container(
            height: height,
            width: widht,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('images/background.jpg'),),
            ),
            child: Center(
              child:Container(
                height: 500,
                width: 400,
                color: Colors.transparent,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius:40,
                          backgroundImage: AssetImage('images/logoo.jpg'),
                      ),
                      SizedBox(height: 10,),
                      Text('Login Here',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: SizedBox(height: 10),
                      ),

                      TextFormField(
                        controller: emailController,
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
                        controller: passwordController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
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
                        onPressed: _isLoading ? null : loginUser,
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Login'),
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
                ),
            ),
          ),
        ),
      ),
    );
  }
}



