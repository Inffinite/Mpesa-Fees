import 'package:flutter/material.dart';

class TitleTab extends StatelessWidget {
  final String title;
  final String mptheme;

  const TitleTab({
    required this.title,
    required this.mptheme,
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
        style: TextStyle(
          fontFamily: "AR",
          fontSize: 14.0,
          color: mptheme == "light" ? Colors.white : Color(0xff000000),
        ),
      ),
    );
  }
}
