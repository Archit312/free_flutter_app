import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './auth/dynamic_link.dart';
import 'auth/referal.dart';

class ReferPage extends StatelessWidget {
  ReferPage({Key? key}) : super(key: key);

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/legal.txt');
  }

  final user = FirebaseAuth.instance.currentUser!.uid;
  final DynamicLinkService dynamicLinkService = DynamicLinkService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refer and Earn'),
      ),
      body: FutureBuilder(
          future: loadAsset(),
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(children: [
                Text(snapshot.data.toString()),
                Center(
                  child: ElevatedButton(
                    child: const Text('Earn Now'),
                    onPressed: () async {
                      AlertDialog alert = AlertDialog(
                        content: Row(
                          children: [
                            const CircularProgressIndicator(),
                            Container(
                                margin: const EdgeInsets.only(left: 7),
                                child: const Text("Loading...")),
                          ],
                        ),
                      );
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        },
                      );
                      loadAsset().then((value) async {
                        var mycode = '';
                        await FirebaseFirestore.instance
                            .collection('UsersData')
                            .doc(user)
                            .get()
                            .then((value) {
                          mycode = value.data()!['mycode'];
                        });
                        Uri uri =
                            await dynamicLinkService.createDynamicLink(mycode);
                        Navigator.of(context).pop();
                        await Share.share(
                          '$value ${uri.toString()}',
                        );
                      });
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      var refby = '';
                      await FirebaseFirestore.instance
                          .collection('UsersData')
                          .doc(user)
                          .get()
                          .then((value) {
                        refby = value.data()!['referedby'];
                      });
                      if (refby == '') {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const Referal()));
                      } else {
                        Fluttertoast.showToast(
                            msg: "You are already referred",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            // backgroundColor: Colors.red,
                            // textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    },
                    child: const Text('Enter Referal Code'))
              ]),
            );
          }),
    );
  }
}
