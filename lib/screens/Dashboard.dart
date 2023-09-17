import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/data.dart';
import '../widgets/AmountTag.dart';
import '../widgets/TitleTab.dart';

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

  var statusMessage = "";

  var minimumBalanceOne = 0;

  var sendingFeeOne = 0;
  var sendingFeeTwo = 0;

  var amountToSendOne = 0;
  var amountToSendTwo = 0;

  var agentWithdrawalFee = 0;
  var atmWithdrawalFee = 0;
  var withdrawableAmountAgent = 0;
  var withdrawableAmountAtm = 0;

  var notSupported = false;
  var atmNotSupported = false;

  calculateUnregisteredFees() {
    for (var i = 0; i < unregisteredUsers.length; i++) {
      // Calculate sending fees for unregistered numbers - two
      if (int.parse(_amountController.text.replaceAll(',', '')) >=
              unregisteredUsers[i][0] &&
          int.parse(_amountController.text.replaceAll(',', '')) <=
              unregisteredUsers[i][1]) {
        setState(() {
          sendingFeeTwo = unregisteredUsers[i][2];
          amountToSendTwo =
              int.parse(_amountController.text.replaceAll(',', '')) +
                  sendingFeeTwo;
        });
        return;
      }
    }
  }

  calculateFees() async {
    for (var i = 0; i < registeredUsers.length; i++) {
      // Calculate sending fees - one
      if (int.parse(_amountController.text.replaceAll(',', '')) >=
              registeredUsers[i][0] &&
          int.parse(_amountController.text.replaceAll(',', '')) <=
              registeredUsers[i][1]) {
        setState(() {
          sendingFeeOne = registeredUsers[i][2];
        });
        await calculateAgentWithdrawalCharges();
        await calculateAtmWithdrawalCharges();
        return;
      }
    }
  }

  calculateAgentWithdrawalCharges() async {
    for (var i = 0; i < agentWithdrawal.length; i++) {
      if (int.parse(_amountController.text.replaceAll(',', '')) >=
              agentWithdrawal[i][0] &&
          int.parse(_amountController.text.replaceAll(',', '')) <=
              agentWithdrawal[i][1]) {
        setState(() {
          agentWithdrawalFee = agentWithdrawal[i][2];

          withdrawableAmountAgent =
              int.parse(_amountController.text.replaceAll(',', '')) -
                  agentWithdrawalFee;
        });
        await calculateBalances();
        return;
      }
    }
  }

  calculateAtmWithdrawalCharges() async {
    for (var i = 0; i < atmWithdrawal.length; i++) {
      if (int.parse(_amountController.text.replaceAll(',', '')) >=
              atmWithdrawal[i][0] &&
          int.parse(_amountController.text.replaceAll(',', '')) <=
              atmWithdrawal[i][1]) {
        setState(() {
          atmWithdrawalFee = atmWithdrawal[i][2];

          withdrawableAmountAtm =
              int.parse(_amountController.text.replaceAll(',', '')) -
                  atmWithdrawalFee;
        });
        await calculateBalances();
        return;
      }
    }
  }

  calculateBalances() {
    if (_amountController.text.replaceAll(',', '').isEmpty) {
      setState(() {
        amountToSendOne = 0;
        minimumBalanceOne = 0;
      });
    } else {
      setState(() {
        amountToSendOne = agentWithdrawalFee +
            int.parse(_amountController.text.replaceAll(',', ''));
        minimumBalanceOne =
            int.parse(_amountController.text.replaceAll(',', '')) +
                sendingFeeOne +
                agentWithdrawalFee;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                      "Amount you wish to send",
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
                        setState(() {
                          statusMessage = "";
                        });

                        if (string.isNotEmpty) {
                          string = _formatNumber(string.replaceAll(',', ''));
                          _amountController.value = TextEditingValue(
                            text: string,
                            selection:
                                TextSelection.collapsed(offset: string.length),
                          );

                          if (string.replaceAll(',', '') == "6969") {
                            setState(() {
                              statusMessage = "Nice!";
                            });
                          }

                          if (string.replaceAll(',', '') == "999999") {
                            setState(() {
                              statusMessage = "You wish!";
                            });
                          }

                          print(string);

                          if (int.parse(
                                  _amountController.text.replaceAll(',', '')) >
                              35000) {
                            setState(() {
                              atmNotSupported = true;
                            });
                          } else {
                            setState(() {
                              atmNotSupported = false;
                            });
                          }

                          if (int.parse(
                                  _amountController.text.replaceAll(',', '')) >
                              150000) {
                            setState(() {
                              notSupported = true;
                            });
                          } else {
                            notSupported = false;
                            calculateFees();
                            calculateUnregisteredFees();
                          }
                        } else {
                          setState(() {
                            minimumBalanceOne = 0;
                            sendingFeeOne = 0;
                            sendingFeeTwo = 0;
                            amountToSendOne = 0;
                            amountToSendTwo = 0;
                            agentWithdrawalFee = 0;
                            atmWithdrawalFee = 0;
                            withdrawableAmountAgent = 0;
                            withdrawableAmountAtm = 0;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 10.0),
                    statusMessage.isEmpty
                        ? Container()
                        : Container(
                            padding: EdgeInsets.only(
                              top: 4.0,
                              bottom: 4.0,
                              left: 20.0,
                              right: 20.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: Text(
                              statusMessage,
                              style: TextStyle(
                                fontFamily: 'AR',
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const TitleTab(title: "Sending to a registered number"),
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
                              amount: notSupported == true
                                  ? "N/A"
                                  : _formatNumber(amountToSendOne
                                      .toString()
                                      .replaceAll(',', ''))),
                          Divider(
                            color: const Color(0xff52B44B).withOpacity(0.1),
                            thickness: 2.0,
                          ),
                          AmountTag(
                            title: "Account minimum balance",
                            amount: notSupported == true
                                ? "N/A"
                                : _formatNumber(
                                    minimumBalanceOne
                                        .toString()
                                        .replaceAll(',', ''),
                                  ),
                          ),
                          Divider(
                            color: const Color(0xff52B44B).withOpacity(0.1),
                            thickness: 2.0,
                          ),
                          AmountTag(
                            title: "Sending fee",
                            amount: notSupported == true
                                ? "N/A"
                                : _formatNumber(
                                    sendingFeeOne
                                        .toString()
                                        .replaceAll(',', ''),
                                  ),
                          ),
                          Divider(
                            color: const Color(0xff52B44B).withOpacity(0.1),
                            thickness: 2.0,
                          ),
                          AmountTag(
                            title: "Withdrawal charge",
                            amount: notSupported == true
                                ? "N/A"
                                : _formatNumber(
                                    agentWithdrawalFee
                                        .toString()
                                        .replaceAll(',', ''),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    const TitleTab(title: "Sending to an unregistered number"),
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
                            title: "Account minimum balance",
                            amount: notSupported == true
                                ? "N/A"
                                : _formatNumber(
                                    amountToSendTwo
                                        .toString()
                                        .replaceAll(',', ''),
                                  ),
                          ),
                          Divider(
                            color: const Color(0xff52B44B).withOpacity(0.1),
                            thickness: 2.0,
                          ),
                          AmountTag(
                            title: "Sending fee",
                            amount: notSupported == true
                                ? "N/A"
                                : _formatNumber(
                                    sendingFeeTwo
                                        .toString()
                                        .replaceAll(',', ''),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    const TitleTab(title: "Withdraw at an agent"),
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
                            title: "Withdrawal charge",
                            amount: notSupported == true
                                ? "N/A"
                                : _formatNumber(
                                    agentWithdrawalFee
                                        .toString()
                                        .replaceAll(',', ''),
                                  ),
                          ),
                          Divider(
                            color: const Color(0xff52B44B).withOpacity(0.1),
                            thickness: 2.0,
                          ),
                          AmountTag(
                            title: "Withdrawable amount",
                            amount: notSupported == true
                                ? "N/A"
                                : _formatNumber(
                                    withdrawableAmountAgent
                                        .toString()
                                        .replaceAll(',', ''),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    const TitleTab(title: "Withdraw at an ATM"),
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
                            title: "Withdrawal charge",
                            amount:
                                notSupported == true || atmNotSupported == true
                                    ? "N/A"
                                    : _formatNumber(
                                        atmWithdrawalFee
                                            .toString()
                                            .replaceAll(',', ''),
                                      ),
                          ),
                          Divider(
                            color: const Color(0xff52B44B).withOpacity(0.1),
                            thickness: 2.0,
                          ),
                          AmountTag(
                            title: "Withdrawable amount",
                            amount:
                                notSupported == true || atmNotSupported == true
                                    ? "N/A"
                                    : _formatNumber(
                                        withdrawableAmountAtm
                                            .toString()
                                            .replaceAll(',', ''),
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
