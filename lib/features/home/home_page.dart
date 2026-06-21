import 'package:flutter/material.dart';

import '../wellness/wellness_page.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        title: const Text('LELOMS 🌙'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Bienvenido a LELOMS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
