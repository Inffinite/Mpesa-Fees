import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';

import '../data/data.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController _amountController = TextEditingController();
  static const _locale = 'en';
  String _formatNumber(String s) =>
      NumberFormat.decimalPattern(_locale).format(int.parse(s));

  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'en_US', symbol: '\$');

  var minimumBalanceOne = 0;
  var sendingFeeOne = 0;
  var amountToSendOne = 0;

  var agentWithdrawalFee = 0;
  var atmWithdrawalFee = 0;

  calculateFees() async {
    log(_amountController.text);
    for (var i = 0; i < registeredUsers.length; i++) {
      // Calculate sending fees - one
      if (int.parse(_amountController.text.replaceAll(',', '')) >=
              registeredUsers[i][0] &&
          int.parse(_amountController.text.replaceAll(',', '')) <=
              registeredUsers[i][1]) {
        setState(() {
          sendingFeeOne = registeredUsers[i][2];
        });
        await calculateWithdrawalCharges();
        return;
      }

      // Calculate sending fees - one
      if (int.parse(_amountController.text.replaceAll(',', '')) >=
              registeredUsers[i][0] &&
          int.parse(_amountController.text.replaceAll(',', '')) <=
              registeredUsers[i][1]) {
        setState(() {
          sendingFeeOne = registeredUsers[i][2];
        });

        await calculateWithdrawalCharges();
        return;
      }
    }
  }

  calculateWithdrawalCharges() async {
    for (var i = 0; i < agentWithdrawal.length; i++) {
      if (int.parse(_amountController.text.replaceAll(',', '')) >=
              agentWithdrawal[i][0] &&
          int.parse(_amountController.text.replaceAll(',', '')) <=
              agentWithdrawal[i][1]) {
        setState(() {
          agentWithdrawalFee = agentWithdrawal[i][2];
        });
        await calculateBalances();
        return;
      }
    }
  }

  calculateBalances() {
    // Calculate amount to send - one
    setState(() {
      amountToSendOne = agentWithdrawalFee +
          int.parse(_amountController.text.replaceAll(',', ''));
      minimumBalanceOne =
          int.parse(_amountController.text.replaceAll(',', '')) +
              sendingFeeOne +
              agentWithdrawalFee;
    });
  }

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
                children: [
                  const SizedBox(height: 50.0),
                  const Text(
                    "Amount you wish to spend",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFNSR',
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  CupertinoTextField(
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    placeholder: "0.0",
                    placeholderStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFT-Bold',
                      fontSize: 32.0,
                    ),
                    controller: _amountController,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    onChanged: (string) {
                      if (!string.isEmpty) {
                        string = _formatNumber(string.replaceAll(',', ''));
                        _amountController.value = TextEditingValue(
                          text: string,
                          selection:
                              TextSelection.collapsed(offset: string.length),
                        );
                        calculateFees();
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TitleTab(title: "Sending to a registered number"),
                  const SizedBox(height: 15.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xff52B44B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: [
                        AmountTag(
                            title: "Amount to send",
                            amount: _formatNumber(amountToSendOne
                                .toString()
                                .replaceAll(',', ''))),
                        Divider(
                          color: const Color(0xff52B44B).withOpacity(0.1),
                          thickness: 2.0,
                        ),
                        AmountTag(
                            title: "Minimum balance",
                            amount: _formatNumber(minimumBalanceOne
                                .toString()
                                .replaceAll(',', ''))),
                        Divider(
                          color: const Color(0xff52B44B).withOpacity(0.1),
                          thickness: 2.0,
                        ),
                        AmountTag(
                            title: "Sending fee",
                            amount: _formatNumber(
                                sendingFeeOne.toString().replaceAll(',', ''))),
                        Divider(
                          color: const Color(0xff52B44B).withOpacity(0.1),
                          thickness: 2.0,
                        ),
                        AmountTag(
                            title: "Withdrawal charge",
                            amount: _formatNumber(agentWithdrawalFee
                                .toString()
                                .replaceAll(',', ''))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  TitleTab(title: "Sending to an unregistered number"),
                  const SizedBox(height: 15.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xff52B44B).withOpacity(0.1),
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
                  const SizedBox(height: 30.0),
                  TitleTab(title: "Withdraw at an agent"),
                  const SizedBox(height: 15.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xff52B44B).withOpacity(0.1),
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
                  const SizedBox(height: 30.0),
                  TitleTab(title: "Withdraw at an ATM"),
                  const SizedBox(height: 15.0),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xff52B44B).withOpacity(0.1),
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
                color: Color(0xff52B44B), fontSize: 14.0, fontFamily: "SFNSR"),
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
    );
  }
}
