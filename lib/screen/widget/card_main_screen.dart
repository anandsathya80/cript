import 'package:flutter/material.dart';

class CardMainScreen extends StatefulWidget {
  CardMainScreen({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    super.key,
  });

  String id;
  String name;
  String description;
  String image;

  @override
  State<CardMainScreen> createState() => _CardMainScreenState();
}

class _CardMainScreenState extends State<CardMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Card(
        color: Colors.amber,
      ),
    );
  }
}
