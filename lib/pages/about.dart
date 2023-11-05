import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';


import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 64),
        child: Container(
          child: ClipRRect(
              child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              // transparent
              backgroundColor: Colors.transparent,
              title: Center(
                child: Text('About App',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                    )),
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.report),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Tac()),
                        );
                  },
                ),
              ],
            ),
          )),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Taskopolis',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Version: 0.1.0',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                'What are Taskopolis?:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "It's the most aesthetically pleasing To-Do Application you'll ever use. Creating tasks, putting remidners on them, organizing them by categories and even to edit them later on. Taskopolis is at your service.",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                'Developer:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Nisura\nSahan\nMaleesha\nRavindu\nVarsha",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Tac extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('By using the "Taskopolis" to-do list app, you agree to be bound by the following terms and conditions. If you do not agree with any part of these terms, please do not use the app.'),
              Gap(10),
              Text("1. Usage"),
              Gap(5),
              Text("Taskopolis is designed for personal use only. Users must be at least 13 years old to use the app. You are responsible for maintaining the confidentiality of your account and any login information. You may not use the app for any illegal or unauthorized purpose."),
              Gap(10),
              Text("2. Privacy"),
              Text("Your use of Taskopolis is subject to our Privacy Policy, which can be accessed through the app. By using the app, you consent to the collection and use of your information as described in the Privacy Policy."),
              Gap(10),
              Text("3. User-Generated Content"),
              Gap(5),
              Text("You are solely responsible for the content and tasks you input into Taskopolis. You grant Taskopolis a non-exclusive, worldwide license to use, display, and process your content for the purpose of providing and improving the app. You may not upload, share, or transmit content that is infringing, offensive, or violates the rights of others."),
              Gap(10),
              Text("4. Termination"),
              Gap(5),
              Text("Taskopolis reserves the right to terminate or suspend your account and access to the app at our discretion, with or without notice."),
              Gap(10),
              Text("5. Disclaimer of Warranty"),
              Gap(5),
              Text('Taskopolis is provided "as is" and "as available." We make no warranties regarding the accuracy, reliability, or suitability for a particular purpose of the app.'),
              Gap(10),
              Text("6. Limitation of Liability"),
              Text("Taskopolis is not liable for any indirect, incidental, special, or consequential damages resulting from your use of the app."),
              Gap(10),
              Text("7. Changes to Terms and Conditions"),
              Gap(5),
              Text("We may update or change these Terms and Conditions at our discretion. You are responsible for reviewing these terms periodically. Continued use of the app after changes constitute acceptance of the new terms."),
            ]
          ),
      ),
    );
  }
}
