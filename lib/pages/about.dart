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
                child: Text('Help',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                    )),
              ),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.report),
                  onPressed: () {
                    // Implement search functionality here
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
                'App Name: Your App Name',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Version: 1.0.0',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                'Description:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'This is a great app that provides many features to its users.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                'Developer:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Your Name',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
