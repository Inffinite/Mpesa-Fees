import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200.0,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xff52B44B),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  SizedBox(height: 40.0),
                  Text(
                    "Amount you wish to spend",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFNSR',
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    "34,754",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40.0,
                      fontFamily: 'SFT-Bold',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TitleTab(title: "Sending to a registered number"),
                  SizedBox(height: 15.0),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Color(0xff52B44B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        AmountTag(title: "Minimum balance", amount: '45,555'),
                        Divider(
                          color: const Color(0xff52B44B).withOpacity(0.1),
                          thickness: 2.0,
                        ),
                        AmountTag(title: "Sending fee", amount: '105'),
                        Divider(
                          color: const Color(0xff52B44B).withOpacity(0.1),
                          thickness: 2.0,
                        ),
                        AmountTag(title: "Withdrawal charge", amount: '191'),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.0),
                  TitleTab(title: "Sending to an unregistered number"),
                  SizedBox(height: 15.0),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Color(0xff52B44B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        AmountTag(title: "Minimum balance", amount: '45,555'),
                        Divider(
                          color: const Color(0xff52B44B).withOpacity(0.1),
                          thickness: 2.0,
                        ),
                        AmountTag(title: "Sending fee", amount: '105'),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.0),
                  TitleTab(title: "Withdraw at an agent"),
                  SizedBox(height: 15.0),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Color(0xff52B44B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        AmountTag(title: "Withdrawal charge", amount: '45,555'),
                        Divider(
                          color: const Color(0xff52B44B).withOpacity(0.1),
                          thickness: 2.0,
                        ),
                        AmountTag(title: "Withdrawable amount", amount: '105'),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.0),
                  TitleTab(title: "Withdraw at an ATM"),
                  SizedBox(height: 15.0),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Color(0xff52B44B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        AmountTag(title: "Withdrawal charge", amount: '45,555'),
                        Divider(
                          color: const Color(0xff52B44B).withOpacity(0.1),
                          thickness: 2.0,
                        ),
                        AmountTag(title: "Withdrawable amount", amount: '105'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TitleTab extends StatelessWidget {
  final String title;

  TitleTab({
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
        style: TextStyle(
          fontFamily: "AR",
          fontSize: 14.0,
          color: Colors.white,
        ),
      ),
    );
  }
}

class AmountTag extends StatelessWidget {
  final String title;
  final String amount;

  AmountTag({
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
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
            style: TextStyle(
                color: Color(0xff52B44B), fontSize: 14.0, fontFamily: "SFNSR"),
          ),
          SizedBox(height: 5.0),
          Text(
            amount,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: "SFT-Bold",
              fontSize: 24.0,
              color: Color(0xff52B44B),
            ),
          ),
        ],
      ),
    );
  }
}
