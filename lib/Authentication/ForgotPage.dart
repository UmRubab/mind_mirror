import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mind_mirror/Authentication/LoginPage.dart';

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  final ec=TextEditingController();
  final DatabaseReference _dbref=FirebaseDatabase.instance.ref('users');
  final auth=FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 400,
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: ec,
                decoration: InputDecoration(

                    labelText: "Email",
                    hintText: "Enter Email"
                ),
              ),
              ElevatedButton(onPressed: (){
                auth.sendPasswordResetEmail(email: ec.text.toString())
                    .then((onvalue){
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Check Email"))
                  );
                })
                    .onError((error,stac){
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Something is Wrong $error"))
                  );
                });
              },
                child: Text("Reset Password "),),
              SizedBox(height: 10,),
              Text('Back to login'),
              TextButton(onPressed: (){
                Navigator.pop(context,MaterialPageRoute(builder: (context)=>LoginPage()));
              }, child: Icon(Icons.login)),
            ],
          ),
        ),
      ),
    );
  }
}