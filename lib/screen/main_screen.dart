import 'package:cript/screen/widget/card_main_screen.dart';
import 'package:cript/screen/widget/header_main_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(12),
            child: Center(
              child: Column(
                children: [
                  HeaderMain(),
                  SizedBox(
                    height: 100,
                  ),
                  CardMainScreen(),
                ],
              ),
            )),
      ),
    );
  }
}
