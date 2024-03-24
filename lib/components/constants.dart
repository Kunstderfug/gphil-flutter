import 'package:flutter/material.dart';

var appBar = AppBar(
  title: const Text(
    'P L A Y L I S T',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  toolbarHeight: 64,
);

var bottomBar = BottomAppBar(
  color: Colors.transparent,
  child: Container(
    height: 64,
    color: Colors.transparent,
  ),
);
