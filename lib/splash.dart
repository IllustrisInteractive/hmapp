import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      child: Container(
        color: Colors.white, // Set the desired background color
        child: Column(
          children: [
            Expanded(child: SizedBox.shrink()),
            Image.asset('assets/images/logo.png'),
            Text(
              "An Android Based Food Donation and Food Waste Management System Using First In-First Out Algorithm with Geo-fencing",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
            Expanded(child: SizedBox.shrink()),
            Text(
              "Tap to Continue",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
            Expanded(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
