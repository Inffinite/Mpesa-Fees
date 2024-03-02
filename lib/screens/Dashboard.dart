import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mpesafees/database/database_helper.dart';
import 'package:http/http.dart' as http;

import '../data/data.dart';
import '../widgets/AmountTag.dart';
import '../widgets/TitleTab.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

enum Availability { loading, available, unavailable }

class _DashboardState extends State<Dashboard> {
  final InAppReview _inAppReview = InAppReview.instance;
  final _dbHelper = DatabaseHelper.instance;

  String _appStoreId = 'com.wrenix.mpesafees';
  Availability _availability = Availability.loading;

  final TextEditingController _amountController = TextEditingController();
  static const _locale = 'en';
  String _formatNumber(String s) =>
      NumberFormat.decimalPattern(_locale).format(int.parse(s));

  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'en_US', symbol: '\$');

  TextEditingController messagecontroller = TextEditingController();

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

  String buttonState = "notloading";

  var mptheme = "light";

  Color grn = Color(0xff52B44B);
  Color white = Colors.white;

  Color darkBlack = Color(0xff000000);

  var sendBtnText = "Send";

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

  checkTheme() async {
    var rows = await _dbHelper.queryAllRows("mpesafeesInfo");

    if (rows[0]['theme'] == "light") {
      setState(() {
        mptheme = "light";
      });
    } else {
      setState(() {
        mptheme = "dark";
      });
    }
  }

  checkDay() {
    final now = DateTime.now();
    return now.day;
  }

  setupDayOfInstall() async {
    var rowCount = await _dbHelper.queryRowCount("dayOfInstall");

    var today = checkDay();

    if (rowCount == 0) {
      await _dbHelper.insert({"day": today}, "dayOfInstall");
    } else {
      var rows = await _dbHelper.queryAllRows("dayOfInstall");

      print("[+] DAY ADDED: ${rows[0]['day']}");

      if (rows[0]['day'] != today) {
        addReview();
      }
    }
  }

  setupReview() async {
    var rowCount = await _dbHelper.queryRowCount("review");

    // 0 - user has not reviewed us
    // 1 - user has reviewed us

    if (rowCount == 0) {
      log("No rows");
      await _dbHelper.insert({"reviewed": 0}, "review");
    }
  }

  addReview() async {
    var rows = await _dbHelper.queryAllRows("review");

    if (rows[0]['reviewed'] == 0) {
      _requestReview();
      await _dbHelper.update({"_id": 1, "reviewed": 1}, "review");
      log("Reviewed successfully");
    } else {
      log("Already reviewed");
    }
  }

  sendHome(message) async {
    setState(() {
      buttonState = 'loading';
    });
    final res = await http.Client().post(
      Uri.parse(dotenv.env['URL'].toString()),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'content': '**MPESA FEES FEEDBACK MESSAGE**\n$message',
        'name': dotenv.env['USERNAME'],
        'type': dotenv.env['TYPE'],
        'token': dotenv.env['TOKEN']
      }),
    );

    setState(() {
      buttonState = 'notloading';
    });
    return;
  }

  buttonStatus() {
    switch (buttonState) {
      case "loading":
        return LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.white,
          size: 25.0,
        );
      case "notloading":
        return Text(
          'Send',
          style: TextStyle(
            fontSize: 16.0,
            color: Color(0xff52B44B),
            fontFamily: "AR",
          ),
        );
    }
  }

  feedbackModal(context) {
    showModalBottomSheet(
      showDragHandle: true,
      backgroundColor: Color(0xff52B44B),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Wrap(
              children: [
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Feedback",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "Give us your ideas for new features",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.normal,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        CupertinoTextField(
                          padding: EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 71, 160, 65),
                              borderRadius: BorderRadius.circular(20.0)),
                          scrollPhysics: const BouncingScrollPhysics(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                          controller: messagecontroller,
                          onChanged: (text) {},
                          cursorColor: Colors.white,
                          maxLines: 5,
                          placeholder: "Whats on your mind...",
                          obscureText: false,
                          placeholderStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontFamily: "SFNSR",
                            fontSize: 18.0,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(
                            bottom: 10.0,
                            left: 0.0,
                            right: 0.0,
                            top: 10.0,
                          ),
                          child: CupertinoButton(
                            padding: const EdgeInsets.only(
                              top: 15.0,
                              bottom: 15.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                            child: Text(
                              sendBtnText,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Color(0xff52B44B),
                                fontFamily: "AR",
                              ),
                            ),
                            onPressed: () {
                              if (sendBtnText != "Message sent successfully!") {
                                setState(() {
                                  sendBtnText = "Sending...";
                                });
                                var mymessage = messagecontroller.text;
                                if (mymessage.length == 0) {
                                  print("DO NOTHING");
                                } else {
                                  sendHome(messagecontroller.text);
                                  messagecontroller.text = "";
                                  setState(() {
                                    sendBtnText = "Message sent successfully!";
                                  });
                                }
                              } else {
                                log("Can't send twice in a row.");
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
    );
  }

  checkKeyboard() {
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    if (isKeyboardOpen) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _requestReview() => _inAppReview.requestReview();

  Future<void> _openStoreListing() => _inAppReview.openStoreListing(
        appStoreId: _appStoreId,
      );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkTheme();
    (<T>(T? o) => o!)(WidgetsBinding.instance).addPostFrameCallback((_) async {
      try {
        final isAvailable = await _inAppReview.isAvailable();

        setState(() {
          // This plugin cannot be tested on Android by installing your app
          // locally. See https://github.com/britannio/in_app_review#testing for
          // more information.
          _availability = isAvailable && !Platform.isAndroid
              ? Availability.available
              : Availability.unavailable;
        });
      } catch (_) {
        setState(() => _availability = Availability.unavailable);
      }
    });

    setupReview();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: mptheme == "light" ? white : darkBlack,
        floatingActionButton: checkKeyboard()
            ? FloatingActionButton(
                onPressed: () {
                  _amountController.clear();
                },
                child: Icon(Icons.clear),
              )
            : Container(),
        appBar: AppBar(
          title: Text(
            "Mpesa Fees",
            style: TextStyle(
              fontSize: 18.0,
              fontFamily: "SFT-Bold",
              color: mptheme == "light" ? Colors.white : Colors.black,
            ),
          ),
          leading: Container(
            margin: EdgeInsets.only(
              left: 15.0,
            ),
            child: IconButton(
              icon: Icon(
                mptheme == "dark" ? Icons.light_mode : Icons.dark_mode,
                size: 26.0,
                color: mptheme == "light" ? Colors.white : Colors.black,
              ),
              onPressed: () async {
                if (mptheme == "light") {
                  setState(() {
                    mptheme = "dark";
                  });

                  var rowCount = await _dbHelper.queryRowCount("mpesafeesInfo");

                  if (rowCount == 0) {
                    await _dbHelper.insert({"theme": "dark"}, "mpesafeesInfo");
                  } else {
                    await _dbHelper
                        .update({"_id": 1, "theme": "dark"}, "mpesafeesInfo");
                  }
                } else {
                  setState(() {
                    mptheme = "light";
                  });

                  var rowCount = await _dbHelper.queryRowCount("mpesafeesInfo");

                  if (rowCount == 0) {
                    await _dbHelper.insert({"theme": "light"}, "mpesafeesInfo");
                  } else {
                    await _dbHelper
                        .update({"_id": 1, "theme": "light"}, "mpesafeesInfo");
                  }
                }
              },
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(
                right: 15.0,
              ),
              child: IconButton(
                icon: Icon(
                  CupertinoIcons.chat_bubble_2_fill,
                  size: 26.0,
                  color: mptheme == "light" ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  _amountController.clear();
                  setState(() {
                    sendBtnText = "Send";
                    messagecontroller.text = "";
                  });

                  feedbackModal(context);
                },
              ),
            ),
          ],
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Color(0xff52B44B),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 130.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: grn,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 0.0),
                    Text(
                      "Amount you wish to send",
                      style: TextStyle(
                        color: mptheme == "light" ? white : darkBlack,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    CupertinoTextField(
                      cursorColor: mptheme == "light" ? white : darkBlack,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      placeholder: "ksh 0",
                      cursorOpacityAnimates: true,
                      placeholderStyle: TextStyle(
                        color: mptheme == "light"
                            ? white.withOpacity(0.3)
                            : darkBlack.withOpacity(0.3),
                      ),
                      style: TextStyle(
                        fontFamily: "SFT-Bold",
                        fontSize: 35.0,
                        color: mptheme == "light" ? white : darkBlack,
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
                              color: mptheme == "light"
                                  ? white
                                  : darkBlack.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: Text(
                              statusMessage,
                              style: TextStyle(
                                fontFamily: 'AR',
                                color: mptheme == "light" ? white : darkBlack,
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
                    TitleTab(
                      title: "Sending to a registered number",
                      mptheme: mptheme,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: grn.withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
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
                            color: grn.withOpacity(0.1),
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
                            color: grn.withOpacity(0.1),
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
                            color: grn.withOpacity(0.1),
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
                    TitleTab(
                      title:
                          "Sending to pochi la biashara and business till to customer",
                      mptheme: mptheme,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: grn.withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
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
                            color: grn.withOpacity(0.1),
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
                            color: grn.withOpacity(0.1),
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
                            color: grn.withOpacity(0.1),
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
                    TitleTab(
                      title: "Sending to an unregistered number",
                      mptheme: mptheme,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: grn.withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
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
                            color: grn.withOpacity(0.1),
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
                    TitleTab(
                      title: "Withdraw at an agent",
                      mptheme: mptheme,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: grn.withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
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
                            color: grn.withOpacity(0.1),
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
                    TitleTab(
                      title: "Withdraw at an ATM",
                      mptheme: mptheme,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: grn.withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
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
                            color: grn.withOpacity(0.1),
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
                    SizedBox(height: 25.0),
                    Text(
                      "Powered by Wrenix Studio",
                      style: TextStyle(color: grn, fontSize: 12.0),
                    ),
                    SizedBox(height: 5.0),
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
