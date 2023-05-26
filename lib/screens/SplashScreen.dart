import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'Dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  moveOn() async {
    var timer = Timer(
        Duration(seconds: 3),
        () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Dashboard(),
                ),
              )
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
      backgroundColor: Color(0xff52B44B),
      body: Stack(
        children: [
          Container(
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
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 20.0,
                        height: 70.0,
                        decoration: BoxDecoration(
                          color: Color(0xff6FBF69),
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                      SizedBox(width: 15.0),
                      Container(
                        width: 20.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          color: Color(0xff52B44B),
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                      SizedBox(width: 15.0),
                      Container(
                        width: 20.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: Color(0xffA1D99C),
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 30.0),
              child: Text(
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
