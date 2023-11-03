import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskapolis/pages/addTask.dart';
import 'package:taskapolis/pages/editTask.dart'; // Import Firestore

// Sample Task class for demonstration
class Task {
  final String title;
  final String category;
  final String priority;

  bool completed;

  Task({
    required this.title,
    required this.category,
    required this.priority,
    required this.completed,
  });
}

class SearchScreen extends StatefulWidget {
  final String currentUserId; // Pass the current user's ID
  SearchScreen({required this.currentUserId});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedPriority = 'All';
  bool _showCompleted = false;

  // Firestore stream for tasks
  Stream<QuerySnapshot> _taskStream() {
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('uid', isEqualTo: widget.currentUserId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('Search and Filters'),
// searchbar in appbar
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            // border: OutlineInputBorder(),
            // labelText: 'Search',
            hintText: 'Search',
          ),
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
        ),
      ),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: TextField(
          //     controller: _searchController,
          //     decoration: InputDecoration(
          //       border: OutlineInputBorder(),
          //       labelText: 'Search',
          //     ),
          //     onChanged: (query) {
          //       setState(() {
          //         _searchQuery = query;
          //       });
          //     },
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(width: 20),
                    DropdownButton<String>(
                      value: _selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                      items: ['All', 'Work', 'Personal', 'Shopping']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Priority',
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    SizedBox(width: 20),
                    DropdownButton<String>(
                      value: _selectedPriority,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPriority = newValue!;
                        });
                      },
                      items: ['All', 'High', 'Medium', 'Low']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(children: [
            Checkbox(
              value: _showCompleted,
              onChanged: (bool? newValue) {
                setState(() {
                  _showCompleted = newValue!;
                });
              },
            ),
            Text('Show Completed'),
          ]),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _taskStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // or a loading indicator
                }

                // Map snapshot data to Task objects (similar to previous code)
                List<Task> tasks = snapshot.data!.docs.map((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  return Task(
                    title: data['title'],
                    category: data['category'],
                    priority: data['priority'],
                    completed: data['completed'],
                  );
                }).toList();

                // Filter tasks based on your criteria
                List<Task> filteredTasks = tasks.where((task) {
                  final bool categoryMatches = _selectedCategory == 'All' ||
                      task.category == _selectedCategory;
                  final bool priorityMatches = _selectedPriority == 'All' ||
                      task.priority == _selectedPriority;
                  final bool completedMatches =
                      _showCompleted || !task.completed;

                  return categoryMatches &&
                      priorityMatches &&
                      completedMatches &&
                      (task.title
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()));
                }).toList();

                // Display filtered tasks
                return ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final Task task = filteredTasks[index];
                    // get taskid as a string
                    final String taskid = snapshot.data!.docs[index].id;
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTaskPage(taskId: taskid),
                          ),
                        );
                      },
                      leading: Checkbox(
                        // change checkbox border color according to priority
                        // grey checkbox if task is completed
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),

                        side: MaterialStateBorderSide.resolveWith(
                            (states) => BorderSide(
                                width: 1.0,
                                color: task.completed
                                    ? Theme.of(context).colorScheme.onBackground
                                    : task.priority == "High"
                                        ? Colors.red
                                        : task.priority == "Medium"
                                            ? Colors.orange
                                            : Colors.grey)),

// grey checkbox if task is completed
                        fillColor: MaterialStateProperty.resolveWith((states) =>
                            task.completed
                                ? Theme.of(context).colorScheme.onBackground
                                : null),
                        value: task.completed,
                        onChanged: (bool? value) {
                          // Update the completed field with the new value
                          FirebaseFirestore.instance
                              .collection('tasks')
                              .doc(taskid)
                              .update({'completed': value});
                        },
                      ),
                      title: Text(task.title,
                          style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onBackground,
                          )),
                      subtitle: Row(
                        children: [
                          Text(task.category,
                              style: TextStyle(
                                fontSize: 12,
                                // fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              )),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
