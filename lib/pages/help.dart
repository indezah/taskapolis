import 'dart:ui';
import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
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
                  icon: const Icon(Icons.troubleshoot),
                  onPressed: () {
                    // Implement search functionality here
                  },
                ),
              ],
            ),
          )),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Text('Help'),
          ],
        ),
      ),
    );
  }
}
