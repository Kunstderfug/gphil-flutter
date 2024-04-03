import 'package:flutter/material.dart';

var appBar = AppBar(
  title: const Text(
    'P L A Y L I S T',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  toolbarHeight: 64,
);

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconSize: 24,
      selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
      unselectedItemColor: Theme.of(context).colorScheme.secondary,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
