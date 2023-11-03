import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskapolis/pages/auth.dart';
import 'package:taskapolis/pages/signin.dart';
import 'package:taskapolis/pages/help.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showProfileDialog() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('TASKOPOLIS'),
        actions: <Widget>[
          IconButton(
            icon: CircleAvatar(
              backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with your image url
            ),
            onPressed: _showProfileDialog,
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('Username'), // Replace with actual username
              accountEmail: Text('email@example.com'), // Replace with actual email
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with your image url
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Add your settings logic here
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Log Out'),
              onTap: () {
<<<<<<< Updated upstream
                // Add your log out logic here
=======
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Sign Out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                );
              },
            ),
            ListTile(
              title: const Text('About'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                // Navigator.pop(context);
>>>>>>> Stashed changes
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Wrap(
            spacing: 8.0,
            children: <Widget>[
              FilterChip(
                label: Text('All'),
                selected: true,
                onSelected: (bool value) {
                  print('All');
                },
              ),
              FilterChip(
                label: Text('Today'),
                onSelected: (bool value) {
                  print('Today');
                },
              ),
              FilterChip(
                label: Text('Work'),
                onSelected: (bool value) {
                  print('Work');
                },
              ),
              FilterChip(
                label: Text('Shopping'),
                onSelected: (bool value) {
                  print('Shopping');
                },
              ),
              FilterChip(
                label: Text('Anytime'),
                onSelected: (bool value) {
                  print('Anytime');
                },
              ),
            ],
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(child: ListTile(title: Text('Item ${index + 1}'))); // Replace with your data
              },
            ),
          ),
        ],
      ),
    );
  }
}