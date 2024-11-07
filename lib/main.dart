import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    return MaterialApp(
      title: 'Product Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(dbHelper: dbHelper),
    );
  }
}