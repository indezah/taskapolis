// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskapolis/pages/Settings.dart';
import 'package:taskapolis/pages/addTask.dart';
import 'package:taskapolis/pages/auth.dart';
import 'package:taskapolis/pages/editTask.dart';
import 'package:taskapolis/pages/search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
  String selectedChip = 'All'; // Initialize it with 'All'

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
              title: const Text('Todo List'),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Implement search functionality here
                    // Show search screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchScreen(
                              currentUserId:
                                  FirebaseAuth.instance.currentUser!.uid)),
                    );
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
              title: const Text('Item 1'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                // Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Settings'),
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
              title: const Text('Sign Out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthPage()),
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
              .collection('tasks')
              .where('uid', isEqualTo: userId)
              .where('category',
                  isEqualTo: selectedFilter == "All"
                      ? ["Personal", "Work", "Educational"]
                      : selectedFilter)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }

            // if empty show empty message
            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No tasks found'),
              );
            }

            // Sort tasks into "Today" and "Later"

            List<DocumentSnapshot> overdueTasks = [];
            List<DocumentSnapshot> todayTasks = [];
            List<DocumentSnapshot> completedTasks = [];
            List<DocumentSnapshot> laterTasks = [];
            DateTime now = DateTime.now();
            completedTasks.clear();
            todayTasks.clear();
            laterTasks.clear();
            overdueTasks.clear();

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
              bool isOverdue = taskDate != null &&
                  taskDate.isBefore(DateTime(now.year, now.month, now.day));
              bool isCompleted = data['completed'];
              if (isCompleted) {
                completedTasks.add(document);
              } else {
                if (isOverdue) {
                  overdueTasks.add(document);
                } else if (isToday) {
                  todayTasks.add(document);
                } else {
                  laterTasks.add(document);
                }
              }
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ListView.separated(
                itemCount: overdueTasks.length +
                    todayTasks.length +
                    laterTasks.length +
                    completedTasks.length +
                    4, // Add four for headers
                separatorBuilder: (BuildContext context, int index) {
                  return Container();
                },
                itemBuilder: (context, index) {
                  int overdueIndex = 0;
                  int todayIndex =
                      overdueTasks.isNotEmpty ? overdueTasks.length + 1 : 0;
                  int laterIndex = todayTasks.isNotEmpty
                      ? todayIndex + todayTasks.length + 1
                      : todayIndex;
                  int completedIndex = laterTasks.isNotEmpty
                      ? laterIndex + laterTasks.length + 1
                      : laterIndex;

                  if (index == overdueIndex && overdueTasks.isNotEmpty) {
                    return const ListTile(
                      title: Text(
                        'Overdue',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    );
                  } else if (index == todayIndex && todayTasks.isNotEmpty) {
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
                  } else if (index > overdueIndex &&
                      index <= overdueIndex + overdueTasks.length) {
                    DocumentSnapshot document =
                        overdueTasks[index - overdueIndex - 1];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return _buildTaskListItem(document, data);
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
                  return Container(); // Return an empty container instead of null
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
                      selected: selectedFilter == 'All',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      label: const Text('All'),
                      onSelected: (bool value) {
                        setState(() {
                          selectedFilter = 'All';
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      selected: selectedFilter == 'Personal',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      label: const Text('Personal'),
                      onSelected: (bool value) {
                        setState(() {
                          selectedFilter = 'Personal';
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      selected: selectedFilter == 'Work',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      label: const Text('Work'),
                      onSelected: (bool value) {
                        setState(() {
                          selectedFilter = 'Work';
                        });
                      },
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
            MaterialPageRoute(builder: (context) => const AddTask()),
          );
        },
        label: const Row(
            children: [Icon(Icons.add), SizedBox(width: 5), Text("Add Task")]),
      ),
    );
  }

  // Function to show a success message dialog
  void showSuccessEdit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(
              255, 0, 0, 0), // Background color of the alert dialog
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
          ),
          content: const SingleChildScrollView(
            // Wrap content in SingleChildScrollView
            child: Column(
              children: [
                Text(
                  'Task edited successfully',
                  style: TextStyle(
                    color: Color.fromARGB(
                        255, 255, 255, 255), // Content text color
                    fontSize: 18.0, // Content text size
                  ),
                ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 10.0), // Adjust vertical padding
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(
                    255, 62, 172, 148), // Button background color
                onPrimary: Colors.white, // Button text color
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16.0, // Button text size
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTaskListItem(
      DocumentSnapshot document, Map<String, dynamic> data) {
    print(data['timestamp']);
    return GestureDetector(
        onTap: () async {
          // Navigate to the EditTaskPage with the animation
          await Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return EditTaskPage(taskId: document.id);
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(
                  CurveTween(curve: curve),
                );

                var offsetAnimation = animation.drive(tween);
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );

          // Show the success alert when returning from EditTaskPage
          showSuccessEdit();
        },
        child: Hero(
            tag: 'task_${document.id}', // Use a unique tag for each task
            child: Container(
              // add background color to task
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(0),
              ),
              // margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: ListTile(
                  leading: Checkbox(
                    // change checkbox border color according to priority
                    // grey checkbox if task is completed
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),

                    side: MaterialStateBorderSide.resolveWith(
                        (states) => BorderSide(
                            width: 1.0,
                            color: data['completed']
                                ? Theme.of(context).colorScheme.onBackground
                                : data['priority'] == "High"
                                    ? Colors.red
                                    : data['priority'] == "Medium"
                                        ? Colors.orange
                                        : Colors.grey)),

// grey checkbox if task is completed
                    fillColor: MaterialStateProperty.resolveWith((states) =>
                        data['completed']
                            ? Theme.of(context).colorScheme.onBackground
                            : null),
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
                  // subtitle: Text(
                  //   data['category'],
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     color: Theme.of(context).colorScheme.onBackground,
                  //   ),
                  // ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        data['timestamp'] != null && data['timestamp'] != ''
                            ? DateFormat('MMM d').format(
                                (data['timestamp'] as Timestamp).toDate())
                            : '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ],
                  )),
            )));
  }
}
