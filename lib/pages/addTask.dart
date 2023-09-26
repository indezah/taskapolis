import 'package:flutter/material.dart';

// void main() {
//   runApp(AddTask());
// }

class AddTask extends StatefulWidget {
  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  String selectedCategory = 'Category1'; // Initialize with a default value
  bool isReminderSet = false;
  // DateTime dueDate = DateTime.now();
  // TimeOfDay dueTime = TimeOfDay.now();

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime pickedDate = await showDatePicker(
  //     context: context,
  //     initialDate: dueDate,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //   );
  //   if (pickedDate != null && pickedDate != dueDate) {
  //     setState(() {
  //       dueDate = pickedDate;
  //     });
  //   }
  // }

  // Future<void> _selectTime(BuildContext context) async {
  //   // final TimeOfDay pickedTime = await showTimePicker(
  //   //   context: context,
  //   //   initialTime: dueTime,
  //   // );
  //   if (pickedTime != null && pickedTime != dueTime) {
  //     setState(() {
  //       dueTime = pickedTime;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Add Task'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Title',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Note',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
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
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue ?? '';
                        });
                      },
                      items: <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: 'Category1',
                          child: Text('Category 1'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Category2',
                          child: Text('Category 2'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Category3',
                          child: Text('Category 3'),
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
                  // Expanded(
                  //   flex: 3,
                  //   child: TextButton(
                  //     onPressed: () {
                  //       _selectDate(context);
                  //     },
                  //     child: Text(
                  //       '${dueDate.toLocal()}'.split(' ')[0],
                  //       style: TextStyle(
                  //         fontSize: 16.0,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              SizedBox(height: 20.0),
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
                  // Expanded(
                  //   flex: 3,
                  //   child: TextButton(
                  //     onPressed: () {
                  //       _selectTime(context);
                  //     },
                  //     child: Text(
                  //       dueTime.format(context),
                  //       style: TextStyle(
                  //         fontSize: 16.0,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
