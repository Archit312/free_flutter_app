import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '/charts_gali.dart';
import 'selectgame_gali.dart';
import 'package:google_fonts/google_fonts.dart';

class GaliDeswar extends StatefulWidget {
  const GaliDeswar({Key? key}) : super(key: key);

  @override
  _GaliDeswarState createState() => _GaliDeswarState();
}

class _GaliDeswarState extends State<GaliDeswar> {
  final Duration duration = const Duration(milliseconds: 500);
  double deltaX = 0;
  final Curve curve = Curves.bounceOut;
  double shake(double animation) =>
      2 * (0.5 - (0.5 - curve.transform(animation)).abs());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gali Desawar'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Card(
            color: Colors.blue[300],
            elevation: 10,
            clipBehavior: Clip.hardEdge,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.zero,
                    topRight: Radius.zero,
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Container(
              //clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.zero,
                      topRight: Radius.zero,
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              width: MediaQuery.of(context).size.width * 0.98,
              height: MediaQuery.of(context).size.height * 0.15,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Rates')
                    .doc('gali')
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
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'Gali Desawar',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: ListTile(
                          tileColor: Colors.blue[300],
                          leading: const Text(
                            'Jodi',
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: Text(
                            '10-${document!['jodi']}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('GamesData')
                    .where('active', isEqualTo: true)
                    .where('type', isEqualTo: 'gali')
                    .orderBy('start')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  var length = snapshot.data!.docs.length;
                  DateTime now = DateTime.now();
                  String formattedDateFinal =
                      DateFormat('dd-MM-yyyy').format(now);
                  return ListView.builder(
                      cacheExtent: 10000.0,
                      itemCount: length,
                      itemBuilder: (context, index) {
                        return StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('GamesData')
                                .doc(snapshot.data!.docs[index].id.toString())
                                .collection('Games')
                                .doc(formattedDateFinal)
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<DocumentSnapshot> snapshot2) {
                              if (snapshot2.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox();
                              }
                              //var documents = snapshot2.data!.docs[index].id;
                              String formattedopen = DateFormat('hh:mm a')
                                  .format(DateTime.parse(
                                      '2021-12-27 ${snapshot.data!.docs[index]['start']}:00'));
                              int formatteddate = snapshot.data!.docs.length;
                              // String formattedclose = DateFormat('hh:mm a')
                              //     .format(DateTime.parse(
                              //         '2012-02-27 ${snapshot.data!.docs[index]['end']}:00'));
                              return StatefulBuilder(
                                  builder: (context, setState) {
                                return GestureDetector(
                                  onTap: () {
                                    (DateTime.now().hour.toDouble() +
                                                    DateTime.now().minute.toDouble() /
                                                        60 >=
                                                DateTime.parse('2021-12-27 00:00:00')
                                                        .hour
                                                        .toDouble() +
                                                    DateTime.parse('2021-12-27 00:00:00')
                                                            .minute
                                                            .toDouble() /
                                                        60) &&
                                            (DateTime.now().hour.toDouble() +
                                                    DateTime.now()
                                                            .minute
                                                            .toDouble() /
                                                        60 <
                                                DateTime.parse('2021-12-27 ${snapshot.data!.docs[index]['start']}:00')
                                                        .hour
                                                        .toDouble() +
                                                    DateTime.parse('2021-12-27 ${snapshot.data!.docs[index]['start']}:00')
                                                            .minute
                                                            .toDouble() /
                                                        60)
                                        ?
                                        //HapticFeedback.vibrate();
                                        Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) {
                                            return SelectGameGali(
                                                snapshot
                                                    .data!.docs[index]['name']
                                                    .toUpperCase(),
                                                snapshot.data!.docs[index]['id']
                                                    .toString()
                                                    .trim());
                                          }))
                                        : setState(() {
                                            deltaX = 20;
                                          });
                                    HapticFeedback.mediumImpact();
                                  },
                                  child: TweenAnimationBuilder<double>(
                                    key: UniqueKey(),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: duration,
                                    builder: (context, animation, child) =>
                                        Transform.translate(
                                      offset:
                                          Offset(deltaX * shake(animation), 0),
                                      child: Card(
                                        // child: ,
                                        color: Colors.blue,

                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        // child: ,
                                        child: SizedBox(
                                          height: 120,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        18.0, 0, 0, 0),
                                                    child: Text(
                                                      snapshot.data!
                                                          .docs[index]['name']
                                                          .toUpperCase(),
                                                      style: GoogleFonts.getFont(
                                                          'Roboto Slab',
                                                          textStyle:
                                                              const TextStyle(
                                                            fontSize: 23,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          )),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        0.0, 0, 18, 0),
                                                    child: IconButton(
                                                      icon: Image.asset(
                                                          'assets/results.png'),
                                                      onPressed: () => Navigator
                                                              .of(context)
                                                          .push(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) {
                                                        return ChartsGali(
                                                            snapshot.data!
                                                                    .docs[index]
                                                                ['id']);
                                                      })),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  (DateTime.now().hour.toDouble() +
                                                                  DateTime.now()
                                                                          .minute
                                                                          .toDouble() /
                                                                      60 >=
                                                              DateTime.parse(
                                                                          '2021-12-27 00:00:00')
                                                                      .hour
                                                                      .toDouble() +
                                                                  DateTime.parse(
                                                                              '2021-12-27 00:00:00')
                                                                          .minute
                                                                          .toDouble() /
                                                                      60) &&
                                                          (DateTime.now()
                                                                      .hour
                                                                      .toDouble() +
                                                                  DateTime.now()
                                                                          .minute
                                                                          .toDouble() /
                                                                      60 <
                                                              DateTime.parse(
                                                                          '2021-12-27 08:00:00')
                                                                      .hour
                                                                      .toDouble() +
                                                                  DateTime.parse(
                                                                              '2021-12-27 08:00:00')
                                                                          .minute
                                                                          .toDouble() /
                                                                      60)
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  18.0,
                                                                  0,
                                                                  0,
                                                                  0),
                                                          child: snapshot2
                                                                      .data![
                                                                          'Numbers']
                                                                      .toUpperCase() ==
                                                                  ''
                                                              ? Text('* *',
                                                                  style: GoogleFonts.getFont(
                                                                      'Pacifico',
                                                                      textStyle: const TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          letterSpacing:
                                                                              2.0,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color: Color.fromRGBO(
                                                                              255,
                                                                              178,
                                                                              102,
                                                                              1))))
                                                              : Text(
                                                                  snapshot2
                                                                      .data![
                                                                          'Numbers']
                                                                      .toUpperCase(),
                                                                  style: GoogleFonts.getFont(
                                                                      'Pacifico',
                                                                      textStyle: const TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          letterSpacing:
                                                                              2.0,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color: Color.fromRGBO(
                                                                              255,
                                                                              178,
                                                                              102,
                                                                              1))),
                                                                ),
                                                        )
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  18.0,
                                                                  0,
                                                                  0,
                                                                  0),
                                                          child: snapshot2
                                                                      .data![
                                                                          'Numbers']
                                                                      .toUpperCase() ==
                                                                  ''
                                                              ? Text('* *',
                                                                  style: GoogleFonts.getFont(
                                                                      'Pacifico',
                                                                      textStyle: const TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          letterSpacing:
                                                                              2.0,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color: Color.fromRGBO(
                                                                              255,
                                                                              178,
                                                                              102,
                                                                              1))))
                                                              : Text(
                                                                  snapshot2
                                                                      .data![
                                                                          'Numbers']
                                                                      .toUpperCase(),
                                                                  style: GoogleFonts.getFont(
                                                                      'Pacifico',
                                                                      textStyle: const TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          letterSpacing:
                                                                              2.0,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color: Color.fromRGBO(
                                                                              255,
                                                                              178,
                                                                              102,
                                                                              1))),
                                                                ),
                                                        ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        0.0, 0, 18, 0),
                                                    child: (DateTime.now()
                                                                        .hour
                                                                        .toDouble() +
                                                                    DateTime.now()
                                                                            .minute
                                                                            .toDouble() /
                                                                        60 >=
                                                                DateTime.parse('2021-12-27 00:00:00')
                                                                        .hour
                                                                        .toDouble() +
                                                                    DateTime.parse('2021-12-27 00:00:00')
                                                                            .minute
                                                                            .toDouble() /
                                                                        60) &&
                                                            (DateTime.now()
                                                                        .hour
                                                                        .toDouble() +
                                                                    DateTime.now()
                                                                            .minute
                                                                            .toDouble() /
                                                                        60 <
                                                                DateTime.parse(
                                                                            '2021-12-27 ${snapshot.data!.docs[index]['start']}:00')
                                                                        .hour
                                                                        .toDouble() +
                                                                    DateTime.parse('2021-12-27 ${snapshot.data!.docs[index]['start']}:00')
                                                                            .minute
                                                                            .toDouble() /
                                                                        60)
                                                        ? Image.asset(
                                                            'assets/play.png',
                                                            width: 28,
                                                            height: 28,
                                                          )
                                                        : Image.asset(
                                                            'assets/close.png',
                                                            width: 20,
                                                            height: 20,
                                                          ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        18.0, 0, 0, 0),
                                                    child: Text(
                                                      'Open- $formattedopen',
                                                      //style: TextStyle(),
                                                    ),
                                                  ),
                                                  // Padding(
                                                  //   padding:
                                                  //       const EdgeInsets.fromLTRB(
                                                  //           0.0, 0, 18, 0),
                                                  //   child: Text(
                                                  //     'Close- $formattedclose',
                                                  //     //style: TextStyle(),
                                                  //   ),
                                                  // ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              });
                            });
                      });
                }),
          ),
        ],
      ),
    );
  }
}
