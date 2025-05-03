import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text("Welcome to Weatherly!", style: Theme.of(context).textTheme.headlineMedium),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              child: Text("Get Started"),
            ),
          ],
        ),
      ),
    );
  }
}
