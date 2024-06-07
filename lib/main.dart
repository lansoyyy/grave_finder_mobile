import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grave_finder/firebase_options.dart';
import 'package:grave_finder/screens/home_screen.dart';
import 'package:grave_finder/screens/login_page.dart';
import 'package:grave_finder/screens/sample_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'gravefinder-9d85f',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}
