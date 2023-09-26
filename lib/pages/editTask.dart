import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTaskPage extends StatefulWidget {
  final String taskId;

  const EditTaskPage({required this.taskId});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> taskData;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController priorityController;
  late TextEditingController categoryController;

  @override
  void initState() {
    super.initState();
    // Fetch the task data for the given taskId
    taskData = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('tasks')
        .doc(widget.taskId)
        .get();
    // print(taskData.toString());
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    priorityController = TextEditingController();
    categoryController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: taskData,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            }

            if (snapshot.connectionState == ConnectionState.done) {
              final data = snapshot.data!.data()!;
              titleController.text = data['title'] ?? '';
              descriptionController.text = data['description'] ?? '';
              priorityController.text = data['priority'].toString();
              categoryController.text = data['category'] ?? '';
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        icon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        icon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: priorityController,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        icon: Icon(Icons.priority_high),
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        icon: Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 25),

                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('tasks')
                            .doc(widget.taskId)
                            .update({
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'priority': priorityController.text,
                          'category': categoryController.text,
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
