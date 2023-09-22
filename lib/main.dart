import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taskapolis/firebase_options.dart';

import 'package:taskapolis/pages/signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 0, 76, 255)),
        useMaterial3: true,
      ),
      home: SigninScreen(),
    );
  }
}
