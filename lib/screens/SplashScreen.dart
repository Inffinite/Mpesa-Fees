import 'dart:async';

import 'package:flutter/material.dart';

import 'Dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  moveOn() async {
    var timer = Timer(
        const Duration(seconds: 3),
        () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Dashboard(),
                ),
              );
            });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    moveOn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff52B44B),
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Container(
                width: 160.0,
                height: 160.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.white,
                ),
                child: const Center(child: Text("Mpesa Fees")),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 30.0),
              child: const Text(
                "Powered by Wrenix Studio",
                style: TextStyle(
                    color: Colors.white, fontFamily: "AR", fontSize: 14.0),
              ),
            ),
          )
        ],
      ),
    );
  }
}
