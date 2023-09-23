import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      home: MyHomePage(title: 'Flutter Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isAddNewItemsToBottom = false;
  bool _isMoveCheckedItemsToBottom = false;
  bool _isDisplayRichLinkPreviews = false;
  
  TimeOfDay _morningTime = TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _afternoonTime = TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _nightTime = TimeOfDay(hour: 20, minute: 0);

  Future<void> _selectTime(BuildContext context, String timeOfDay) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: timeOfDay == 'morning' ? _morningTime : timeOfDay == 'afternoon' ? _afternoonTime : _nightTime,
    );
    if (picked != null)
      setState(() {
        if (timeOfDay == 'morning') {
          _morningTime = picked;
        } else if (timeOfDay == 'afternoon') {
          _afternoonTime = picked;
        } else if (timeOfDay == 'night') {
          _nightTime = picked;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Display Options',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('Add new items to bottom', style: TextStyle(fontSize: 18)),
              leading: Switch(
                value: _isAddNewItemsToBottom,
                onChanged: (bool value) {
                  setState(() {
                    _isAddNewItemsToBottom = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Move checked items to bottom', style: TextStyle(fontSize: 18)),
              leading: Switch(
                value: _isMoveCheckedItemsToBottom,
                onChanged: (bool value) {
                  setState(() {
                    _isMoveCheckedItemsToBottom = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Display rich link previews', style: TextStyle(fontSize: 18)),
              leading: Switch(
                value: _isDisplayRichLinkPreviews,
                onChanged: (bool value) {
                  setState(() {
                    _isDisplayRichLinkPreviews = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Reminder Defaults',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('Morning', style: TextStyle(fontSize: 18)),
              trailing: IconButton(
                icon: Icon(Icons.access_time),
                onPressed: () => _selectTime(context, 'morning'),
              ),
            ),
            ListTile(
              title: const Text('Afternoon', style: TextStyle(fontSize: 18)),
              trailing: IconButton(
                icon: Icon(Icons.access_time),
                onPressed: () => _selectTime(context, 'afternoon'),
              ),
            ),
            ListTile(
              title: const Text('Night', style: TextStyle(fontSize: 18)),
              trailing: IconButton(
                icon: Icon(Icons.access_time),
                onPressed: () => _selectTime(context, 'night'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

