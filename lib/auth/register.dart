//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '/auth/otp_page.dart';
import 'package:cloud_functions/cloud_functions.dart';
//import 'package:matka/auth/otp_page.dart';
import './auth_form_register.dart';

class Register extends StatefulWidget {
  static const routeName = '/register_screen';

  const Register({Key? key}) : super(key: key);
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(
    String email,
    String password,
    String username,
    String phoneNo,
    BuildContext ctx,
  ) async {
    //UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'checkIfPhoneExists',
      );
      dynamic resp = await callable.call({'phone': '+91$phoneNo'});
      if (resp.data) {
        // user exists
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: const Text(
              'Phone number already taken.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      } else {
        try {
          await _auth
              .createUserWithEmailAndPassword(
            email: email,
            password: password,
          )
              .then((value) async {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return OTPScreen(email, username, phoneNo, false);
            }));
            // final user = FirebaseAuth.instance.currentUser;
            // if (user != null) {
            //   FirebaseFirestore.instance.collection('UsersData').doc(user.uid).set({
            //     'Name': username,
            //     'Email': email,
            //     'active': false,
            //     'phone': phoneNo,
            //     'Balance': 0.0,
            //     'Transactions': [],
            //     'admin': false,
            //   });
            // }
            // //await user!.linkWithPhoneNumber('+91$phoneNo');
            // Navigator.of(context).pop();
            // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            //   return Otp('+91$phoneNo');
            // })).then((value) {
            //   if (value == 'Done') {

            //   } else {
            //     _auth.currentUser!.delete();
            //   }
            // });
            // final user = FirebaseAuth.instance.currentUser;
            // await FirebaseAuth.instance.verifyPhoneNumber(
            //     phoneNumber: '+91$phoneNo',
            //     verificationCompleted: (PhoneAuthCredential authCredential) async {
            //       print("verification completed ${authCredential.smsCode}");
            //       //User? user = FirebaseAuth.instance.currentUser;
            //       print(phoneNo);
            //       if (authCredential.smsCode != null) {
            //         try {
            //           UserCredential credential =
            //               await user!.linkWithCredential(authCredential);
            //           FirebaseFirestore.instance
            //               .collection('UsersData')
            //               .doc(user.uid)
            //               .set({
            //             'Name': username,
            //             'Email': email,
            //             'active': false,
            //             'phone': phoneNo,
            //             'Balance': 0.0,
            //             'Transactions': [],
            //           });
            //           Navigator.of(context).pop();
            //         } on FirebaseAuthException catch (e) {
            //           if (e.code == 'provider-already-linked') {
            //             await _auth.signInWithCredential(authCredential);
            //           }
            //         }
            //         setState(() {
            //           _isLoading = false;
            //         });
            //       }
            //     },
            //     verificationFailed: (FirebaseAuthException e) {
            //       print('ayaa');
            //       _auth.signOut();
            //       user!.delete();
            //       var message = '${e.message}';
            //       ScaffoldMessenger.of(ctx).showSnackBar(
            //         SnackBar(
            //           content: Text(
            //             message,
            //             style: const TextStyle(color: Colors.white),
            //           ),
            //           backgroundColor: Theme.of(ctx).errorColor,
            //         ),
            //       );
            //       setState(() {
            //         _isLoading = false;
            //       });
            //     },
            //     codeSent: (String verificationId, int? resendToken) {
            //       print('ayaaaaaaaaaa');
            //       String _otp = '';
            //       Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            //         return  Otp();
            //       })).then((value) async {
            //         if (value == '') {
            //           _auth.signOut();
            //           user!.delete();
            //           showDialog(
            //               context: context,
            //               builder: (context) {
            //                 return const AlertDialog(
            //                   title: Text('Otp Not Entered'),
            //                 );
            //               });
            //         } else {
            //           _otp = value;
            //         }
            //         PhoneAuthCredential credential = PhoneAuthProvider.credential(
            //             verificationId: verificationId, smsCode: _otp);

            //         // Sign the user in (or link) with the credential
            //         user!.linkWithCredential(credential);
            //       });
            //     },
            //     codeAutoRetrievalTimeout: (String verificationId) {});
          });
        } on FirebaseAuthException catch (err) {
          var message = '${err.message}';
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
      // final user = FirebaseAuth.instance.currentUser;
      // if (user != null) {
      //   FirebaseFirestore.instance.collection('UsersData').doc(user.uid).set({
      //     'Name': username,
      //     'Email': email,
      //     'active': false,
      //     'phone': phoneNo,
      //     'Balance': 0.0,
      //     'Transactions': [],
      //   });
      // }
      // Navigator.of(context).pop();
    } on PlatformException catch (err) {
      var message = '${err.message}';
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(ctx).colorScheme.error,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.blue,
      body: AuthForm(
        _submitAuthForm,
        _isLoading,
      ),
    );
  }
}
