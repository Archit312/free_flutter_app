import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Alerts extends StatefulWidget {
  const Alerts({Key? key}) : super(key: key);

  @override
  _AlertsState createState() => _AlertsState();
}

class _AlertsState extends State<Alerts> {
  var userID = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
          var documents = snapshot.data!['alerts'];
          var temp2 = documents.reversed;
          documents = List.from(temp2);
          if (documents.length == 0) {
            return const Center(
              child: Text('No Alerts'),
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
                        leading: const Icon(Icons.notifications),
                        title: Text('${documents[index]['title']}'),
                        subtitle: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${documents[index]['body']}'),
                            Text(formattedDate),
                          ],
                        )),
                  ),
                );
              });
        },
      ),
    );
  }
}
