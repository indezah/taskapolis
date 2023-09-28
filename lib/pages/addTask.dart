import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Add this import for DateFormat
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';


class AddTask extends StatefulWidget {
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
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String timeOfDayToString(TimeOfDay timeOfDay) {
    return '${timeOfDay.hour}:${timeOfDay.minute}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDueDate = pickedDate;
        dueDate = pickedDate; // Update dueDate with the selected date
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedDueTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        selectedDueTime = pickedTime;
        dueTime = pickedTime; // Update dueTime with the selected time
      });
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      if (dueDate == null || dueTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select Due Date and Due Time.'),
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
      final Timestamp dueDateTimestamp = Timestamp.fromDate(dueDate!);
      final dueTimeAsString = timeOfDayToString(dueTime!);
       final DateTime dueDateTime = DateTime(
          dueDate!.year,
          dueDate!.month,
          dueDate!.day,
          dueTime!.hour,
          dueTime!.minute,
    );

    // Create a map with the task data
    // final dueTimeAsString = timeOfDayToString(dueTime!);

      Map<String, dynamic> taskData = {
        'category': selectedCategory,
        'completed': false,
        'notes': notesController.text.isEmpty ? '' : notesController.text,
        'priority': selectedPriority,
        'timestamp': dueDateTimestamp,
        'duetime': dueTimeAsString, // Store the TimeOfDay as a string
        // 'timestamp': FieldValue.serverTimestamp(),
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
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                TextFormField(
                  controller: titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20.0),
                SizedBox(height: 10.0),
                TextFormField(
                  maxLines: 5,
                  controller: notesController,
                  validator: (value) {
                    // Add validation logic for the note field if needed
                    return null; // Return null if no validation required
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Notes',
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
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
                        items: <DropdownMenuItem<String>>[
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
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
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
                        items: <DropdownMenuItem<String>>[
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
                SizedBox(height: 20.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
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
                SizedBox(height: 20.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Due Date',
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
                          _selectDate(context);
                        },
                        child: Text(
                          dueDate != null
                              ? '${dueDate!.toLocal()}'.split(' ')[0]
                              : 'Select Date',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Due Time',
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
                          _selectTime(context);
                        },
                        child: Text(
                          dueTime != null
                              ? dueTime!.format(context)
                              : 'Select Time',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    child: Text('Save Task'),
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
