import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancing2/auth/dynamic_link.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Referal extends StatefulWidget {
  const Referal({Key? key}) : super(key: key);
  @override
  _ReferalState createState() => _ReferalState();
}

class _ReferalState extends State<Referal> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  final TextEditingController _pinPutController = TextEditingController();
  final DynamicLinkService _dynamicLinkService = DynamicLinkService();
  final FocusNode _pinPutFocusNode = FocusNode();
  var referal = '';
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: const Color.fromRGBO(43, 46, 66, 1),
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: const Color.fromRGBO(126, 203, 224, 1),
    ),
  );
  init() async {
    referal = await _dynamicLinkService.retrieveDynamicLink(context);
    _pinPutController.text = referal;
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Refer and Earn'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 40),
              child: const Center(
                child: Text(
                  'Please enter the referal code.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: PinCodeTextField(
                controller: _pinPutController,
                appContext: context,
                length: 8,
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.underline,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                ),
                animationDuration: const Duration(milliseconds: 300),
                onCompleted: (v) async {
                  {
                    try {
                      var uid = FirebaseAuth.instance.currentUser!.uid;
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
                      FocusScope.of(context).unfocus();
                      var reredby = '';
                      await FirebaseFirestore.instance
                          .collection('UsersData')
                          .where('mycode', isEqualTo: v)
                          .get()
                          .then((value) async {
                        if (value.docs.isNotEmpty) {
                          reredby = value.docs[0].data()['Name'];
                          await FirebaseFirestore.instance
                              .collection('UsersData')
                              .doc(uid.toString().trim())
                              .update({
                            'referedby': v,
                          }).then((value) {
                            Navigator.of(context).pop();
                            AwesomeDialog(
                              context: context,
                              animType: AnimType.scale,
                              dialogType: DialogType.success,
                              title: 'Successfully Refered!!',
                              desc: '$reredby refered you',
                              btnOkOnPress: () {
                                Navigator.of(context).pop();
                              },
                            ).show();
                          });
                        } else {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text(
                              'Invalid Referal code',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ));
                        }
                      });
                    } catch (e) {
                      FocusScope.of(context).unfocus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Could Not Apply referal code',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                },
                onChanged: (value) {
                  //print(value);
                  setState(() {});
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pinPutFocusNode.unfocus();
    _pinPutController.dispose();
  }
}
