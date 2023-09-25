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

  @override
  void initState() {
    super.initState();
    // Fetch the task data for the given taskId
    taskData = FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.taskId)
        .get();
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Error fetching task data: ${snapshot.error}');
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            final task = snapshot.data!.data() as Map<String, dynamic>;
            final taskTitle = task['title'] as String;
            final taskDescription = task['description'] as String;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                    ),
                    initialValue: taskTitle,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Task Description',
                    ),
                    initialValue: taskDescription,
                    maxLines: null, // Allow multiline input
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      // Update task data in Firestore
                      await FirebaseFirestore.instance
                          .collection('tasks')
                          .doc(widget.taskId)
                          .update({
                        'title': titleController.text,
                        'description': descriptionController.text,
                      });

                      // Optionally, navigate back to the task list or previous screen
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            );
          } else {
            // Debugging information
            print('Snapshot: $snapshot');
            print('Task ID: ${widget.taskId}');
            print('Task Data: $taskData');
            return const Center(child: Text('Task not found'));
          }
        },
      ),
    );
  }
}
