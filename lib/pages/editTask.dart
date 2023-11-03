// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTaskPage extends StatefulWidget {
  final String taskId;

  const EditTaskPage({super.key, required this.taskId});

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  String selectedPriority = 'Low'; // Default value for priority
  String selectedCategory = 'Personal'; // Default value for category

  final List<String> priorities = ['Low', 'Medium', 'High'];
  final List<String> categories = [
    'Personal',
    'Work',
    'Family',
    'Health',
    'Finance',
    'Social',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();

    // Fetch the task data for the given taskId
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.taskId)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      final data = snapshot.data()!;
      titleController.text = data['title'] ?? '';
      descriptionController.text = data['description'] ?? '';
      setState(() {
        selectedPriority = data['priority'] ?? 'Low'; // Update selectedPriority
        selectedCategory =
            data['category'] ?? 'Personal'; // Update selectedCategory
      });
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

 bool showSuccessMessage = false; // Initialize the flag

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                  labelText: 'Notes',
                  icon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 25),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                onChanged: (newValue) {
                  setState(() {
                    selectedPriority = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  icon: Icon(Icons.priority_high),
                ),
                items: priorities.map((priority) {
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  icon: Icon(Icons.category),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(widget.taskId)
                    .update({
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'priority': selectedPriority,
                      'category': selectedCategory,
                    });

                  Navigator.pop(context, true); // Return true to indicate success
                },
                child: const Text('Save'),
              ),
              // if (showSuccessMessage) // Show the message if the flag is true
              //   Text('Task edited successfully'),
            ],
          ),
        ),
      ),
    );
  }
}