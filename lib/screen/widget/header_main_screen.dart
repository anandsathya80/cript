import 'package:flutter/material.dart';

class HeaderMain extends StatefulWidget {
  const HeaderMain({super.key});

  @override
  State<HeaderMain> createState() => _HeaderMainState();
}

class _HeaderMainState extends State<HeaderMain> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('this is header text'),
    );
  }
}
