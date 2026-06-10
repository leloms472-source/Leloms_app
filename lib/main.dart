import 'package:flutter/material.dart';
import 'features/home/home_page.dart';

void main() {
  runApp(const LelomsApp());
}

class LelomsApp extends StatelessWidget {
  const LelomsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LELOMS',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}	

