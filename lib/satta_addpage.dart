import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'wallet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class AddSatta extends StatefulWidget {
  final String type;
  final String gameId;
  final String gameName;
  final bool checker;
  const AddSatta(this.type, this.gameId, this.gameName, this.checker,
      {Key? key})
      : super(key: key);

  @override
  _AddSattaState createState() => _AddSattaState();
}

class _AddSattaState extends State<AddSatta> {
  int _radioValue = 0;
  var resultsout = false;
  var userID = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _pointseditingController =
      TextEditingController();
  final TextEditingController _pointseditingController2 =
      TextEditingController();
  final TextEditingController _pointseditingController3 =
      TextEditingController();
  final TextEditingController _pointseditingController4 =
      TextEditingController();
  String _session = '';
  bool _loading = false;
  double balance2 = 0;
  void _handelRadioValueChange(int? value) {
    setState(() {
      _radioValue = value!;
    });
    switch (_radioValue) {
      case 1:
        _session = 'Open';
        break;
      case 2:
        _session = 'Close';
        break;
    }
  }

  @override
  void dispose() {
    _pointseditingController.dispose();
    _pointseditingController2.dispose();
    _pointseditingController3.dispose();
    _pointseditingController4.dispose();
    super.dispose();
  }

  _submitFun() async {
    setState(() {
      _loading = true;
    });
    var obj = [
      {
        'amount': _pointseditingController.text.trim(),
        'timestamp': DateTime.now(),
        'type': 'bidPlaced',
        'type2': widget.type,
        'game': widget.gameId,
        'gameName': widget.gameName,
        'number': widget.type == 'Single Digit' ||
                widget.type == "Jodi" ||
                widget.type == 'Single Panna' ||
                widget.type == 'Double Panna' ||
                widget.type == 'Triple Panna' ||
                widget.type == 'Half Sangam'
            ? _pointseditingController2.text.trim()
            : widget.type == 'Full Sangam'
                ? _pointseditingController4.text.trim()
                : '',
        'session': _session,
        'extraNumber':
            widget.type == 'Half Sangam' || widget.type == 'Full Sangam'
                ? _pointseditingController3.text.trim()
                : '',
      }
    ];
    double finalprice;
    double? balance;
    await FirebaseFirestore.instance.collection('UsersData').doc(userID).update(
        {'Transaction': FieldValue.arrayUnion(obj)}).then((value) async {
      await FirebaseFirestore.instance
          .collection('UsersData')
          .doc(userID)
          .get()
          .then((value) {
        var price = value.data()!['Balance'];
        finalprice = double.parse('$price');
        balance = finalprice - double.parse(_pointseditingController.text);
      });
      await FirebaseFirestore.instance
          .collection('UsersData')
          .doc(userID)
          .update({'Balance': balance});
    }).then((value) {
      Fluttertoast.showToast(
          msg: "Bid Submitted Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          // backgroundColor: Colors.red,
          // textColor: Colors.white,
          fontSize: 16.0);
      FocusScope.of(context).unfocus();
    });

    // bids adding feature
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    String? name;
    await FirebaseFirestore.instance
        .collection('UsersData')
        .doc(userID)
        .get()
        .then((value) {
      name = value.data()!['Name'];
    });
    var obj2 = [
      {
        'amount': _pointseditingController.text.trim(),
        'timestamp': DateTime.now(),
        'person': userID,
        'name': name,
        'number': widget.type == 'Single Digit' ||
                widget.type == "Jodi" ||
                widget.type == 'Single Panna' ||
                widget.type == 'Double Panna' ||
                widget.type == 'Triple Panna' ||
                widget.type == 'Half Sangam'
            ? _pointseditingController2.text.trim()
            : widget.type == 'Full Sangam'
                ? _pointseditingController4.text.trim()
                : '',
        'type': widget.type,
        'session': _session,
        'extraNumber':
            widget.type == 'Half Sangam' || widget.type == 'Full Sangam'
                ? _pointseditingController3.text.trim()
                : '',
      }
    ];
    if (widget.checker) {
      DateTime now = DateTime.now();
      now.subtract(const Duration(days: 1));
      formattedDate = DateFormat('dd-MM-yyyy').format(now);
    }
    await FirebaseFirestore.instance
        .collection('GamesData')
        .doc(widget.gameId)
        .collection('Games')
        .doc(formattedDate)
        .get()
        .then((doc) async {
      if (doc.exists) {
        await FirebaseFirestore.instance
            .collection('GamesData')
            .doc(widget.gameId)
            .collection('Games')
            .doc(formattedDate)
            .update({'Bids': FieldValue.arrayUnion(obj2)}).then((value) {
          _pointseditingController.clear();
          _pointseditingController2.clear();
          _pointseditingController3.clear();
          _pointseditingController4.clear();
          setState(() {
            _loading = false;
          });
        });
      } else {
        await FirebaseFirestore.instance
            .collection('GamesData')
            .doc(widget.gameId)
            .collection('Games')
            .doc(formattedDate)
            .set({
          'Numbers': '',
          'resultdeclared': false,
          'opendeclared': false,
          'opendeclared2': false,
          'closedeclared': false,
          'Bids': FieldValue.arrayUnion(obj2),
          'winnerList': [],
        }).then((value) {
          _pointseditingController.clear();
          _pointseditingController2.clear();
          _pointseditingController3.clear();
          _pointseditingController4.clear();
          setState(() {
            _loading = false;
          });
        });
      }
    });
  }

