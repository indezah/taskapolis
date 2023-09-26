import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskapolis/reuseable_wdigets/reuseable_widget.dart';

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
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // TextField(
                  //   controller: titleController,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Title',

                  //   ),
                  // ),
                  reuseableTextField(
                      'Title', Icons.title, false, titleController),
                  const SizedBox(height: 20),
                  reuseableTextField('Description', Icons.description, false,
                      descriptionController),
                  const SizedBox(height: 20),
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
    );
  }
}
