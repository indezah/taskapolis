import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taskapolis/pages/Settings.dart';
import 'package:taskapolis/pages/addTask.dart';
import 'package:taskapolis/pages/auth.dart';
import 'package:taskapolis/pages/signin.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

List<String> list = <String>['One', 'Two', 'Three', 'Four'];

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String selectedCategory = 'Personal';
  String selectedFilter = 'All';
  final String userId =
      FirebaseAuth.instance.currentUser!.uid; // Get the current user's ID

  bool showTodaySection = false; // Added to control section header display

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
              title: Text('Todo List'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Implement search functionality here
                  },
                ),
              ],
            ),
          )),
        ),
      ),
      drawer: Drawer(
        // Implement navigation drawer here
        // material3 drawer

        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                ),
                child: Text(
                  'Taskapolis',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
                // Update the state of the app
                // ...
                // Then close the drawer
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Sign Out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AuthPage()),
                );
              },
            )
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          //   gradient: LinearGradient(
          //       colors: [
          //         const Color(0xFF3366FF),
          //         Color.fromARGB(255, 102, 0, 255),
          //       ],
          //       begin: const FractionalOffset(0.0, 0.0),
          //       end: const FractionalOffset(1.0, 0.0),
          //       stops: [0.0, 1.0],
          //       tileMode: TileMode.clamp),
          image: DecorationImage(
              // image opacity
              colorFilter: ColorFilter.mode(
                  Color.fromARGB(168, 0, 0, 0), BlendMode.luminosity),
              image: AssetImage("assets/images/bg.jpg"),
              fit: BoxFit.cover),
          // iamge opacity
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('tasks')
              .orderBy('priority', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            // if empty show empty message
            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No tasks found'),
              );
            }

            // Sort tasks into "Today" and "Later"

            List<DocumentSnapshot> todayTasks = [];
            List<DocumentSnapshot> completedTasks = [];

            List<DocumentSnapshot> laterTasks = [];
            DateTime now = DateTime.now();
            completedTasks.clear();
            todayTasks.clear();
            laterTasks.clear();

            for (DocumentSnapshot document in snapshot.data!.docs) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              DateTime? taskDate = data['timestamp'] != null
                  ? (data['timestamp'] as Timestamp).toDate()
                  : null;
              bool isToday = taskDate != null &&
                  now.year == taskDate.year &&
                  now.month == taskDate.month &&
                  now.day == taskDate.day;
              bool isCompleted = data['completed'];
              if (isCompleted) {
                completedTasks.add(document);
              } else {
                if (isToday) {
                  todayTasks.add(document);
                } else {
                  laterTasks.add(document);
                }
              }
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ListView.separated(
                itemCount: todayTasks.length +
                    laterTasks.length +
                    completedTasks.length +
                    3, // Add three for headers
                separatorBuilder: (BuildContext context, int index) {
                  return Container();
                },
                itemBuilder: (context, index) {
                  print('index: $index');
                  print('todayTasks.length: ${todayTasks.length}');
                  print('laterTasks.length: ${laterTasks.length}');
                  print('completedTasks.length: ${completedTasks.length}');
                  int todayIndex = 0;
                  int laterIndex =
                      todayTasks.isNotEmpty ? todayTasks.length + 1 : 0;
                  int completedIndex = laterTasks.isNotEmpty
                      ? laterIndex + laterTasks.length + 1
                      : laterIndex;

                  if (index == todayIndex && todayTasks.isNotEmpty) {
                    return const ListTile(
                      title: Text(
                        'Today',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  } else if (index == laterIndex && laterTasks.isNotEmpty) {
                    return const ListTile(
                      title: Text(
                        'Later',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  } else if (index == completedIndex &&
                      completedTasks.isNotEmpty) {
                    return const ListTile(
                      title: Text(
                        'Completed',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  } else if (index > todayIndex &&
                      index <= todayIndex + todayTasks.length) {
                    DocumentSnapshot document =
                        todayTasks[index - todayIndex - 1];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return _buildTaskListItem(document, data);
                  } else if (index > laterIndex &&
                      index <= laterIndex + laterTasks.length) {
                    DocumentSnapshot document =
                        laterTasks[index - laterIndex - 1];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return _buildTaskListItem(document, data);
                  } else if (index > completedIndex &&
                      index <= completedIndex + completedTasks.length) {
                    DocumentSnapshot document =
                        completedTasks[index - completedIndex - 1];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return _buildTaskListItem(document, data);
                  }
                  return null;
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration:
            BoxDecoration(color: Theme.of(context).colorScheme.background),
        height: 80.0,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      label: Text('All'),
                      onSelected: (bool value) {},
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      label: Text('Work'),
                      onSelected: (bool value) {},
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      label: Text('Personal'),
                      onSelected: (bool value) {},
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      label: Text('Shopping'),
                      onSelected: (bool value) {},
                    ),
                  ),
                  // Add more chips here
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTask()),
          );
        },
        label: Row(
            children: [Icon(Icons.add), SizedBox(width: 5), Text("Add Task")]),
      ),
    );
  }

  Widget _buildTaskListItem(
      DocumentSnapshot document, Map<String, dynamic> data) {
    // Build and return the task list item here
    print(data['title']);
    return Container(
      // margin between each task
      // border radius
      // decoration: BoxDecoration(
      //   color: Color.fromARGB(255, 255, 255, 255),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Color.fromRGBO(0, 0, 0, 0.1),
      //       blurRadius: 10,
      //       offset: Offset(0, 5),
      //     ),
      //   ],
      //   borderRadius: BorderRadius.circular(10),
      // ),
      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Card(
//blurred translucent cards
        color: Theme.of(context).colorScheme.background.withOpacity(1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        //
        child: ListTile(
            leading: Checkbox(
              value: data['completed'],
              onChanged: (bool? value) {
                // Update the completed field with the new value
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('tasks')
                    .doc(document.id)
                    .update({'completed': value});
              },
            ),
            title: Text(data['title'],
                style: TextStyle(
                  // fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                )),
            subtitle: Text(
              'Today',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  data['priority'].toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                Text(
                  'Priority',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
