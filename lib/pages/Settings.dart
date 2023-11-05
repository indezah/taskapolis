import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> exportTasksToCSV(BuildContext context) async {
    const permission = Permission.manageExternalStorage;
    if (await permission.isDenied) {
      await permission.request();
    }

    if (await permission.isGranted) {
      // Get a reference to the tasks collection
      CollectionReference tasks = firestore.collection('tasks');

      // Get all tasks
      QuerySnapshot querySnapshot = await tasks.get();

      // Get a reference to the documents in the tasks collection
      List<QueryDocumentSnapshot> documents = querySnapshot.docs;

      // Create a list of lists to store the CSV data
      List<List<dynamic>> csvData = [
        ['Title', 'Category', 'Completed', 'Priority', 'Timestamp', 'UID'],
      ];

      // Iterate through the documents and add the data to the csvData list
      for (final document in documents) {
        csvData.add([
          document['title'],
          document['category'],
          document['completed'],
          // document['duedate'],
          // document['duetime'],
          // document['notes'],
          document['priority'],
          document['timestamp'],
          document['uid'],
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

  Future<void> importTasksFromCSV(BuildContext context) async {
    const permission = Permission.manageExternalStorage;
    if (await permission.isDenied) {
      await permission.request();
    }

    if (await permission.isGranted) {
      // let user get path where to save the file by using file_picker
      String? selectedFilePath = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      ).then((value) => value!.files.single.path);

      // Create a reference to the file
      final File csvFile = File(selectedFilePath!);

      // Read the file
      String csvString = await csvFile.readAsString();

      // Convert the file to a list of lists
      List<List<dynamic>> csvData =
          const CsvToListConverter().convert(csvString);
      print(csvData);
      // Get a reference to the tasks collection
      CollectionReference tasks = firestore.collection('tasks');

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
              onPressed: () => importTasksFromCSV(context),
              child: Text('Import Tasks from CSV'),
            ),
          ],
        ),
      ),
    );
  }
}
