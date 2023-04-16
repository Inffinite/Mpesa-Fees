import 'package:flutter/material.dart';

class TitleTab extends StatelessWidget {
  final String title;

  const TitleTab({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 10.0,
        bottom: 10.0,
        left: 20.0,
        right: 20.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xff52B44B),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: "AR",
          fontSize: 14.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
