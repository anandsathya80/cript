import 'package:flutter/material.dart';

class CardMainScreen extends StatefulWidget {
  CardMainScreen({
    super.key,
  });

  @override
  State<CardMainScreen> createState() => _CardMainScreenState();
}

class _CardMainScreenState extends State<CardMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('data loaded here'),
    );
  }
}
