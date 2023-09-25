
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taskapolis/pages/auth.dart';
import 'package:taskapolis/reuseable_wdigets/reuseable_widget.dart';

class signUpScreen extends StatefulWidget {
  const signUpScreen({super.key});

  @override
  State<signUpScreen> createState() => _signUpScreenState();
}

class _signUpScreenState extends State<signUpScreen> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _confirmPasswordTextController =
      TextEditingController();
  final TextEditingController _firstNameTextController =
      TextEditingController();
  final TextEditingController _lastNameTextController = TextEditingController();

  void signUp() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      if (_passwordTextController.text != _confirmPasswordTextController.text) {
        Navigator.pop(context);
        errorMessage('Passwords do not match', false);
        return;
      }
      var userCredentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailTextController.text,
              password: _passwordTextController.text);

      print('userCredentials: $userCredentials');
      await addUserDetails(
          userCredentials.user!.uid,
          _firstNameTextController.text.trim(),
          _lastNameTextController.text.trim(),
          _emailTextController.text.trim());

      Navigator.pop(context);
      Navigator.popUntil(context, (route) => route.isFirst);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      if (e.code == 'email-already-in-use') {
        errorMessage('The account already exists for that email.', true);
      }
    }
  }

  Future addUserDetails(
      String userid, String firstName, String lastName, String email) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userid);
    return userRef.set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    });
  }

  void errorMessage(String message, bool isUsed) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: const Text('Sign In Failed'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: isUsed ? const Text('Sign In') : const Text('Try Again'),
                onPressed: () {
                  // Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => SigninScreen()),
                  // );
                },
              ),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 195, 228, 255),
          elevation: 1,
          title: const Text(
            "Sign Up",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 211, 229, 255)),
            child: SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
              child: Column(children: <Widget>[
                const SizedBox(height: 20),
                reuseableTextField("Enter First Name", Icons.person_2_outlined,
                    false, _firstNameTextController),
                const SizedBox(height: 20),
                reuseableTextField("Enter Last Name", Icons.person_2_outlined,
                    false, _lastNameTextController),
                const SizedBox(height: 20),
                reuseableTextField("Enter Email", Icons.email_outlined, false,
                    _emailTextController),
                const SizedBox(height: 20),
                reuseableTextField("Password", Icons.lock_outline, true,
                    _passwordTextController),
                const SizedBox(height: 20),
                reuseableTextField("Confirm Password", Icons.lock_outline, true,
                    _confirmPasswordTextController),
                const SizedBox(height: 20),
                signInSignUpButton(context, false, signUp),
              ]),
            ))));
  }
}
