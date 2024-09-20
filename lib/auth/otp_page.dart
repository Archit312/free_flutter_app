import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freelancing2/auth/referal.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final String username;
  final String email;
  final bool isLogin;
  const OTPScreen(this.email, this.username, this.phone, this.isLogin,
      {Key? key})
      : super(key: key);
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  late String _verificationCode;
  var uuid = const Uuid();
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: const Color.fromRGBO(43, 46, 66, 1),
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: const Color.fromRGBO(126, 203, 224, 1),
    ),
  );
  @override
  Widget build(BuildContext context) {
    var v1 = uuid.v1();
    var result = v1.substring(1, 8);
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (!widget.isLogin) {
              FirebaseAuth.instance.currentUser!.delete();
              Navigator.of(context).pop();
            }
            Navigator.of(context).pop();
          },
        ),
        title: const Text('OTP Verification'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'Verify +91-${widget.phone}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 26),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: true,
                obscuringCharacter: '*',
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                ),
                animationDuration: const Duration(milliseconds: 300),
                onCompleted: (v) async {
                  {
                    if (widget.isLogin) {
                      final AuthCredential credential =
                          PhoneAuthProvider.credential(
                        verificationId: _verificationCode,
                        smsCode: v,
                      );
                      try {
                        await FirebaseAuth.instance
                            .signInWithCredential(credential);
                      } catch (e) {
                        FocusScope.of(context).unfocus();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Invalid OTP',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                        // _scaffoldkey.currentState!.showSnackBar(
                        //     const SnackBar(content: Text('invalid OTP')));
                      }
                      await FirebaseFirestore.instance
                          .collection('UsersData')
                          .doc(
                              FirebaseAuth.instance.currentUser!.uid.toString())
                          .get()
                          .then((value) async {
                        if (!value.exists) {
                          FocusScope.of(context).unfocus();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'User Not Registered',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Theme.of(context).colorScheme.error,
                            ),
                          );
                          await FirebaseAuth.instance.currentUser!.delete();
                        }
                      });
                      Navigator.of(context).pop();
                    } else {
                      try {
                        await FirebaseAuth.instance.currentUser!
                            .linkWithCredential(PhoneAuthProvider.credential(
                                verificationId: _verificationCode, smsCode: v))
                            .then((value) async {
                          if (value.user != null) {
                            await FirebaseFirestore.instance
                                .collection('UsersData')
                                .doc(FirebaseAuth.instance.currentUser!.uid
                                    .toString())
                                .set({
                              'Name': widget.username,
                              'Email': widget.email,
                              'active': false,
                              'phone': widget.phone,
                              'Balance': 0.0,
                              'Transaction': [],
                              'alerts': [],
                              'admin': false,
                              'referedby': '',
                              'mycode': result,
                            }).then((value) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            });

                            //setPassword(value.user!.uid);
                          } else {
                            FocusScope.of(context).unfocus();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Could Not Register try again later',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                            await FirebaseAuth.instance.currentUser!.delete();
                          }
                        });
                      } catch (e) {
                        FocusScope.of(context).unfocus();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Invalid OTP',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                        // _scaffoldkey.currentState!.showSnackBar(
                        //     const SnackBar(content: Text('invalid OTP')));
                      }
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

  _verifyPhone() async {
    var v1 = uuid.v1();
    var result = v1.substring(1, 8);
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${widget.phone}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (widget.isLogin) {
            try {
              FirebaseAuth.instance.signInWithCredential(credential);
              Navigator.of(context).pop();
            } catch (e) {
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Invalid OTP',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          } else {
            await FirebaseAuth.instance.currentUser!
                .linkWithCredential(credential)
                .then((value) async {
              if (value.user != null) {
                await FirebaseFirestore.instance
                    .collection('UsersData')
                    .doc(FirebaseAuth.instance.currentUser!.uid.toString())
                    .set({
                  'Name': widget.username,
                  'Email': widget.email,
                  'active': false,
                  'phone': widget.phone,
                  'Balance': 0.0,
                  'Transaction': [],
                  'alerts': [],
                  'referedby': '',
                  'mycode': result,
                  'admin': false,
                }).then((value) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Referal()));
                });

                // setPassword(value.user!.uid);
              }
            });

            // FirebaseAuth.instance
            //     .signInWithCredential(credential)
            //     .then((value) async {
            //   if (value.user != null) {
            //    // setPassword(value.user!.uid);
            //   }
            // });
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          FirebaseAuth.instance.currentUser!.delete();
          // print(e.message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.message.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
        codeSent: (String verficationID, int? resendToken) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'OTP Send',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          setState(() {
            _verificationCode = verficationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            _verificationCode = verificationID;
          });
        },
        timeout: const Duration(seconds: 120));
  }

  // setPassword(uid) {
  //   Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) => PasswordScreen(widget.phone, uid)),
  //       (route) => false);

  //   /*Map userDetails={
  //     "mobile":widget.phone,
  //     "password":"1234",
  //   };

  //   dbRef.child(uid).set(userDetails).then((value) {
  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => Home(uid)),
  //             (route) => false);
  //   }).onError((error, stackTrace) {
  //     _scaffoldkey.currentState!
  //         .showSnackBar(SnackBar(content: Text('${error.toString()}')));
  //   });*/
  // }

  @override
  void initState() {
    _verifyPhone();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pinPutFocusNode.unfocus();
    _pinPutController.dispose();
  }
}
