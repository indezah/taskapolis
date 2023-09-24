import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void onFilterSelected(String filter) {
    setState(() {
      print(FirebaseAuth.instance.currentUser!.email);
      selectedFilter = filter;
    });
  }

  Future<void> addCategory() async {
    String newCategory = await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text('Add category'),
          content: TextField(
            controller: controller,
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );

    if (newCategory.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('categories')
          .add({'name': newCategory});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello Nisura',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        // search
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // showSearch(context: context, delegate: DataSearch());
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Text('Taskapolis'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Sign Out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AuthPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              // StreamBuilder<QuerySnapshot>(
              //   stream: FirebaseFirestore.instance
              //       .collection('users')
              //       .doc(userId)
              //       .collection('categories')
              //       .snapshots(),
              //   builder: (BuildContext context,
              //       AsyncSnapshot<QuerySnapshot> snapshot) {
              //     if (snapshot.hasError) {
              //       return Text('Something went wrong');
              //     }

              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return CircularProgressIndicator();
              //     }

              //     List categories =
              //         snapshot.data!.docs.map((DocumentSnapshot doc) {
              //       Map<String, dynamic> data =
              //           doc.data() as Map<String, dynamic>;
              //       return data['name'];
              //     }).toList();

              //     // get logged in user's email
              //     print(FirebaseAuth.instance.currentUser!.email);
              //     print('categories: $categories');

              //     categories.add('Add category');

              //     return DropdownButton<String>(
              //       value: selectedCategory,
              //       items: const [
              //         DropdownMenuItem(
              //             value: 'Personal', child: Text('Personal')),
              //         DropdownMenuItem(value: 'Work', child: Text('Work')),
              //         DropdownMenuItem(value: 'School', child: Text('School')),
              //         DropdownMenuItem(
              //             value: 'Add category', child: Text('Add category')),
              //       ],
              //       onChanged: (String? newValue) {
              //         if (newValue == 'Add category') {
              //           addCategory();
              //         } else {
              //           onCategorySelected(newValue!);
              //         }
              //       },
              //     );
              //   },
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Inbox',
                        style: TextStyle(
                            fontSize: 32,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      label: Text('All'),
                      selected: selectedFilter == 'All',
                      onSelected: (isSelected) {
                        onFilterSelected('All');
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      label: Text('Pending'),
                      selected: selectedFilter == 'Pending',
                      onSelected: (isSelected) {
                        onFilterSelected('Pending');
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      label: Text('Completed'),
                      selected: selectedFilter == 'Completed',
                      onSelected: (isSelected) {
                        onFilterSelected('Completed');
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('tasks')
                      .where('category', isEqualTo: selectedCategory)
                      // if selectedFilter is 'All', then don't filter
                      .where('status',
                          isEqualTo: selectedFilter == 'All'
                              ? 'Pending'
                              : selectedFilter)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No tasks'));
                    }

                    List<Map<String, dynamic>> allTasks =
                        snapshot.data!.docs.map((DocumentSnapshot doc) {
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;
                      return data;
                    }).toList();

                    return ListView.builder(
                        itemCount: allTasks.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              leading: Icon(Icons.inbox),
                              title: Text(allTasks[index]['title']),
                              subtitle: Text(allTasks[index]['category']),
                              // a checkbox after the title
                              trailing: Checkbox(
                                value: allTasks[index]['status'] == 'Completed'
                                    ? true
                                    : false,
                                onChanged: (value) {
                                  // update the status of the task
                                  print(allTasks[index]);
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .collection('tasks')
                                      .doc(allTasks[index]['id'])
                                      .update({'status': 'Completed'});
                                },
                              ),
                            ),
                          );
                        });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
