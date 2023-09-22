import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskapolis/pages/home.dart';
import 'package:taskapolis/reuseable_wdigets/reuseable_widget.dart';

class signUpScreen extends StatefulWidget {
  const signUpScreen({super.key});

  @override
  State<signUpScreen> createState() => _signUpScreenState();
}

class _signUpScreenState extends State<signUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Sign Up",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration:
                BoxDecoration(color: Color.fromARGB(255, 211, 229, 255)),
            child: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
              child: Column(children: <Widget>[
                SizedBox(height: 20),
                reuseableTextField("Enter Name", Icons.person_2_outlined, false,
                    TextEditingController()),
                SizedBox(height: 20),
                reuseableTextField("Enter Email", Icons.email_outlined, false,
                    _emailTextController),
                SizedBox(height: 20),
                reuseableTextField("Password", Icons.lock_outline, true,
                    _passwordTextController),
                SizedBox(height: 20),
                reuseableTextField("Confirm Password", Icons.lock_outline, true,
                    TextEditingController()),
                SizedBox(height: 20),
                singInSignUpButton(context, false, () {
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                      .then((value) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                    return null;
                  }).onError((error, stackTrace) {
                    print(error.toString());
                  });
                }),
              ]),
            ))));
  }
}
