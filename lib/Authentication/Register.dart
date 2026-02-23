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
  final  dbRef = FirebaseDatabase.instance.ref('users');
  @override
  void registerUser ()async {
    try{
  UserCredential userCredential = await auth.createUserWithEmailAndPassword(
  email: email.text.trim(),
  password: password.text.trim());
  await dbRef.child('users').push().set({
    '_formKey':_formKey.hashCode,
  'name':name.text.trim(),
  'email':email.text.trim(),
  'password':password.text.trim(),
  });
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("Account is created")));
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) =>LoginPage(),
    ),
  );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Error occurred")),
      );
    }


  catch(e){
  print("error is $e");
  }
}

  @override
  Widget build(BuildContext context) {
    final mediaquery=MediaQuery.of(context).size;
    final hieght=mediaquery.height;
    final width=mediaquery.width;

    return Scaffold(
      body: Container(
        height: hieght,
        width: width,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('images/background.jpg'),
          fit: BoxFit.fill),
        ),

        child: Center(
          child:Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),

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
                    CircleAvatar(
                      radius:40,
                      backgroundImage: AssetImage('images/logoo.jpg'),
                    ),
                    SizedBox(height: 10,),
                    Text('SignUp Here!',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
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
                      onPressed:registerUser,
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