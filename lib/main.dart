import 'package:flutter/material.dart';
import 'package:myChef/ui/screens/guest.dart';
import 'package:myChef/ui/screens/home.dart';
import 'ui/screens/sign_in.dart';
import 'ui/screens/sign_up.dart';
import 'utils/state_widget.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyApp Title',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => HomeScreen(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
      },
    );
  }
}

void main() {
  StateWidget stateWidget = new StateWidget(
    child: new MyApp(),
  );
  runApp(stateWidget);
}