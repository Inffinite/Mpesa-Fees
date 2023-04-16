import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountTag extends StatelessWidget {
  final String title;
  final String amount;

  AmountTag({
    required this.title,
    required this.amount,
  });

  copyToClipboard(value) {
    Clipboard.setData(
        ClipboardData(text: '${int.parse(value.replaceAll(',', ''))}'));
  }

  void showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: "SFNSR"),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xff52B44B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        copyToClipboard(amount);
        showToast(context, "Copied to clipboard");
      },
      child: Container(
        padding: const EdgeInsets.only(
          left: 15.0,
          right: 15.0,
          top: 8.0,
          bottom: 8.0,
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: TextAlign.start,
              style: const TextStyle(
                  color: Color(0xff52B44B),
                  fontSize: 14.0,
                  fontFamily: "SFNSR"),
            ),
            const SizedBox(height: 5.0),
            Text(
              amount,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontFamily: "SFT-Bold",
                fontSize: 24.0,
                color: Color(0xff52B44B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
