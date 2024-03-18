import 'package:flutter/material.dart';
import 'package:gphil/init/sanity.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPhil Project'),
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
          child: Text(
        'G-Phil, Your Personal Orchestra Assistant',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      )),
    );
  }
}
