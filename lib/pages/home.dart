// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:taskapolis/pages/Settings.dart';
import 'package:taskapolis/pages/about.dart';
import 'package:taskapolis/pages/addTask.dart';
import 'package:taskapolis/pages/auth.dart';

import 'package:taskapolis/pages/editTask.dart';
import 'package:taskapolis/pages/help.dart';
import 'package:taskapolis/pages/search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

List<String> list = <String>['One', 'Two', 'Three', 'Four'];

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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
              title: Center(
                child: Text(
                    'Hello ${FirebaseAuth.instance.currentUser!.displayName?.split(" ")[0]}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                    )),
              ),
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
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TASKAPOLIS',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontFamily: 'Space Grotesk',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FirebaseAuth.instance.currentUser!.displayName!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontSize: 16,
                            // fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          '${FirebaseAuth.instance.currentUser!.email}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: const Text('Import/Export Data',
                  style: TextStyle(fontFamily: 'Inter')),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  SettingsPage()),
                );
                // Update the state of the app
                // ...
                // Then close the drawer
              },
            ),
            ListTile(
              title: const Text('Help'),
              onTap: () {
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => HelpPage()),
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
                Navigator.push(context, 
                MaterialPageRoute(builder: (context) => AboutAppPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              // image opacity
              colorFilter: ColorFilter.mode(
                  Color.fromARGB(168, 0, 0, 0), BlendMode.luminosity),
              image: AssetImage('assets/images/bg1.jpg'),
              fit: BoxFit.cover),
          // iamge opacity
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              .where('uid', isEqualTo: userId)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // if empty show empty message
            if (snapshot.data!.docs.isEmpty) {
              return Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Add a task to ',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onBackground,
                      )),
                  Text(selectedFilter,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      )),
                ],
              ));
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

              // Assuming 'category' is the field name in your Firestore document
              String? taskCategory = data['category'];

              // Replace 'desiredCategory' with the category you want to filter
              if (selectedFilter == "All") {
                DateTime? taskDate = data['timestamp'] != null
                    ? (data['timestamp'] as Timestamp).toDate()
                    : null;
                bool isToday = taskDate != null &&
                    now.year == taskDate.year &&
                    now.month == taskDate.month &&
                    now.day == taskDate.day &&
                    now.hour == taskDate.hour &&
                    now.minute == taskDate.minute;

                bool isOverdue = taskDate != null &&
                    taskDate.isBefore(DateTime(
                        now.year, now.month, now.day, now.hour, now.minute));
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
              } else {
                if (taskCategory == selectedFilter) {
                  DateTime? taskDate = data['timestamp'] != null
                      ? (data['timestamp'] as Timestamp).toDate()
                      : null;
                  bool isToday = now.year == taskDate!.year &&
                      now.month == taskDate.month &&
                      now.day == taskDate.day;
                  bool isOverdue = taskDate.isBefore(DateTime(now.year, now.month, now.day));
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
              }
              if (todayTasks.isEmpty &&
                  overdueTasks.isEmpty &&
                  laterTasks.isEmpty &&
                  completedTasks.isEmpty) {
                return Center(
                  child: Text('Add a task to $selectedFilter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      )),
                );
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
                  return Container(
                    height: 50,
                    color: Colors.transparent,
                  );
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      selected: selectedFilter == 'Educational',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      label: const Text('Educational'),
                      onSelected: (bool value) {
                        setState(() {
                          selectedFilter = 'Educational';
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      selected: selectedFilter == 'Health',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      label: const Text('Health'),
                      onSelected: (bool value) {
                        setState(() {
                          selectedFilter = 'Health';
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      selected: selectedFilter == 'Finance',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      label: const Text('Finance'),
                      onSelected: (bool value) {
                        setState(() {
                          selectedFilter = 'Finance';
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      selected: selectedFilter == 'Family',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      label: const Text('Family'),
                      onSelected: (bool value) {
                        setState(() {
                          selectedFilter = 'Family';
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      selected: selectedFilter == 'Social',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      label: const Text('Social'),
                      onSelected: (bool value) {
                        setState(() {
                          selectedFilter = 'Social';
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      selected: selectedFilter == 'Other',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      label: const Text('Other'),
                      onSelected: (bool value) {
                        setState(() {
                          selectedFilter = 'Other';
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
            MaterialPageRoute(
                builder: (context) =>
                    const AddTask()), // Replace 'AddTaskPage' with the actual class name of your "Add Task" page
          );
        },
        label: const Row(
          children: [Icon(Icons.add), SizedBox(width: 5), Text("Add Task")],
        ),
      ),
    );
    
  }

bool showEditSuccessMessage = false;
  // Function to show a success message dialog
  void showSuccessEdit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 0, 0, 0),
          // Background color of the alert dialog
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
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
          // Adjust vertical padding
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(
                    255, 62, 172, 148), // Button text color
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

  // Function to delete a task
Future<void> _deleteTask(String taskId) async {
  try {
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
  } catch (e) {
    // ignore: avoid_print
    print('Error deleting task: $e');
  }
}

  void _showDeleteConfirmationDialog(String taskId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete this task?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () {
              _deleteTask(taskId);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Widget _buildTaskListItem(
  DocumentSnapshot document, Map<String, dynamic> data) {
  return GestureDetector(
    onTap: () async {
      // Navigate to the EditTaskPage with the animation
      bool? edited = await Navigator.of(context).push(
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

      if (edited == true) {
        // Show the success alert when returning from EditTaskPage
        showSuccessEdit();
      }
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
            trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data['timestamp'] != null && data['timestamp'] != ''
                    ? '${(data['timestamp'] as Timestamp).toDate().day}/${(data['timestamp'] as Timestamp).toDate().month}'
                    : '',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red, // Change the icon color as needed
                ),
                onPressed: () {
                  _showDeleteConfirmationDialog(document.id);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}