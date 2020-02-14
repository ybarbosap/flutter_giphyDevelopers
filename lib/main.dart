import 'package:flutter/material.dart';

import 'package:giphy_developers/ui/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
      theme: ThemeData(hintColor: Colors.white, cursorColor: Colors.white),
    );
  }
}
