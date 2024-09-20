import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfile extends StatefulWidget {
  static const routeName = '/edit_profile';

  const EditProfile({Key? key}) : super(key: key);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool _isUploading = false;
  String? url;
  final firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _textEditingController2 = TextEditingController();
  final TextEditingController _textEditingController3 = TextEditingController();
  final TextEditingController _textEditingController4 = TextEditingController();
  @override
  void dispose() {
    _textEditingController.dispose();
    _textEditingController2.dispose();
    _textEditingController3.dispose();
    super.dispose();
  }

  var user = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _updateDis() async {
    String password = _textEditingController3.text;
    String email = _textEditingController2.text;
    String name = _textEditingController.text;
    String phone = _textEditingController4.text;
    String? previousMail;
    await FirebaseFirestore.instance
        .collection('UsersData')
        .doc(user)
        .get()
        .then((value) {
      previousMail = value.data()!['Email'];
    });
    if (previousMail != email && password == '') {
      Fluttertoast.showToast(
          msg: "Please enter the current password to change email!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    }
    if (email != '' && _textEditingController3.text != "") {
      User? user = FirebaseAuth.instance.currentUser;
      UserCredential authResult = await user!.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        ),
      );
      await authResult.user!.updateEmail(email);
      await FirebaseFirestore.instance
          .collection('UsersData')
          .doc(user.uid)
          .update({'Email': email});
    }
    if (name != '') {
      await FirebaseFirestore.instance
          .collection('UsersData')
          .doc(user)
          .update({'Name': name, 'phone': phone});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('UsersData')
                    .doc(user)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  dynamic data = snapshot.data;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircleAvatar(
                              radius: 90,
                              backgroundImage: AssetImage("assets/male.jpg"))),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          enabled: _isUploading ? false : true,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)))),
                          controller: _textEditingController
                            ..text = data['Name'],
                          maxLines: null,
                          minLines: null,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      if (firebaseAuth
                              .currentUser!.providerData[0].providerId !=
                          'google.com')
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            enabled: _isUploading ? false : true,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            controller: _textEditingController2
                              ..text = data['Email'],
                            maxLines: null,
                            minLines: null,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          enabled: _isUploading ? false : true,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)))),
                          controller: _textEditingController4
                            ..text = data['phone'],
                          maxLines: null,
                          minLines: null,
                          keyboardType: TextInputType.number,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      if (firebaseAuth
                              .currentUser!.providerData[0].providerId !=
                          'google.com')
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            enabled: _isUploading ? false : true,
                            decoration: const InputDecoration(
                                hintText: 'Enter Password',
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            controller: _textEditingController3,
                            autocorrect: false,
                            obscureText: true,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ElevatedButton(
                        onPressed: _isUploading
                            ? null
                            : () async {
                                setState(() {
                                  _isUploading = true;
                                });
                                await _updateDis();
                                Fluttertoast.showToast(
                                    msg: "Profile Updated Success.",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    fontSize: 16.0);
                                setState(() {
                                  _isUploading = false;
                                  _textEditingController3.clear();
                                });
                              },
                        child: const Text('Update Profile'),
                      ),
                      ElevatedButton(
                        onPressed: _isUploading
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        child: const Text('Cancel'),
                      ),
                    ],
                  );
                }),
            if (_isUploading)
              const Align(
                alignment: Alignment.center,
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
