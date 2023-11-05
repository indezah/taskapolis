// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskapolis/pages/home.dart';
import 'package:taskapolis/pages/signup.dart';
import 'package:taskapolis/reuseable_wdigets/reuseable_widget.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void signIn() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      Navigator.pop(context);
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        incorrectCredentialsMessage();
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void wrongPasswordMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              'Incorrect Password',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void incorrectCredentialsMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: const Text('Sign In Failed'),
            content: const Text('Incorrect Email or Password'),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                ),
                child: const Text('Try Again'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ]);
      },
    );
  }

  bool passenable = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
            ),
            child: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height * 0.15, 20, 0),
              child: Column(children: <Widget>[
                logoWidget("assets/images/logo.png"),
                const SizedBox(height: 20),
                const Text(
                  "TASKAPOLIS",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Space Grotesk'),
                ),
                const SizedBox(height: 20),
                const Text("Sign in to get started",
                    style: TextStyle(fontSize: 16, fontFamily: 'Inter')),
                const SizedBox(height: 20),
                reuseableTextField("Email", Icons.email_outlined, false,
                    emailController, context),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: passenable,
                  enableSuggestions: passenable,
                  autocorrect: passenable,
                  cursorColor: Theme.of(context).colorScheme.onBackground,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "Password",
                    // prefixIcon: Icon(icon),
                    labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground),
                    // filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        passenable
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                      onPressed: () {
                        setState(() {
                          passenable = !passenable;
                        });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.text,
                ),
                // reuseableTextField("Password", Icons.lock_outline, true,
                //     passwordController, context

                const SizedBox(height: 20),
                signInSignUpButton(context, true, signIn),
                const SizedBox(height: 20),
                signUpOption()
              ]),
            ))));
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have account?",
            style:
                TextStyle(color: Theme.of(context).colorScheme.onBackground)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const signUpScreen()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(
                color: Color.fromARGB(255, 5, 84, 255),
                fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