  init2(String formattedDate) async {
    await FirebaseFirestore.instance
        .collection('GamesData')
        .doc(widget.gameId)
        .collection('Games')
        .doc(formattedDate)
        .set({
      'Numbers': '',
      'resultdeclared': false,
      'Bids': [],
      'opendeclared': false,
      'opendeclared2': false,
      'closedeclared': false,
      'winnerList': [],
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    return Scaffold(
      appBar: AppBar(title: Text(widget.type), actions: [
        GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Wallet()));
            },
            child: Row(
              children: [
                const Icon(Icons.wallet_travel),
                const SizedBox(
                  width: 5,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('UsersData')
                          .doc(userID.toString().trim())
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('0');
                        }
                        balance2 =
                            double.parse(snapshot.data!['Balance'].toString());
                        return Text(
                          snapshot.data!['Balance'].toString(),
                        );
                      }),
                ),
              ],
            )),
      ]),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(28.0, 12, 28, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (widget.type == 'Single Digit' ||
              widget.type == 'Single Panna' ||
              widget.type == 'Double Panna' ||
              widget.type == 'Triple Panna' ||
              widget.type == 'Half Sangam')
            const Text('Choose Session'),
          if (widget.type == 'Single Digit' ||
              widget.type == 'Single Panna' ||
              widget.type == 'Double Panna' ||
              widget.type == 'Triple Panna' ||
              widget.type == 'Half Sangam')
            Row(
              children: [
                // ignore: unnecessary_new
                FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('GamesData')
                        .doc(widget.gameId)
                        .collection('Games')
                        .doc(formattedDate)
                        .get(),
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 2,
                        );
                      }
                      if (!snapshot.data!.exists) {
                        init2(formattedDate);
                        Fluttertoast.showToast(
                            msg: "Please enter again!",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            fontSize: 16.0);
                        Navigator.of(context).pop();
                      } else {
                        if (!snapshot.data!['opendeclared2']) {
                          return Row(
                            children: [
                              Radio(
                                value: 1,
                                groupValue: _radioValue,
                                onChanged: _handelRadioValueChange,
                              ),
                              const Text('Open'),
                            ],
                          );
                        }
                      }
                      return const SizedBox(
                        width: 2,
                      );
                    }),

                // ignore: unnecessary_new
                Radio(
                  value: 2,
                  groupValue: _radioValue,
                  onChanged: _handelRadioValueChange,
                ),
                const Text('Close'),
              ],
            ),
          if (widget.type == 'Single Digit' || widget.type == "Jodi")
            const Text('Digits'),
          if (widget.type == 'Half Sangam')
            _radioValue == 1
                ? const Text('Open Digits')
                : const Text('Close Digits'),
          if (widget.type == 'Single Panna' ||
              widget.type == 'Double Panna' ||
              widget.type == 'Triple Panna')
            const Text('Panna'),
          if (widget.type == 'Single Digit' ||
              widget.type == "Jodi" ||
              widget.type == 'Single Panna' ||
              widget.type == 'Double Panna' ||
              widget.type == 'Triple Panna' ||
              widget.type == 'Half Sangam')
            TextField(
              controller: _pointseditingController2,
              keyboardType: TextInputType.number,
              maxLength: (widget.type == 'Single Panna' ||
                      widget.type == 'Double Panna' ||
                      widget.type == 'Triple Panna')
                  ? 3
                  : widget.type == "Jodi"
                      ? 2
                      : 1,
            ),
          if (widget.type == 'Full Sangam') const Text('Panna'),
          if (widget.type == 'Full Sangam')
            TextField(
                controller: _pointseditingController4,
                keyboardType: TextInputType.number,
                maxLength: 3),
          if (widget.type == 'Half Sangam')
            _radioValue == 1
                ? const Text('Close Panna')
                : const Text('Open Panna'),
          if (widget.type == 'Full Sangam') const Text('Panna'),
          if (widget.type == 'Half Sangam' || widget.type == 'Full Sangam')
            TextField(
                controller: _pointseditingController3,
                keyboardType: TextInputType.number,
                maxLength: 3),
          const Text('Points'),
          TextField(
            controller: _pointseditingController,
            keyboardType: TextInputType.number,
          ),
          Row(children: [
            Expanded(
              child: _loading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        if (_session == '' &&
                            widget.type != 'Jodi' &&
                            widget.type != 'Full Sangam') {
                          Fluttertoast.showToast(
                              msg: "Please select session.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              // backgroundColor: Colors.red,
                              // textColor: Colors.white,
                              fontSize: 16.0);
                        } else if (balance2 <
                            int.parse(_pointseditingController.text
                                .toString()
                                .trim())) {
                          Fluttertoast.showToast(
                              msg: "Insufficient Balance",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              // backgroundColor: Colors.red,
                              // textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          if (double.parse(_pointseditingController.text
                                      .toString()) <
                                  10.0 ||
                              _pointseditingController.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg: "Minimum Points for a bid is 10",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                // backgroundColor: Colors.red,
                                // textColor: Colors.white,
                                fontSize: 16.0);
                          } else {
                            if (widget.type == 'Single Panna') {
                              if (_pointseditingController2.text.trim().length <
                                  3) {
                                Fluttertoast.showToast(
                                    msg: "Invalid Entry of numbers",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    // backgroundColor: Colors.red,
                                    // textColor: Colors.white,
                                    fontSize: 16.0);
                              } else {
                                if (_pointseditingController2.text[0] ==
                                        _pointseditingController2.text[1] ||
                                    _pointseditingController2.text[1] ==
                                        _pointseditingController2.text[2] ||
                                    _pointseditingController2.text[0] ==
                                        _pointseditingController2.text[2]) {
                                  Fluttertoast.showToast(
                                      msg: "Invalid Entry of numbers",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      // backgroundColor: Colors.red,
                                      // textColor: Colors.white,
                                      fontSize: 16.0);
                                } else {
                                  _submitFun();
                                }
                              }
                            } else if (widget.type == 'Triple Panna') {
                              if (_pointseditingController2.text.trim().length <
                                  3) {
                                Fluttertoast.showToast(
                                    msg: "Invalid Entry of numbers",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    // backgroundColor: Colors.red,
                                    // textColor: Colors.white,
                                    fontSize: 16.0);
                              } else {
                                if (_pointseditingController2.text[0] !=
                                        _pointseditingController2.text[1] ||
                                    _pointseditingController2.text[1] !=
                                        _pointseditingController2.text[2] ||
                                    _pointseditingController2.text[0] !=
                                        _pointseditingController2.text[2]) {
                                  Fluttertoast.showToast(
                                      msg: "Invalid Entry of numbers",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      // backgroundColor: Colors.red,
                                      // textColor: Colors.white,
                                      fontSize: 16.0);
                                } else {
                                  _submitFun();
                                }
                              }
                            } else if (widget.type == 'Double Panna') {
                              if (_pointseditingController2.text.trim().length <
                                  3) {
                                Fluttertoast.showToast(
                                    msg: "Invalid Entry of numbers",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    // backgroundColor: Colors.red,
                                    // textColor: Colors.white,
                                    fontSize: 16.0);
                              } else {
                                if ((_pointseditingController2.text[0] ==
                                            _pointseditingController2.text[1] &&
                                        _pointseditingController2.text[1] ==
                                            _pointseditingController2
                                                .text[2]) ||
                                    (_pointseditingController2.text[0] !=
                                            _pointseditingController2.text[1] &&
                                        _pointseditingController2.text[1] !=
                                            _pointseditingController2
                                                .text[2])) {
                                  Fluttertoast.showToast(
                                      msg: "Invalid Entry of numbers",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      // backgroundColor: Colors.red,
                                      // textColor: Colors.white,
                                      fontSize: 16.0);
                                } else {
                                  _submitFun();
                                }
                              }
                            } else {
                              if (widget.type == 'Half Sangam' && _pointseditingController3.text.trim().length < 3 ||
                                  widget.type == 'Full Sangam' &&
                                      _pointseditingController3.text
                                              .trim()
                                              .length <
                                          3 ||
                                  widget.type == 'Full Sangam' &&
                                      _pointseditingController4.text
                                              .trim()
                                              .length <
                                          3 ||
                                  widget.type == 'Half Sangam' &&
                                      _pointseditingController2.text
                                          .trim()
                                          .isEmpty ||
                                  widget.type == 'Single Digit' &&
                                      _pointseditingController2.text
                                          .trim()
                                          .isEmpty ||
                                  widget.type == 'Jodi' &&
                                      _pointseditingController2.text
                                              .trim()
                                              .length <
                                          2) {
                                Fluttertoast.showToast(
                                    msg: "Invalid Entry of numbers",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    // backgroundColor: Colors.red,
                                    // textColor: Colors.white,
                                    fontSize: 16.0);
                              } else {
                                _submitFun();
                              }
                            }
                          }
                        }
                      },
                      child: const Text('PROCEED'),
                    ),
            )
          ]),
        ]),
      ),
    );
  }
}
