import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'wallet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class GaliAddSatta extends StatefulWidget {
  final String type;
  final String gameId;
  final String gameName;
  const GaliAddSatta(this.type, this.gameId, this.gameName, {Key? key})
      : super(key: key);

  @override
  _GaliAddSattaState createState() => _GaliAddSattaState();
}

class _GaliAddSattaState extends State<GaliAddSatta> {
  var userID = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _pointseditingController =
      TextEditingController();
  final TextEditingController _pointseditingController2 =
      TextEditingController();
  double balance2 = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _pointseditingController.dispose();
    _pointseditingController2.dispose();
    super.dispose();
  }

  _submitFun() async {
    setState(() {
      _isLoading = true;
    });
    var obj = [
      {
        'amount': _pointseditingController.text.trim(),
        'timestamp': DateTime.now(),
        'type': 'bidPlaced',
        'game': widget.gameId,
        'gameName': widget.gameName,
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
        'number': _pointseditingController2.text.trim().toString(),
        'type': widget.type,
        'extraNumber': '',
      }
    ];
    FirebaseFirestore.instance
        .collection('GamesData')
        .doc(widget.gameId)
        .collection('Games')
        .doc(formattedDate)
        .get()
        .then((doc) {
      if (doc.exists) {
        FirebaseFirestore.instance
            .collection('GamesData')
            .doc(widget.gameId)
            .collection('Games')
            .doc(formattedDate)
            .update({'Bids': FieldValue.arrayUnion(obj2)}).then((value) {
          _pointseditingController.clear();
          _pointseditingController2.clear();
        });
      } else {
        FirebaseFirestore.instance
            .collection('GamesData')
            .doc(widget.gameId)
            .collection('Games')
            .doc(formattedDate)
            .set({
          'Numbers': '',
          'resultdeclared': false,
          'Bids': FieldValue.arrayUnion(obj2),
          'opendeclared': false,
          'opendeclared2': false,
          'closedeclared': false,
          'winnerList': [],
        }).then((value) {
          _pointseditingController.clear();
          _pointseditingController2.clear();
        });
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          const Text('Digits'),
          TextField(
            controller: _pointseditingController2,
            keyboardType: TextInputType.number,
            maxLength:
                (widget.type == 'Right Digit' || widget.type == 'Left Digit')
                    ? 1
                    : 2,
          ),
          const Text('Points'),
          TextField(
            controller: _pointseditingController,
            keyboardType: TextInputType.number,
          ),
          Row(children: [
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        if (balance2 <
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
                            if (widget.type == 'Jodi Digit') {
                              if (_pointseditingController2.text.trim().length <
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
                            } else {
                              if (_pointseditingController2.text
                                  .trim()
                                  .isEmpty) {
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
