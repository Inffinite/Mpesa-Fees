import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountTag extends StatefulWidget {
  final String title;
  String amount;

  AmountTag({
    required this.title,
    required this.amount,
  });

  @override
  State<AmountTag> createState() => _AmountTagState();
}

class _AmountTagState extends State<AmountTag> {
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
        if (widget.amount != "N/A") {
          var value = widget.amount;
          copyToClipboard(widget.amount);
          setState(() {
            widget.amount = "Copied to clipboard";
          });

          var timer = Timer(
              Duration(seconds: 1),
              () => {
                    setState(() {
                      widget.amount = value;
                    })
                  });
        }
        // showToast(context, "Copied to clipboard");
      },
      child: Container(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 8.0,
          bottom: 8.0,
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.start,
              style: const TextStyle(
                color: Color(0xff52B44B),
                fontSize: 16.0,
                fontFamily: "SFNSR",
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.amount,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: "SFT-Bold",
                fontSize: widget.amount == "Copied to clipboard" ? 16.0 : 26.0,
                color: Color(0xff52B44B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
