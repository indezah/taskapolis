import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Add this import for DateFormat
// import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class AddTask extends StatefulWidget {
  const AddTask({super.key});

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  String selectedCategory = 'Work';
  String selectedPriority = "High"; // Initialize with a default value
  bool isReminderSet = false;
  DateTime? selectedDueDate; // Declare as class-level variables
  TimeOfDay? selectedDueTime;
  DateTime? dueDate; // Declare dueDate
  TimeOfDay? dueTime;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String timeOfDayToString(TimeOfDay timeOfDay) {
    return '${timeOfDay.hour}:${timeOfDay.minute}';
  }

  Future<void> _selectDateAndTime(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? now,
      firstDate: now,
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedDueTime ?? TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          dueDate = selectedDueDate;
          selectedDueTime = pickedTime;
          dueTime = selectedDueTime;
        });
      }
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      if (selectedDueDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Due Date and Time.'),
          ),
        );
        return;
      }

      // Get the current user ID from Firebase Authentication
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Handle the case where the user is not logged in
        return;
      }

      // Create a map with the task data
      Map<String, dynamic> taskData = {
        'category': selectedCategory,
        'completed': false,
        'notes': notesController.text.isEmpty ? '' : notesController.text,
        'priority': selectedPriority,
        'timestamp':
            Timestamp.fromDate(selectedDueDate!), // Use selectedDueDate
        'title': titleController.text,
        'uid': user.uid,
        'isReminderSet': isReminderSet,
      };

      // Add the task data to Firestore under the 'tasks' collection and the user's ID
      try {
        await FirebaseFirestore.instance.collection('tasks').add(taskData);
      } catch (e) {
        print(e);
      }

      // Navigate to the home page
      Navigator.of(context)
          .pop(); // Close the current screen and go back to the previous one (home page)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20.0),
                const SizedBox(height: 10.0),
                TextFormField(
                  maxLines: 5,
                  controller: notesController,
                  validator: (value) {
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Notes',
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    const Expanded(
                      flex: 3,
                      child: Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Category is required';
                          }
                          return null;
                        },
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(
                            value: 'Work',
                            child: Text('Work'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Education',
                            child: Text('Education'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Home',
                            child: Text('Home'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Health',
                            child: Text('Health'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Shopping',
                            child: Text('Shopping'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Personal',
                            child: Text('Personal'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Entertainment',
                            child: Text('Entertainment'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    const Expanded(
                      flex: 3,
                      child: Text(
                        'Priority',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: selectedPriority,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPriority = newValue ??
                                "High"; // Assign a default value if null
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Priority is required';
                          }
                          return null;
                        },
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(
                            value: "High",
                            child: Text('High'),
                          ),
                          DropdownMenuItem<String>(
                            value: "Medium",
                            child: Text('Medium'),
                          ),
                          DropdownMenuItem<String>(
                            value: "Low",
                            child: Text('Low'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Text(
                        'Set a reminder',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Switch(
                        value: isReminderSet,
                        onChanged: (bool newValue) {
                          setState(() {
                            isReminderSet = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Text(
                        'Due Date and Time', // Update the label
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextButton(
                        onPressed: () {
                          _selectDateAndTime(context); // Use _selectDateAndTime
                        },
                        child: Text(
                          selectedDueDate != null && selectedDueTime != null
                              ? DateFormat('MMM d, y H:mm')
                                  .format(selectedDueDate!) // Format as desired
                              : 'Select Date and Time',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    child: const Text('Save Task'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
