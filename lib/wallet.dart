import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:matka/add_funds.dart';
import '/upi_payment.dart';
import '/wallet_history.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: must_be_immutable
class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _textEditingController2 = TextEditingController();
  @override
  void dispose() {
    _textEditingController.dispose();
    _textEditingController2.dispose();
    super.dispose();
  }

  void _showPicker(context, text) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('Settings')
                    .doc('data')
                    .get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Wrap(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Text(
                            'Contact Admin',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      ListTile(
                          leading: const Icon(Icons.add),
                          title: const Text('Add Request'),
                          onTap: () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Enter The amount to $text'),
                                    content: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextField(
                                              controller:
                                                  _textEditingController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                  hintText: 'Enter Amount')),
                                          text == 'transfer'
                                              ? const Padding(
                                                  padding: EdgeInsets.all(5.0),
                                                  child: Text(
                                                      'Enter Phone No of user you want to transfer points'),
                                                )
                                              : const Padding(
                                                  padding: EdgeInsets.all(5.0),
                                                  child:
                                                      Text('Enter your UPI Id'),
                                                ),
                                          TextField(
                                            controller: _textEditingController2,
                                            decoration: InputDecoration(
                                                hintText: text == 'transfer'
                                                    ? 'Phone No'
                                                    : 'UpiId'),
                                          ),
                                          ElevatedButton(
                                              onPressed: () async {
                                                var name = '';
                                                // ignore: prefer_typing_uninitialized_variables
                                                var bal;
                                                await FirebaseFirestore.instance
                                                    .collection('UsersData')
                                                    .doc(userID)
                                                    .get()
                                                    .then((value) {
                                                  name = value.data()!['Name'];
                                                  bal =
                                                      value.data()!['Balance'];
                                                });

                                                if (double.parse(
                                                        _textEditingController
                                                            .text
                                                            .trim()) <=
                                                    bal) {
                                                  FirebaseFirestore.instance
                                                      .collection('Requests')
                                                      .doc('${DateTime.now()}')
                                                      .set({
                                                    'request':
                                                        _textEditingController
                                                            .text
                                                            .trim(),
                                                    'id': userID,
                                                    'name': name,
                                                    'type': text,
                                                    'transferto':
                                                        _textEditingController2
                                                            .text,
                                                    'upiNo':
                                                        _textEditingController2
                                                            .text,
                                                  }).then((value) {
                                                    _textEditingController
                                                        .clear();
                                                    _textEditingController2
                                                        .clear();
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    Navigator.of(context).pop();
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "You Request Will Be Solved in 3 working Days",
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1,
                                                        // backgroundColor: Colors.red,
                                                        // textColor: Colors.white,
                                                        fontSize: 16.0);
                                                  });
                                                } else {
                                                  _textEditingController
                                                      .clear();
                                                  _textEditingController2
                                                      .clear();
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  Navigator.of(context).pop();
                                                  Fluttertoast.showToast(
                                                      msg: "Insufficient Funds",
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      timeInSecForIosWeb: 1,
                                                      // backgroundColor: Colors.red,
                                                      // textColor: Colors.white,
                                                      fontSize: 16.0);
                                                }
                                              },
                                              child: const Text('Submit'))
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          }),
                      ListTile(
                          leading: Image.asset(
                            'assets/phone.png',
                            width: 40,
                            height: 40,
                          ),
                          title: const Text('Phone'),
                          onTap: () async {
                            launch("tel://${snapshot.data!['whatsApp']}");
                          }),
                      ListTile(
                        leading: Image.asset(
                          'assets/whatsApp.png',
                          width: 50,
                          height: 50,
                        ),
                        title: const Text('WhatsApp'),
                        onTap: () async {
                          await launch(
                              "https://wa.me/+91${snapshot.data!['whatsApp']}?text=I want to $text my points.");
                        },
                      ),
                    ],
                  );
                }),
          );
        });
  }

  var userID = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: Column(
        children: [
          Center(
            child: CircleAvatar(
                radius: 50, child: Image.asset('assets/wallet.jpg')),
          ),
          const Center(
            child: Text(
              'Wallet',
              style: TextStyle(fontSize: 50),
            ),
          ),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('UsersData')
                  .doc(userID.toString().trim())
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapsot) {
                if (snapsot.connectionState == ConnectionState.waiting) {
                  return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Total Balance:',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Divider(),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Loading...',
                                style: TextStyle(fontSize: 25)),
                          ),
                        ],
                      ));
                }
                return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Total Balance:',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(snapsot.data!['Balance'].toString(),
                              style: const TextStyle(fontSize: 25)),
                        ),
                      ],
                    ));
              }),
          Expanded(
            child: GridView.count(
              primary: false,
              padding: const EdgeInsets.all(0),
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              crossAxisCount: 2,
              children: <Widget>[
                GestureDetector(
                  onTap: () => _showPicker(context, 'transfer'),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      //padding: const EdgeInsets.all(8),
                      elevation: 10,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      //padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/transfer.png',
                              width: 70,
                              height: 70,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Transfer Points',
                              style: TextStyle(fontSize: 15),
                            )
                          ],
                        ),
                      ),
                      //decoration:BoxDecoration(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const UpiPayment())),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      // padding: const EdgeInsets.all(8),
                      elevation: 10,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      // padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/addpoint.png',
                              width: 70,
                              height: 70,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Add Funds',
                              style: TextStyle(fontSize: 15),
                            )
                          ],
                        ),
                      ),
                      // decoration:BoxDecoration(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return const WalletHistory();
                  })),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      //padding: const EdgeInsets.all(8),
                      elevation: 10,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      //padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/wallistory.png',
                              width: 70,
                              height: 70,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Wallet History',
                              style: TextStyle(fontSize: 15),
                            )
                          ],
                        ),
                      ),
                      // decoration:BoxDecoration(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showPicker(context, 'withdraw'),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      // padding: const EdgeInsets.all(8),
                      elevation: 10,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18))),
                      // padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/withdpoints.png',
                              width: 70,
                              height: 70,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              'Withdraw Points',
                              style: TextStyle(fontSize: 15),
                            )
                          ],
                        ),
                      ),
                      // decoration:BoxDecoration(),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
