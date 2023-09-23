import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskapolis/pages/auth.dart';
import 'package:taskapolis/pages/signin.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final TabController _tabController;

  final user = FirebaseAuth.instance.currentUser;

  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  var allTasks = [];

  var pendingTasks = [];

  var completedTasks = [];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: Text('Home'),
                onTap: () {
                  // Navigate to the home page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              ListTile(
                title: Text('Logout'),
                onTap: () {
                  // Navigate to the settings page
                  FirebaseAuth.instance.signOut().then((value) =>
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => AuthPage())));
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          // scrolledUnderElevation: scrolledUnderElevation,
          title: Center(
              child: Text(
            'TASKAPOLIS',
            style: TextStyle(
              fontFamily: 'Space-Grotesk',
              fontWeight: FontWeight.bold, // Apply bold style
            ),
          )),
          bottom: TabBar(
            controller: _tabController,
            tabs: const <Widget>[
              Tab(
                text: 'ALL',
              ),
              Tab(
                text: 'PENDING',
              ),
              Tab(
                text: 'COMPLETED',
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // // Implement search feature
                // showSearch(context: context, delegate: TaskSearch(allTasks));
              },
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            RefreshIndicator(
              onRefresh: () async {
                // Reload the data here
                // You can call your function to fetch the data here
                // For example, fetchTodoItems();
              },
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('tasks')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator());
                  }

                  allTasks = snapshot.data!.docs.map((DocumentSnapshot doc) {
                    Map<String, dynamic> data =
                        doc.data()! as Map<String, dynamic>;
                    return data;
                  }).toList();

                  print(allTasks);

                  return ListView.builder(
                    itemCount: allTasks.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text("${allTasks[index]['name']}",
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600)),
                          leading: FlutterLogo(size: 56.0),
                          subtitle: Text('Here is a second line'),
                          trailing: Checkbox(
                            onChanged: (value) => {
                              // setState(() {
                              //   allTasks[index].isDone = value!;
                              // })
                            },
                            value: false,
                          ),
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) =>
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Center(
              child: Text("It's rainy here"),
            ),
            Center(
              child: Text("It's sunny here"),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            // // Navigate to the task input screen
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => AddTaskPage()),
            // );
          },
        ),
      ),
    );
  }
}
