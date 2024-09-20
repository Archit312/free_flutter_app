import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChartsGali extends StatefulWidget {
  final String gameId;
  const ChartsGali(this.gameId, {Key? key}) : super(key: key);

  @override
  _ChartsGaliState createState() => _ChartsGaliState();
}

class _ChartsGaliState extends State<ChartsGali> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('GamesData')
              .doc(widget.gameId)
              .get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Center(
                    child: Text(
                      'Matka ${snapshot.data!['name']} Result Chart',
                      style: const TextStyle(fontSize: 35),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('GamesData')
                        .doc(widget.gameId)
                        .collection('Games')
                        .where('resultdeclared', isEqualTo: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      var documents = snapshot.data!.docs;
                      return Expanded(
                        child: Center(
                          child: ListView.builder(
                              itemCount: documents.length + 1,
                              // gridDelegate:
                              //     const SliverGridDelegateWithFixedCrossAxisCount(
                              //         crossAxisCount: 6,
                              //         mainAxisSpacing: 20,
                              //         childAspectRatio: 9 / 16),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          //padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              border: Border.all(width: 2)),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Date',
                                              maxLines: 2,
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          //padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              border: Border.all(width: 2)),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Number',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                String result = documents[index - 1]['Numbers'];
                                // var res1 = result.substring(0, 3);
                                // var res2 = result.substring(4, 6);
                                // var res3 = result.substring(7, 10);
                                // print(res1);
                                // print(res2);
                                // print(res3);
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 2)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          documents[index - 1].id,
                                          maxLines: 2,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 2)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          result,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                      );
                    }),
              ],
            );
          }),
    );
  }
}
