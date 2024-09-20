import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '/auth/sign_in_details.dart';
import 'otp_page.dart';
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:firebase_remote_config/firebase_remote_config.dart'
    show FirebaseRemoteConfig, RemoteConfigSettings;
import 'package:url_launcher/url_launcher.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'auth_form_login.dart';

class Loginscreen extends StatefulWidget {
  static const routeName = '/login_screen';

  const Loginscreen({Key? key}) : super(key: key);
  @override
  _LoginscreenState createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _auth = FirebaseAuth.instance;
  GlobalKey<ScaffoldState> scafoldkey = GlobalKey<ScaffoldState>();
  var _isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _formKey = GlobalKey<FormState>();
  // ignore: constant_identifier_names
  static const PLAY_STORE_URL =
      'https://play.google.com/store/apps/details?id=com.matkagroup.mumbaibazarmain';
  versionCheck(context) async {
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    double currentVersion =
        double.parse(info.version.trim().replaceAll(".", ""));

    //Get Latest version info from firebase config
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 2),
        minimumFetchInterval: Duration.zero,
      ));
      await remoteConfig.fetchAndActivate();
      remoteConfig.getString('force_update_current_version');
      double newVersion = double.parse(remoteConfig
          .getString('force_update_current_version')
          .trim()
          .replaceAll(".", ""));
      if (newVersion > currentVersion) {
        _showVersionDialog(context);
      }
      bool maintain = remoteConfig.getBool('under_maintain');
      // print(maintain);
      if (maintain) {
        _showMaintainDialog(context);
      }
    } on PlatformException catch (exception) {
      // Fetch throttled.
      print(exception);
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
  }

  _showMaintainDialog(context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "Under Maintainence";
        String message =
            "The servers are under maintainence, we will resume our services soon. We deeply regret for the inconvenience caused";
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
          ),
        );
      },
    ).whenComplete(() => exit(0));
  }

  _showVersionDialog(context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "New Update Available";
        String message =
            "There is a newer version of app available please update it now.";
        String btnLabel = "Update Now";
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: Text(btnLabel),
                onPressed: () => _launchURL(PLAY_STORE_URL),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() => exit(0));
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _signInWithGoogle(
    BuildContext ctx,
  ) async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        if (userCredential.additionalUserInfo!.isNewUser) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => GoogleDetails(googleUser)));
        }
      } catch (err) {
        var message = 'An error occurred, please check your credentials!';
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signInWithFacebook(BuildContext ctx) {}
  // void _signInWithFacebook(
  //   BuildContext ctx,
  // ) async {
  //   // Trigger the authentication flow
  //   final result1 = await FacebookAuth.instance.login();
  //   if (result1 != null) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     try {
  //       AuthCredential authCredential =
  //           FacebookAuthProvider.getCredential(accessToken: result1.token);
  //       await _auth.signInWithCredential(authCredential);
  //       Navigator.of(context).pop();
  //     } on PlatformException catch (err) {
  //       var message = 'An error occurred, pelase check your credentials!';

  //       if (err.message != null) {
  //         message = err.message;
  //       }

  //       Scaffold.of(ctx).showSnackBar(
  //         SnackBar(
  //           content: Text(message),
  //           backgroundColor: Theme.of(ctx).errorColor,
  //         ),
  //       );
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     } catch (err) {
  //       print(err);
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  void _submitAuthForm(
    String email,
    String password,
    String username,
    BuildContext ctx,
  ) async {
    //UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      if (!email.contains('@')) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return OTPScreen(email, username, email, true);
        })).then((value) {
          setState(() {
            _isLoading = false;
          });
        });
      } else {
        //await _auth.signInWithCredential(PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode))
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
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

  void _forgotPassword(BuildContext ctx) {
    String? emailFor = '';
    bool inProgress = false;
    Future<void> resetPassword(String email) async {
      try {
        await _auth.sendPasswordResetEmail(email: email);
      } on FirebaseException catch (e) {
        String message = "${e.message}";
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
        );
      }
    }

    showDialog(
        context: ctx,
        builder: (context) {
          return AlertDialog(
            title: const Text('Enter Email ID'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: _formKey,
                  child: TextFormField(
                    enabled: !inProgress,
                    key: const ValueKey('Forgotemail'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      emailFor = value;
                      emailFor!.trim();
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                        onPressed: () {
                          final isValid = _formKey.currentState!.validate();
                          FocusScope.of(context).unfocus();
                          if (isValid) {
                            resetPassword(emailFor!);
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Submit'))
                  ],
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    versionCheck(context);
    return Scaffold(
      key: scafoldkey,
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthFormLogin(
        _submitAuthForm,
        _isLoading,
        _signInWithGoogle,
        _signInWithFacebook,
        _forgotPassword,
      ),
    );
  }
}
