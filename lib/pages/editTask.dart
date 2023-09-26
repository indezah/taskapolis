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
  String priorityValue = "1"; // Store the selected priority as a String
  late TextEditingController categoryController;

  // Define the available priority options and their corresponding values
  final List<String> priorityOptions = ['Low', 'Medium', 'High'];
  final Map<String, String> priorityValues = {'Low': '1', 'Medium': '2', 'High': '3'};

  // Define the available category options
  final List<String> categoryOptions = ['Personal', 'Work', 'Health', 'Family', 'Finance', 'Social'];

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
    titleController = TextEditingController();
    descriptionController = TextEditingController();
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
              priorityValue = data['priority'] ?? '1'; // Initialize priorityValue
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
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        icon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 25),
                    DropdownButtonFormField<String>(
                      value: priorityValue,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        icon: Icon(Icons.priority_high),
                      ),
                      items: priorityValues.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.value,
                          child: Text(entry.key),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            priorityValue = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 25),
                    DropdownButtonFormField<String>(
                      value: categoryController.text,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        icon: Icon(Icons.category),
                      ),
                      items: categoryOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          categoryController.text = value ?? '';
                        });
                      },
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
                          'priority': priorityValue, // Use priorityValue
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
