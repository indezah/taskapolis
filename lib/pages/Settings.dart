import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> exportTasksToCSV(BuildContext context) async {
    // Request permission to write to external storage
    PermissionStatus permission = await Permission.storage.request();
    if (permission.isDenied) {
      await Permission.storage.request();
    }

    // Check if permission is granted

    if (await permission.isGranted) {
      // Get a reference to the tasks collection
      CollectionReference tasks = firestore.collection('tasks');

      // Get all tasks
      QuerySnapshot querySnapshot = await tasks
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      // Get a reference to the documents in the tasks collection
      List<QueryDocumentSnapshot> documents = querySnapshot.docs;

      // Create a list of lists to store the CSV data
      List<List<dynamic>> csvData = [
        [
          'title',
          'category',
          'completed',
          'isReminderSet',
          'notes',
          'priority',
          'timestamp'
        ]
      ];

      // Iterate through the documents and add the data to the csvData list
      for (final document in documents) {
        csvData.add([
          document['title'],
          document['category'],
          document['completed'],
          document['isReminderSet'],
          document['notes'],
          document['priority'],
          document['timestamp'],
        ]);
      }

      // Convert csvData to a string
      String csvString = const ListToCsvConverter().convert(csvData);

      // let user get path where to save the file by using file_picker
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      // Create a reference to the file path
      String filePath = '$selectedDirectory/tasks.csv';

      // Create a reference to the file
      final File csvFile = File(filePath);

      // Write the file
      await csvFile.writeAsString(csvString);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tasks exported to CSV successfully.'),
        ),
      );
    }
  }

  Future<void> importTasksFromCSV(BuildContext context, String uid) async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isDenied) {
      await Permission.storage.request();
    }

    if (await Permission.storage.isGranted) {
      // let user get path where to save the file by using file_picker
      String? selectedFilePath = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      ).then((value) => value!.files.single.path);
      print(selectedFilePath);
      // Create a reference to the file
      final File csvFile = File(selectedFilePath!);
      print(csvFile);
      // Read the file
      String csvString = await csvFile.readAsString();
      print('csvString: $csvString');
      // Convert the file to a list of lists
      List<List<dynamic>> csvData =
          const CsvToListConverter().convert(csvString);
      print('csvData: $csvData');

      // Get a reference to the tasks collection
      CollectionReference tasks = firestore.collection('tasks');

      // Iterate through the csvData and add each task to the Firestore collection
      for (int i = 1; i < csvData.length; i++) {
        String timestampString = csvData[i][6];
        int seconds = int.parse(timestampString.split('=')[1].split(',')[0]);
        bool completed = csvData[i][2].toLowerCase() == 'true';
        bool isReminderSet = csvData[i][3].toLowerCase() == 'true';

        // Convert the seconds to milliseconds
        int milliseconds = seconds * 1000;

        // Create a new Timestamp from the milliseconds
        Timestamp timestamp =
            Timestamp.fromMillisecondsSinceEpoch(milliseconds);

        await tasks.add({
          'title': csvData[i][0],
          'category': csvData[i][1],
          'completed': completed,
          'isReminderSet': isReminderSet,
          'notes': csvData[i][4],
          'priority': csvData[i][5],
          'timestamp': timestamp,
          'uid': uid, // Use the UID of the currently logged in user
        });
        csvData.clear();
        // print(uid);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tasks imported from CSV successfully.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => exportTasksToCSV(context),
              child: Text('Export Tasks to CSV'),
            ),
            ElevatedButton(
              onPressed: () => importTasksFromCSV(
                  context, FirebaseAuth.instance.currentUser!.uid),
              child: Text('Import Tasks from CSV'),
            ),
          ],
        ),
      ),
    );
  }
}
