import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:taskapolis/main.dart';

class FirebaseApi {
  // create an instance of Firebase Messaging
  final  _firebaseMessaging = FirebaseMessaging.instance;

  // function to initialize notifications
  Future<void> initNitifications() async {
    // request permission to send notifications
    await _firebaseMessaging.requestPermission();

    // get the token 
    final token = await _firebaseMessaging.getToken();

    // print the token
    print('FirebaseMessaging token: $token');

  }

  // function to handle received messages
  void handleMessage(RemoteMessage? message) {
      // check if the message is null
      if (message == null) return;

      // navigate to new screen when message is received and user  taps notification
      navigatorKey.currentState?.pushNamed(
        '/notification_screen', 
        arguments: message,
      );
  }

  // fucntion to initialize background settings
  Future<void> initBackgroundSettings() async {
    // handle notification if the app was terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // attach event listners for when a notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
  

