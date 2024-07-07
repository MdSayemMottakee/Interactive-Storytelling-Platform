import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:login_signup/components/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDUZXuhQnvS3fw2RxEtKIsdgFqi4HsQsco',
      authDomain: 'interactive-storytelling-1323c.firebaseapp.com',
      databaseURL: 'https://interactive-storytelling-1323c-default-rtdb.asia-southeast1.firebasedatabase.app/',
      projectId: 'interactive-storytelling-1323c',
      storageBucket: 'interactive-storytelling-1323c.appspot.com',
      messagingSenderId: '120027546584',
      appId: '1:120027546584:web:91120db9ac0d769526a8ad',
      measurementId: 'G-0KTH0HS81G'
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize Firebase and wait for completion
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while Firebase is initializing
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // Show error message if initialization fails
          return const Center(
            child: Text('Error initializing Firebase'),
          );
        } else {
          // Once Firebase is initialized, return MaterialApp
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: LoginPage(),
          );
        }
      },
    );
  }
}
