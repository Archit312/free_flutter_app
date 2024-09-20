import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/satta_addpage.dart';

class SelectGame extends StatefulWidget {
  final String gamename;
  final String gameId;
  final bool checker;
  const SelectGame(this.gamename, this.gameId, this.checker, {Key? key})
      : super(key: key);

  @override
  State<SelectGame> createState() => _SelectGameState();
}

class _SelectGameState extends State<SelectGame> {
  init2(String formattedDate) async {
    await FirebaseFirestore.instance
        .collection('GamesData')
        .doc(widget.gameId)
        .collection('Games')
        .doc(formattedDate)
        .set({
      'Numbers': '',
      'resultdeclared': false,
      'opendeclared': false,
      'closedeclared': false,
      'opendeclared2': false,
      'Bids': [],
      'winnerList': [],
    });
  }

  init() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    var temp = false;
    await FirebaseFirestore.instance
        .collection('GamesData')
        .doc(widget.gameId)
        .collection('Games')
        .doc(formattedDate)
        .get()
        .then((value) {
      if (!value.exists) {
        init2(formattedDate);
      }
    });
    await FirebaseFirestore.instance
        .collection('GamesData')
        .doc(widget.gameId)
        .get()
        .then((value) {
      if (DateTime.now().hour.toDouble() +
              DateTime.now().minute.toDouble() / 60 +
              DateTime.now().second.toDouble() / 3600 >
          DateTime.parse(
                      '2021-12-27 ${value.data()!['start']}:00')
                  .hour
                  .toDouble() +
              DateTime.parse('2021-12-27 ${value.data()!['start']}:00')
                      .minute
                      .toDouble() /
                  60 +
              DateTime.parse('2021-12-27 ${value.data()!['start']}:00')
                      .second
                      .toDouble() /
                  3600) {
        temp = true;
      }
    }).then((value) async {
      await FirebaseFirestore.instance
          .collection('GamesData')
          .doc(widget.gameId)
          .collection('Games')
          .doc(formattedDate)
          .update({'opendeclared2': temp});
    });
  }

  @override
  Widget build(BuildContext context) {
    init();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gamename),
      ),
      body: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(0),
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        crossAxisCount: 2,
        children: <Widget>[
          GestureDetector(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) {
              return AddSatta('Single Digit', widget.gameId, widget.gamename,
                  widget.checker);
            })),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/singledigit.png',
                      width: 120,
                      height: 120,
                    ),
                    // Icon(
                    //   Icons.send,
                    //   size: 120,
                    // ),
                    const Text('Single Digit')
                  ],
                ),
              ),
              // color: Colors.teal[100],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) {
              return AddSatta(
                  'Jodi', widget.gameId, widget.gamename, widget.checker);
            })),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/jodidigit.png',
                      width: 120,
                      height: 120,
                    ),
                    const Text('Jodi')
                  ],
                ),
              ),
              //color: Colors.teal[200],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) {
              return AddSatta('Single Panna', widget.gameId, widget.gamename,
                  widget.checker);
            })),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/singlepana.png',
                      width: 120,
                      height: 120,
                    ),
                    const Text('Single Panna')
                  ],
                ),
              ),
              // color: Colors.teal[300],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) {
              return AddSatta('Double Panna', widget.gameId, widget.gamename,
                  widget.checker);
            })),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/doublepana.png',
                      width: 120,
                      height: 120,
                    ),
                    const Text('Double Panna')
                  ],
                ),
              ),
              // color: Colors.teal[400],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) {
              return AddSatta('Triple Panna', widget.gameId, widget.gamename,
                  widget.checker);
            })),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/triplepana.png',
                      width: 120,
                      height: 120,
                    ),
                    const Text('Triple Panna')
                  ],
                ),
              ),
              // color: Colors.teal[400],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) {
              return AddSatta('Half Sangam', widget.gameId, widget.gamename,
                  widget.checker);
            })),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/halfsangam.png',
                      width: 120,
                      height: 120,
                    ),
                    const Text('Half Sangam')
                  ],
                ),
              ),
              // color: Colors.teal[400],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) {
              return AddSatta('Full Sangam', widget.gameId, widget.gamename,
                  widget.checker);
            })),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/fullsangam.png',
                      width: 120,
                      height: 120,
                    ),
                    const Text('Full Sangam')
                  ],
                ),
              ),
              //color: Colors.teal[400],
            ),
          ),
        ],
      ),
    );
  }
}
