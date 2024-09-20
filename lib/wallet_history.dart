import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WalletHistory extends StatefulWidget {
  const WalletHistory({Key? key}) : super(key: key);

  @override
  _WalletHistoryState createState() => _WalletHistoryState();
}

class _WalletHistoryState extends State<WalletHistory> {
  var userID = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet History'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('UsersData')
            .doc(userID.toString().trim())
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          var documents = snapshot.data!['Transaction'];
          var temp2 = documents.reversed;
          documents = List.from(temp2);
          if (documents.length == 0) {
            return const Center(
              child: Text('No Transaction History'),
            );
          }
          return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                String formattedDate = DateFormat('dd/MM/yyyy - hh:mm a')
                    .format(DateTime.fromMillisecondsSinceEpoch(
                        documents[index]['timestamp'].seconds * 1000));
                return Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  elevation: 5,
                  child: Center(
                    child: ListTile(
                        leading: documents[index]['type'] == "winning" ||
                                documents[index]['type'] == "addamount" ||
                                documents[index]['type'] == "bonus"
                            ? const Icon(
                                Icons.arrow_upward_rounded,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.arrow_downward_rounded,
                                color: Colors.red,
                              ),
                        title: documents[index]['type'] == "winning" ||
                                documents[index]['type'] == "addamount" ||
                                documents[index]['type'] == "bonus"
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  (documents[index]['type'] == "winning")
                                      ? FutureBuilder(
                                          future: FirebaseFirestore.instance
                                              .collection('GamesData')
                                              .doc(documents[index]['game']
                                                  .toString()
                                                  .trim())
                                              .get(),
                                          builder: (context,
                                              AsyncSnapshot<DocumentSnapshot>
                                                  snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Text('');
                                            }
                                            return Text(
                                              documents[index]['type'] ==
                                                      "winning"
                                                  ? 'Won in ${documents[index]['gameName']}'
                                                  : documents[index]['type'] ==
                                                          "addamount"
                                                      ? 'Amount Added'
                                                      : 'Bonus awarded',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            );
                                          })
                                      : Text(
                                          documents[index]['type'] == "winning"
                                              ? 'Won in ${documents[index]['gameName']}'
                                              : documents[index]['type'] ==
                                                      "addamount"
                                                  ? 'Amount Added'
                                                  : 'Bonus awarded',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                  Text(
                                    '+${documents[index]['amount']}',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  documents[index]['type'] == "bidPlaced"
                                      ? FutureBuilder(
                                          future: FirebaseFirestore.instance
                                              .collection('GamesData')
                                              .doc(documents[index]['game']
                                                  .toString()
                                                  .trim())
                                              .get(),
                                          builder: (context,
                                              AsyncSnapshot<DocumentSnapshot>
                                                  snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Text('');
                                            }
                                            return Text(
                                              documents[index]['type'] ==
                                                      "bidPlaced"
                                                  ? 'Placed bid in ${documents[index]['gameName']}'
                                                  : 'Amount withdrawal',
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            );
                                          },
                                        )
                                      : Text(
                                          documents[index]['type'] ==
                                                  "bidPlaced"
                                              ? 'Placed bid in ${documents[index]['gameName']}'
                                              : 'Amount withdrawal',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                  Text(
                                    '-${documents[index]['amount']}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                        subtitle: Text(formattedDate)),
                  ),
                );
              });
        },
      ),
    );
  }
}
