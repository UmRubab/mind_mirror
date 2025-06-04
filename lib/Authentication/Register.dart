import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'LoginPage.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}
class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final name=TextEditingController();
  final email=TextEditingController();
  final password=TextEditingController();
  final auth=FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('users');
  @override
  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      String userId = _dbRef.push().key!;
      await _dbRef.child(userId).set({
        'name': name.text.trim(),
        'email': email.text.trim(),
        'password': password.text.trim(), // Not secure in production
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful!')),
      );
      name.clear();
      email.clear();
      password.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,),
      body: Center(
        child:Card(
    elevation: 10,
        child: Container(
          height: 500,
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment:MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('SignUp Here!'),
                  SizedBox(height: 10,),
                  TextFormField(
                    controller: name,
                    decoration:  InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.teal,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black12,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        labelText: 'Name'),
                    validator: (value) =>
                    value!.isEmpty ? 'Enter your name' : null,
                  ),
                  SizedBox(height: 10,),
                  TextFormField(
                    controller: email,
                    decoration:InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.teal,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black12,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        labelText: 'Email'),
                    validator: (value) =>
                    value!.isEmpty ? 'Enter your email' : null,
                  ),
                  SizedBox(height: 10,),
                  TextFormField(
                    controller: password,
                    decoration:  InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.teal,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black12,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),

                        labelText: 'Password'),
                    obscureText: true,
                    validator: (value) =>
                    value!.length < 6 ? 'Password must be at least 8 characters' : null,
                  ),
                   SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registerUser,
                    child: Text('SignUp'),
                  ),
                  SizedBox(height: 10,),
                  Text('Already have an account?'),
                  TextButton(onPressed: (){
                    Navigator.pop(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                  }, child: Text('Login')),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}