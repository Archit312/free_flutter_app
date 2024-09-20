import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  final String type;
  const History(this.type, {Key? key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  var userID = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.type} History'),
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
          // print(temp2);
          List? temp = [];
          if (widget.type == 'Win') {
            for (int i = 0; i < documents.length; i++) {
              if (documents[i]['type'] == 'winning') {
                temp.add(documents[i]);
              }
            }
          } else {
            for (int i = 0; i < documents.length; i++) {
              if (documents[i]['type'] == 'bidPlaced') {
                temp.add(documents[i]);
              }
            }
          }
          if (widget.type == 'Win' && temp.isEmpty) {
            return const Center(
              child: Text('No Win History'),
            );
          }
          if (widget.type == 'Bid' && temp.isEmpty) {
            return const Center(
              child: Text('No Bid History'),
            );
          }
          return ListView.builder(
              itemCount: temp.length,
              itemBuilder: (context, index) {
                String formattedDate = DateFormat('dd/MM/yyyy - hh:mm a')
                    .format(DateTime.fromMillisecondsSinceEpoch(
                        temp[index]['timestamp'].seconds * 1000));
                return Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  elevation: 5,
                  child: Center(
                    child: ListTile(
                        leading: widget.type == 'Win'
                            ? const Icon(
                                Icons.arrow_upward_rounded,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.arrow_downward_rounded,
                                color: Colors.red,
                              ),
                        title: widget.type == 'Win'
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FutureBuilder(
                                      future: FirebaseFirestore.instance
                                          .collection('GamesData')
                                          .doc(temp[index]['game']
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
                                          'Won in ${temp[index]['gameName']}',
                                          style: const TextStyle(fontSize: 20),
                                        );
                                      }),
                                  Text('Type - ' '${temp[index]['type2']}'),
                                  Text(
                                    '${temp[index]['session']} Session',
                                  ),
                                  Text(
                                    '+${temp[index]['amount']}',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FutureBuilder(
                                    future: FirebaseFirestore.instance
                                        .collection('GamesData')
                                        .doc(temp[index]['game']
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
                                        'Placed bid in ${temp[index]['gameName']}',
                                        style: const TextStyle(fontSize: 20),
                                      );
                                    },
                                  ),
                                  Text('Type - ' '${temp[index]['type2']}'),
                                  Text('Bid'
                                      ' '
                                      '- ${temp[index]['number']}'
                                      '  '
                                      '${temp[index]['extraNumber']}'),
                                  Text(
                                    'Session - ' '${temp[index]['session']}',
                                  ),
                                  Text(
                                    '-${temp[index]['amount']}',
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
