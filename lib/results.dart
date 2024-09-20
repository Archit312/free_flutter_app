import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Charts extends StatefulWidget {
  final String gameId;
  const Charts(this.gameId, {Key? key}) : super(key: key);

  @override
  _ChartsState createState() => _ChartsState();
}

class _ChartsState extends State<Charts> {
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
                        .orderBy("created")
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      var documents = snapshot.data!.docs;
                      return Expanded(
                        child: GridView.builder(
                            itemCount: documents.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 6,
                                    mainAxisSpacing: 5,
                                    childAspectRatio: 9 / 16),
                            itemBuilder: (context, index) {
                              String result = documents[index]['Numbers'];
                              if (result.length == 5) {
                                result = "$result*-***";
                              }
                              var res1 = result.substring(0, 3);
                              var res2 = result.substring(4, 6);
                              var res3 = result.substring(7, 10);
                              // print(res1);
                              // print(res2);
                              // print(res3);
                              return SizedBox(
                                //color: Colors.redAccent,
                                height:
                                    MediaQuery.of(context).size.width * 0.20,
                                width: MediaQuery.of(context).size.width * 0.12,
                                //color: Colors.redAccent,
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 2)),
                                      child: Text(
                                        documents[index].id,
                                        maxLines: 2,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 2)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: MyVerticalText(res1),
                                            )),
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            res2,
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(width: 2)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: MyVerticalText(res3),
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                      );
                    }),
              ],
            );
          }),
    );
  }
}

class MyVerticalText extends StatelessWidget {
  final String text;

  const MyVerticalText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 30,
      direction: Axis.vertical,
      alignment: WrapAlignment.center,
      children: text
          .split("")
          .map((string) => Text(string, style: const TextStyle(fontSize: 18)))
          .toList(),
    );
  }
}
