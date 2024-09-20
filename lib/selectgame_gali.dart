import 'package:flutter/material.dart';
import 'gali_satta_add.dart';

class SelectGameGali extends StatelessWidget {
  final String gamename;
  final String gameId;

  const SelectGameGali(this.gamename, this.gameId, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gamename),
      ),
      body: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(0),
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        crossAxisCount: 2,
        children: <Widget>[
          // GestureDetector(
          //   onTap: () => Navigator.of(context)
          //       .push(MaterialPageRoute(builder: (context) {
          //     return GaliAddSatta('Left Digit', gameId, gamename);
          //   })),
          //   child: Container(
          //     padding: const EdgeInsets.all(8),
          //     child: Center(
          //       child: Column(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Image.asset(
          //             'assets/leftdigit.png',
          //             width: 120,
          //             height: 120,
          //           ),
          //           const Text('Left Digit')
          //         ],
          //       ),
          //     ),
          //     // color: Colors.teal[100],
          //   ),
          // ),
          // GestureDetector(
          //   onTap: () => Navigator.of(context)
          //       .push(MaterialPageRoute(builder: (context) {
          //     return GaliAddSatta('Right Digit', gameId, gamename);
          //   })),
          //   child: Container(
          //     padding: const EdgeInsets.all(8),
          //     child: Center(
          //       child: Column(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Image.asset(
          //             'assets/rightdigit.png',
          //             width: 120,
          //             height: 120,
          //           ),
          //           const Text('Right Digit')
          //         ],
          //       ),
          //     ),
          //     // color: Colors.teal[100],
          //   ),
          // ),
          GestureDetector(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) {
              return GaliAddSatta('Jodi Digit', gameId, gamename);
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
                    const Text('Jodi Digit')
                  ],
                ),
              ),
              //color: Colors.teal[200],
            ),
          ),
        ],
      ),
    );
  }
}
