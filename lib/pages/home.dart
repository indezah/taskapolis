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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final allTasks = [
    'Task 1',
    'Task 2',
    'Task 3',
    'Task 3',
    'Task 3',
    'Task 3',
    'Task 3',
    'Task 3',
    'Task 3',
    'Task 3',
    'Task 3',
    'Task 3',
    'Task 3',
    'Task 4',
    'Task 5',
  ];

  final pendingTasks = [
    'Task 1',
    'Task 3',
    'Task 3',
    'Task 3',
    'Task 3',
    'Task 3',
    'Task 5',
  ];

  final completedTasks = [
    'Task 2',
    'Task w4',
    'Task 4',
  ];

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
        // bottomNavigationBar: NavigationBar(
        //   onDestinationSelected: (int index) {
        //     setState(() {
        //       currentPageIndex = index;
        //     });
        //   },
        //   indicatorColor: Colors.amber[800],
        //   selectedIndex: currentPageIndex,
        //   destinations: const <Widget>[
        //     NavigationDestination(
        //       selectedIcon: Icon(Icons.home),
        //       icon: Icon(Icons.home_outlined),
        //       label: 'Home',
        //     ),
        //     NavigationDestination(
        //       icon: Icon(Icons.business),
        //       label: 'Business',
        //     ),
        //     NavigationDestination(
        //       selectedIcon: Icon(Icons.school),
        //       icon: Icon(Icons.school_outlined),
        //       label: 'School',
        //     ),
        //   ],
        // ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            RefreshIndicator(
              onRefresh: () async {
                // Reload the data here
                // You can call your function to fetch the data here
                // For example, fetchTodoItems();
              },
              child: ListView.builder(
                itemCount: allTasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                        title: Text(allTasks[index],
                            style: TextStyle(
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
                          //           EditTaskPage(task: allTasks[index])),
                          // );
                        }),
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

  // Widget _buildBody() {
  //   switch (_currentIndex) {
  //     case 0:
  //       return ListView.builder(
  //         itemCount: allTasks.length,
  //         itemBuilder: (context, index) {
  //           return ListTile(
  //               title: Text(allTasks[index]),
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                       builder: (context) =>
  //                           EditTaskPage(task: allTasks[index])),
  //                 );
  //               });
  //         },
  //       );
  //     case 1:
  //       return ListView.builder(
  //         itemCount: pendingTasks.length,
  //         itemBuilder: (context, index) {
  //           return ListTile(
  //             title: Text(pendingTasks[index]),
  //           );
  //         },
  //       );
  //     case 2:
  //       return ListView.builder(
  //         itemCount: completedTasks.length,
  //         itemBuilder: (context, index) {
  //           return ListTile(
  //             title: Text(completedTasks[index]),
  //           );
  //         },
  //       );
  //     default:
  //       return Container();
  //   }
  // }
}
