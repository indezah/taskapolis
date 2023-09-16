import 'package:flutter/material.dart';
import 'package:taskapolis/pages/home.dart';

void main() {
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
      home: HomePage(),
    );
  }
}
