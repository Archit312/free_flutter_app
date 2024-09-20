import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class UpiPayment extends StatefulWidget {
  const UpiPayment({Key? key}) : super(key: key);

  @override
  _UpiPaymentState createState() => _UpiPaymentState();
}

class _UpiPaymentState extends State<UpiPayment> {
  //static const platform = MethodChannel("razorpay_flutter");
  final TextEditingController _textEditingController = TextEditingController();
  var userID = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Points'),
      ),
      body: Center(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
            const Text('Enter Amount To Be Added'),
            SizedBox(
              width: 50,
              child: TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.number,
              ),
            ),
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('Settings')
                    .doc('data')
                    .get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ElevatedButton(
                      onPressed: () async {
                        if (_textEditingController.text.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Amount can't be empty",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              // backgroundColor: Colors.red,
                              // textColor: Colors.white,
                              fontSize: 16.0);
                        } else if (int.parse(_textEditingController.text) <
                            500) {
                          Fluttertoast.showToast(
                              msg: "Minimum amount to add is 500",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              // backgroundColor: Colors.red,
                              // textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          await launch(
                              "https://wa.me/+91${snapshot.data!['whatsApp']}?text=I want to add ${_textEditingController.text} points to my account.");
                        }
                      },
                      child: const Text('Add'));
                })
          ])),
    );
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _razorpay = Razorpay();
  //   _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
  //   _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  //   _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  // }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
    //_razorpay.clear();
  }

  // Future<String> _getOrderid(String txnid, String amount) async {
  //   try {
  //     //print('ayaaa');
  //     // ignore: unnecessary_new
  //     Dio dio = new Dio();
  //     dio.options.headers['Authorization'] =
  //         "Basic cnpwX3Rlc3RfQzZBR0hwRUk3dmNzZXo6SlNXcDhXOWdITXdrZmx6Qm1teWFUM3JV";
  //     var response =
  //         await dio.post('https://api.razorpay.com/v1/orders', data: {
  //       'amount': amount,
  //       'receipt': txnid,
  //       'currency': 'INR',
  //     });
  //     return response.data['id'];
  //     //print(response);
  //   } catch (e) {
  //     //print(e);
  //   }
  //   return '';
  // }

  // void _openCheckout(String id) async {
  //   var options = {
  //     'key': 'rzp_test_C6AGHpEI7vcsez',
  //     'order_id': id,
  //     'name': 'Add Points To Wallet',
  //     'description': '',
  //     'external': {
  //       'wallets': ['paytm']
  //     }
  //   };

  //   try {
  //     _razorpay.open(options);
  //   } catch (e) {
  //     debugPrint('Error: e');
  //   }
  // }

  // void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  //   var balance = 0;
  //   await FirebaseFirestore.instance
  //       .collection('UsersData')
  //       .doc(userID)
  //       .get()
  //       .then((value) {
  //     balance = value.data()!['Balance'];
  //   });
  //   var temp = balance + int.parse(_textEditingController.text.trim());
  //   var obj = [
  //     {
  //       'amount': _textEditingController.text.trim(),
  //       'type': 'addamount',
  //       'game': '',
  //       'timestamp': DateTime.now(),
  //     }
  //   ];
  //   await FirebaseFirestore.instance
  //       .collection('UsersData')
  //       .doc(userID)
  //       .update({
  //     'Transaction': FieldValue.arrayUnion(obj),
  //     'Balance': temp,
  //   });
  //   Fluttertoast.showToast(
  //       msg: "SUCCESS: " + response.paymentId!,
  //       toastLength: Toast.LENGTH_SHORT);
  //   _textEditingController.clear();
  // }

  // void _handlePaymentError(PaymentFailureResponse response) {
  //   Fluttertoast.showToast(
  //       msg: "ERROR: " + response.code.toString() + " - " + response.message!,
  //       toastLength: Toast.LENGTH_SHORT);
  // }

  // void _handleExternalWallet(ExternalWalletResponse response) {
  //   Fluttertoast.showToast(
  //       msg: "EXTERNAL_WALLET: " + response.walletName!,
  //       toastLength: Toast.LENGTH_SHORT);
  // }
}
