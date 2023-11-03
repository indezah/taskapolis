import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';


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
        child: ListView(
          children: const <Widget>[
            Card(
              child: ListTile(
                title: Text('Having Trouble on Taskopolis?'),
                subtitle: Text(
                  "Don't worry, we're here to help!\n,"
                  "Here are some FAQ's to get you started, but if these don't help, feel free to contact us",
                ),
              ),
            ),
            Gap(20),
            ExpansionTile(
              title: Text('Where do i start?'),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'To get started with Taskopolis, follow these simple steps:\n'
                    '1. Download and install the Taskopolis app from your device\'s app store.\n'
                    '2. Create an account or log in if you already have one.\n'
                    '3. Once logged in, you\'ll have access to your personalized to-do list.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            Gap(10),
            ExpansionTile(
              title: Text('How do i organize tasks?'),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Taskopolis offers various ways to keep your tasks organized:\n"
                    "Create categories or lists to group related tasks together.\n"
                    "Assign labels to tasks for easy identification.\n"
                    "Use drag-and-drop to rearrange your tasks as needed.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            Gap(10),
            ExpansionTile(
              title: Text("These FAQ's didn't help"),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "If you encounter any issues, check out our troubleshooting section for solutions to common problems. If you need further assistance, don't hesitate to contact our support team at support@taskopolis.com.",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
