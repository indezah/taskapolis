import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  void onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void onFilterSelected(String filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Taskapolis"),
      ),
      body: Column(
        children: <Widget>[
          DropdownButton<String>(
            value: selectedCategory,
            items: <String>['Personal', 'Work', 'Sports'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? category) {
              onCategorySelected(category!);
            },
          ),
          Row(
            children: <Widget>[
              FilterChip(
                label: Text('All'),
                selected: selectedFilter == 'All',
                onSelected: (isSelected) {
                  onFilterSelected('All');
                },
              ),
              FilterChip(
                label: Text('Pending'),
                selected: selectedFilter == 'Pending',
                onSelected: (isSelected) {
                  onFilterSelected('Pending');
                },
              ),
              FilterChip(
                label: Text('Completed'),
                selected: selectedFilter == 'Completed',
                onSelected: (isSelected) {
                  onFilterSelected('Completed');
                },
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .collection('tasks')
                  .where('category', isEqualTo: selectedCategory)
                  .where('status', isEqualTo: selectedFilter)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  print(
                    FirebaseAuth.instance.currentUser?.email,
                  );

                  print(selectedCategory);
                  print(selectedFilter);
                  return Text("Loading");
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No tasks'));
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['title']),
                      subtitle: Text(data['category']),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
