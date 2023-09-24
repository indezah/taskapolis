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
        backgroundColor: Color.fromRGBO(238, 238, 255, 1),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(238, 238, 255, 1),
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
        drawer: Drawer(
            // Implement navigation drawer here
            ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              // .orderBy('completed')
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

            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length + 1,
                itemBuilder: (context, index) {
                  if (index < snapshot.data!.docs.length) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    DateTime? taskDate = data['timestamp'] != null
                        ? (data['timestamp'] as Timestamp).toDate()
                        : null;
                    DateTime now = DateTime.now();
                    bool isToday = taskDate != null &&
                        now.year == taskDate.year &&
                        now.month == taskDate.month &&
                        now.day == taskDate.day;

                    // If the task is not for today and we are still in the 'Today' section, skip this task
                    if (!isToday && index < snapshot.data!.docs.length - 1) {
                      DocumentSnapshot nextDocument =
                          snapshot.data!.docs[index + 1];
                      Map<String, dynamic> nextData =
                          nextDocument.data() as Map<String, dynamic>;
                      DateTime? nextTaskDate = nextData['timestamp'] != null
                          ? (nextData['timestamp'] as Timestamp).toDate()
                          : null;
                      bool isNextTaskToday = nextTaskDate != null &&
                          now.year == nextTaskDate.year &&
                          now.month == nextTaskDate.month &&
                          now.day == nextTaskDate.day;

                      if (isNextTaskToday) {
                        return Container(); // Return an empty container to maintain the index
                      }
                    }

                    return Container(
                      // margin between each task
                      // border radius
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: ListTile(
                        title: Text(
                          data['title'],
                          style: data['completed']
                              ? TextStyle(
                                  decoration: TextDecoration.lineThrough)
                              : null,
                        ),
                        trailing: Column(
                          // align to the right

                          mainAxisAlignment: MainAxisAlignment.center,
                          // mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // if priority is 3, show !!! in red
                            // if priority is 2, show !! in orange
                            // if priority is 1, show ! in yellow
                            // if priority is 0, show nothing

                            Text(
                                data['priority'] == 3
                                    ? '!!!'
                                    : data['priority'] == 2
                                        ? '!!'
                                        : data['priority'] == 1
                                            ? '!'
                                            : '',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: data['priority'] == 3
                                        ? Colors.red
                                        : data['priority'] == 2
                                            ? Colors.orange
                                            : data['priority'] == 1
                                                ? Colors.yellow
                                                : Colors.white)),

                            Text(
                                'Time: ${taskDate != null ? taskDate.toString() : 'No timestamp'}'),
                          ],
                        ),
                        leading: Checkbox(
                          value: data['completed'],
                          onChanged: (bool? value) {
                            document.reference.update({'completed': value});
                          },
                        ),
                      ),
                    );
                  } else {
                    return Container(
                        height: 80); // Add an empty container at the end
                  }
                },
              ),
            );
          },
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.2),
                blurRadius: 40,
                offset: Offset(0, -5),
              ),
            ],
            color: Color.fromRGBO(102, 60, 255, 1),
            // borderRadius: BorderRadius.only(
            //   topLeft: Radius.circular(25.0),
            //   topRight: Radius.circular(25.0),
            // ),
          ),
          height: 120.0,
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 10.0, 10, 0),
                  child: Text(
                    'Categories',
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FilterChip(
                        // border radius
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
            onPressed: null,
            label: Row(children: [
              Icon(Icons.add),
              SizedBox(width: 5),
              Text("Add Task")
            ])));
  }
}
