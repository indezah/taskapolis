import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taskapolis/pages/auth.dart';
import 'package:taskapolis/pages/signin.dart';
import 'package:taskapolis/pages/addTask.dart';

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
        preferredSize: Size(MediaQuery.of(context).size.width, 64),
      ),
      drawer: Drawer(
          // Implement navigation drawer here
          ),
      body: Container(
        decoration: BoxDecoration(
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
              colorFilter: new ColorFilter.mode(
                  Color.fromARGB(168, 0, 0, 0), BlendMode.luminosity),
              image: AssetImage("assets/images/bg.jpg"),
              fit: BoxFit.cover),
          // iamge opacity
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
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
              return Center(
                child: Text('No tasks found'),
              );
            }

            // Sort tasks into "Today" and "Later"
            List<DocumentSnapshot> todayTasks = [];
            List<DocumentSnapshot> laterTasks = [];
            DateTime now = DateTime.now();

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

              if (isToday) {
                todayTasks.add(document);
              } else {
                laterTasks.add(document);
              }
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ListView.separated(
                itemCount: todayTasks.length +
                    laterTasks.length +
                    2, // Add two for headers
                separatorBuilder: (BuildContext context, int index) {
                  return Container();
                },
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ListTile(
                      title: Text(
                        'Today',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  } else if (todayTasks.isNotEmpty &&
                      index == todayTasks.length + 1) {
                    return ListTile(
                      title: Text(
                        'Later',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  } else if (index <= todayTasks.length) {
                    // Display tasks for "Today"
                    DocumentSnapshot document = todayTasks[index - 1];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return _buildTaskListItem(document, data);
                  } else {
                    // Display tasks for "Later"
                    DocumentSnapshot document =
                        laterTasks[index - todayTasks.length - 2];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return _buildTaskListItem(document, data);
                  }
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            // boxShadow: [
            //   BoxShadow(
            //     color: Color.fromRGBO(0, 0, 0, 0.2),
            //     blurRadius: 40,
            //     offset: Offset(0, -5),
            //   ),
            // ],
            // transparetn
            color: Theme.of(context).colorScheme.background),
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
        MaterialPageRoute(builder: (context) => AddTask()), // Replace 'AddTaskPage' with the actual class name of your "Add Task" page
    );
  },
  label: Row(
    children: [Icon(Icons.add), SizedBox(width: 5), Text("Add Task")],
  ),
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
