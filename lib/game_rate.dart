import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GameRates extends StatelessWidget {
  const GameRates({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Rates'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Rates')
            .doc('rates')
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          var document = snapshot.data;
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    leading: const Text(
                      'Single Digit',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: Text(
                      '10-${document!['singleDigit']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    leading: const Text(
                      'Jodi',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: Text(
                      '10-${document['jodi']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    leading: const Text(
                      'Single Panna',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: Text(
                      '10-${document['singlePanna']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    leading: const Text(
                      'Double Panna',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: Text(
                      '10-${document['doublePanna']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    leading: const Text(
                      'Triple Panna',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: Text(
                      '10-${document['triplePanna']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    leading: const Text(
                      'Half Sangam',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: Text(
                      '10-${document['halfSangam']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    leading: const Text(
                      'Full Sangam',
                      style: TextStyle(fontSize: 18),
                    ),
                    trailing: Text(
                      '10-${document['fullSangam']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
