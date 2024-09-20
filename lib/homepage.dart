import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:freelancing2/alerts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'names.dart';
import 'package:text_scroll/text_scroll.dart';
import '/contact_us.dart';
import 'package:google_fonts/google_fonts.dart';
import '/full_profile.dart';
import '/game_rate.dart';
import '/refer_page.dart';
import '/history.dart';
import '/results.dart';
import '/typesofgame.dart';
import 'package:url_launcher/url_launcher.dart';
import '/wallet.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:firebase_remote_config/firebase_remote_config.dart'
    show FirebaseRemoteConfig, RemoteConfigSettings;

import 'auth/dynamic_link.dart';

enum Availability { loading, available, unavailable }

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // ignore: constant_identifier_names
  static const PLAY_STORE_URL =
      'https://play.google.com/store/apps/details?id=com.dpBoss.mainmumbaibazar';
  var nameString = '';
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

  final Duration duration = const Duration(milliseconds: 500);
  double deltaX = 0;
  final Curve curve = Curves.bounceOut;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  var user = FirebaseAuth.instance.currentUser!.uid;
  bool activeUser = false;
  //double _rating = 0;
  double shake(double animation) =>
      2 * (0.5 - (0.5 - curve.transform(animation)).abs());
  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/legal.txt');
  }

  // ignore: unused_field
  Future<void> _handleBckground(RemoteMessage remoteMessage) async {}
  init() async {
    await FirebaseFirestore.instance
        .collection('UsersData')
        .doc(userID)
        .get()
        .then((value) {
      activeUser = value.data()!['active'];
      setState(() {});
    });
    var token = await FirebaseMessaging.instance.getToken();
    await FirebaseFirestore.instance
        .collection('UsersData')
        .doc(userID)
        .update({'deviceToken': token});
    FirebaseMessaging.onBackgroundMessage(_handleBckground);
    // return showDialog(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Text(message.notification!.title!),
    //         content: Text(message.notification!.body!),
    //         actions: [
    //           TextButton(onPressed: () {}, child: const Text('Cancel')),
    //           TextButton(
    //               onPressed: () {
    //                 launch(message.data.entries.first.value);
    //               },
    //               child: const Text('Visit'))
    //         ],
    //       );
    //     });
    FirebaseMessaging.onMessage.listen((message) {
      if (message.data.isNotEmpty) {
        showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.data.entries.last.key == 'image')
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(message.data.entries.last.value),
                        ),
                      Text(
                        message.notification!.title!,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 4, 8, 8),
                        child: Text(message.notification!.body!),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () async {
                                // await submitFun(List.filled(
                                //     1, message.data.entries.first.value));
                                // // await launchURL(
                                // //   context,
                                // // );
                                Navigator.of(context).pop();
                              },
                              child: const Text('Ok'))
                        ],
                      )
                    ],
                  ));
            }).whenComplete(() {});
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data.isNotEmpty) {
        showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.data.entries.last.key == 'image')
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(message.data.entries.last.value),
                        ),
                      Text(
                        message.notification!.title!,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 4, 8, 8),
                        child: Text(message.notification!.body!),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () async {
                                // await submitFun(List.filled(
                                //     1, message.data.entries.first.value));
                                // // await launchURL(
                                // //   context,
                                // // );
                                Navigator.of(context).pop();
                              },
                              child: const Text('Ok'))
                        ],
                      )
                    ],
                  ));
            }).whenComplete(() {});
      }
    });
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        return showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.data.entries.last.key == 'image')
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(message.data.entries.last.value),
                        ),
                      Text(
                        message.notification!.title!,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 4, 8, 8),
                        child: Text(message.notification!.body!),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () async {
                                // await submitFun(List.filled(
                                //     1, message.data.entries.first.value));
                                // // await launchURL(
                                // //   context,
                                // // );
                                Navigator.of(context).pop();
                              },
                              child: const Text('Visit'))
                        ],
                      )
                    ],
                  ));
            }).whenComplete(() {});
      }
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  // void _requestReview() {
  //   showModalBottomSheet(
  //       context: context,
  //       shape: const RoundedRectangleBorder(
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
  //       ),
  //       clipBehavior: Clip.antiAliasWithSaveLayer,
  //       elevation: 10,
  //       builder: (builder) {
  //         return Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Center(
  //               child: Padding(
  //                 padding: const EdgeInsets.fromLTRB(0.0, 8, 0, 0),
  //                 child: Container(
  //                   height: MediaQuery.of(context).size.height * 0.01,
  //                   width: MediaQuery.of(context).size.width * 0.10,
  //                   decoration: const BoxDecoration(
  //                       color: Colors.grey,
  //                       borderRadius: BorderRadius.all(Radius.circular(20))),
  //                 ),
  //               ),
  //             ),
  //             const Center(
  //               child: Padding(
  //                 padding: EdgeInsets.all(8.0),
  //                 child: Text('Rate the app'),
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.all(12.0),
  //               child: RatingBar.builder(
  //                 initialRating: 3,
  //                 minRating: 1,
  //                 direction: Axis.horizontal,
  //                 allowHalfRating: true,
  //                 itemCount: 5,
  //                 itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
  //                 itemBuilder: (context, _) => const Icon(
  //                   Icons.star,
  //                   color: Colors.amber,
  //                 ),
  //                 onRatingUpdate: (rating) {
  //                   _rating = rating;
  //                 },
  //               ),
  //             ),
  //             Center(
  //               child: TextButton(
  //                 child: const Text('Submit'),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //               ),
  //             )
  //           ],
  //         );
  //       });
  // }

  var userID = FirebaseAuth.instance.currentUser!.uid;
  final DynamicLinkService dynamicLinkService = DynamicLinkService();

  @override
  Widget build(BuildContext context) {
    versionCheck(context);
    return Scaffold(
      drawer: Container(
        margin: MediaQuery.of(context).padding,
        child: Drawer(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DrawerHeader(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                        //radius: 50,
                        child: Image.asset(
                      "assets/male.jpg",
                      width: 80,
                      height: 80,
                    )),
                    FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('UsersData')
                            .doc(userID.toString().trim())
                            .get(),
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(''),
                                    Text(''),
                                  ],
                                ));
                          }
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text('${snapshot.data!['Name']}'),
                                Text('${snapshot.data!['phone']}'),
                              ],
                            ),
                            //Text('${snapshot.data!['phone']}'),
                          );
                        }),
                  ],
                )),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () => Navigator.of(context).pop(),
                ),
                ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Full Profile'),
                    onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const EditProfile();
                        }))),
                if (activeUser)
                  ListTile(
                      leading: const Icon(Icons.wallet_giftcard),
                      title: const Text('Wallet'),
                      onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return const Wallet();
                          }))),
                if (activeUser)
                  ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text('Win History'),
                      onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return const History('Win');
                          }))),
                if (activeUser)
                  ListTile(
                      leading: const Icon(Icons.money),
                      title: const Text('Bid History'),
                      onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return const History('Bid');
                          }))),
                if (activeUser)
                  ListTile(
                    leading: const Icon(Icons.person_add),
                    title: const Text('Refer and earn'),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return ReferPage();
                    })),
                  ),
                if (activeUser)
                  ListTile(
                    leading: const Icon(Icons.money),
                    title: const Text('Game Rates'),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const GameRates();
                    })),
                  ),
                ListTile(
                  leading: const Icon(Icons.contact_phone),
                  title: const Text('Contact Us'),
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return const ContactUs();
                  })),
                ),
                // ListTile(
                //   leading: Icon(Icons.info),
                //   title: Text('How To Play'),
                // ),
                // ListTile(
                //   leading: Icon(Icons.share),
                //   title: Text('Share With Friends'),
                // ),
                ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Rate App'),
                    onTap: () => _launchURL(PLAY_STORE_URL)),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Logout'),
                  onTap: () async {
                    final FirebaseAuth firebase = FirebaseAuth.instance;
                    final GoogleSignIn googleSignIn = GoogleSignIn();
                    User user = firebase.currentUser!;
                    if (user.providerData[0].providerId == 'google.com') {
                      await googleSignIn.signOut();
                    }
                    //await InternetAddress.lookup('google.com');
                    // if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                    await firebase.signOut();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Main Mumbai Bazar'),
        actions: [
          if (activeUser)
            GestureDetector(
                onTap: () {
                  !activeUser
                      ? null
                      : Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const Wallet()));
                },
                child: Row(
                  children: [
                    const Icon(Icons.wallet_travel),
                    const SizedBox(
                      width: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('UsersData')
                              .doc(userID.toString().trim())
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('0');
                            }
                            return SizedBox(
                              width: 30,
                              child: TextScroll(
                                snapshot.data!['Balance'].toString(),
                                velocity: const Velocity(
                                    pixelsPerSecond: Offset(20, 0)),
                                delayBefore: const Duration(seconds: 2),
                                pauseBetween: const Duration(seconds: 3),
                                mode: TextScrollMode.bouncing,
                                selectable: false,
                              ),
                            );
                          }),
                    ),
                  ],
                )),
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Alerts()));
              },
              icon: const Icon(Icons.notifications))
        ],
      ),
      body: Column(
        children: [
          Card(
            elevation: 0,
            clipBehavior: Clip.hardEdge,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.zero,
                    topRight: Radius.zero,
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Stack(children: [
              Container(
                //clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.zero,
                        topRight: Radius.zero,
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                width: MediaQuery.of(context).size.width * 0.98,
                height: MediaQuery.of(context).size.height * 0.3,
                child: Image.asset(
                  'assets/homepage.jpg',
                  fit: BoxFit.fill,
                ),
              ),
              Positioned.fill(
                  child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5,
                  sigmaY: 5,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              )),
              if (activeUser)
                Positioned(
                    child: FutureBuilder(
                  future: Future.microtask(() {
                    for (int i = 0; i < 30; i++) {
                      final random = Random();
                      int randomNumber = 500 + random.nextInt(10000 - 499);
                      double tempRand = randomNumber / 100;
                      randomNumber = tempRand.round();
                      randomNumber = randomNumber * 100;
                      var element = nameList[random.nextInt(nameList.length)];
                      nameString = nameString +
                          "" +
                          element +
                          ' withdrawed ₹' +
                          randomNumber.toString() +
                          "   ";
                    }
                  }),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 0,
                        width: 0,
                      );
                    }
                    return TextScroll(
                      nameString,
                      velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                      delayBefore: const Duration(seconds: 2),
                      pauseBetween: const Duration(seconds: 3),
                      mode: TextScrollMode.bouncing,
                      selectable: false,
                    );
                  },
                )),
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.13,
                left: MediaQuery.of(context).size.width * 0.06,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Welcome To Main Mumbai Bazar',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        if (activeUser)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Best Game Play Online',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/logo.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  //clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.zero,
                          topRight: Radius.zero,
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  width: MediaQuery.of(context).size.width * 0.98,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Container(
                      //   color: Colors.black.withOpacity(0.5),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       // IconButton(
                      //       //     onPressed: () async => launch("tel://8107463368"),
                      //       //     icon: Image.asset('assets/phone.png')),
                      //       // IconButton(
                      //       //     onPressed: () async => await launch(
                      //       //         "https://wa.me/+91${8107463368}?text=I want to add money to my account."),
                      //       //     icon: Image.asset('assets/whatsApp.png')),
                      //       ElevatedButton(
                      //           onPressed: () => !activeUser
                      //               ? null
                      //               : Navigator.of(context).push(
                      //                   MaterialPageRoute(builder: (context) {
                      //                   return const GaliDeswar();
                      //                 })),
                      //           child: const Text('Play Gali Desawar')),
                      //       // const Text(
                      //       //   'Add Points',
                      //       //   style: TextStyle(color: Colors.white),
                      //       // ),
                      //     ],
                      //   ),
                      // ),
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('Settings')
                                .doc('data')
                                .get(),
                            builder: (context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(18.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                              onPressed: () async => launch(
                                                  "tel://${snapshot.data!['whatsApp']}"),
                                              icon: Image.asset(
                                                  'assets/phone.png')),
                                          GestureDetector(
                                            onTap: () async => launch(
                                                "tel://${snapshot.data!['whatsApp']}"),
                                            child: Text(
                                              ' ${snapshot.data!['whatsApp']}',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),

                                      Row(
                                        children: [
                                          IconButton(
                                              onPressed: () async => await launch(
                                                  "https://wa.me/+91${snapshot.data!['whatsApp']}"),
                                              icon: Image.asset(
                                                  'assets/whatsApp.png')),
                                          GestureDetector(
                                            onTap: () async => await launch(
                                                "https://wa.me/+91${snapshot.data!['whatsApp']}"),
                                            child: const Text(
                                              'Chat',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // IconButton(
                                      //     onPressed: () => !activeUser
                                      //         ? null
                                      //         : Navigator.of(context).push(
                                      //             MaterialPageRoute(
                                      //                 builder: (context) {
                                      //             return const UpiPayment();
                                      //           })),
                                      //     icon: Image.asset(
                                      //       'assets/add.png',
                                      //       // height: 30,
                                      //       // width: 30,
                                      //     )),
                                    ],
                                  ),
                                  if (activeUser)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                                onPressed: () => !activeUser
                                                    ? null
                                                    : Navigator.of(context)
                                                        .push(MaterialPageRoute(
                                                            builder: (context) {
                                                        return const Wallet();
                                                      })),
                                                icon: Image.asset(
                                                    'assets/deposit.jpg')),
                                            GestureDetector(
                                              onTap: () => !activeUser
                                                  ? null
                                                  : Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                      return const Wallet();
                                                    })),
                                              child: const Text(
                                                ' Deposit',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ],
                                        ),

                                        Row(
                                          children: [
                                            IconButton(
                                                onPressed: () => !activeUser
                                                    ? null
                                                    : Navigator.of(context)
                                                        .push(MaterialPageRoute(
                                                            builder: (context) {
                                                        return const Wallet();
                                                      })),
                                                icon: Image.asset(
                                                    'assets/rupee.png')),
                                            GestureDetector(
                                              onTap: () => !activeUser
                                                  ? null
                                                  : Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                      return const Wallet();
                                                    })),
                                              child: const Text(
                                                'Withdraw',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // IconButton(
                                        //     onPressed: () => !activeUser
                                        //         ? null
                                        //         : Navigator.of(context).push(
                                        //             MaterialPageRoute(
                                        //                 builder: (context) {
                                        //             return const UpiPayment();
                                        //           })),
                                        //     icon: Image.asset(
                                        //       'assets/add.png',
                                        //       // height: 30,
                                        //       // width: 30,
                                        //     )),
                                      ],
                                    ),
                                ],
                              );
                            }),
                      ),
                    ],
                  ),
                  //height: MediaQuery.of(context).size.height * 0.20,
                ),
              )
            ]),
          ),
          Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('GamesData')
                      .where('active', isEqualTo: true)
                      .where('type', isEqualTo: 'normal')
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
                    DateTime yesterday = DateTime.now();
                    yesterday.subtract(const Duration(days: 1));
                    String formattedYestardayFinal =
                        DateFormat('dd-MM-yyyy').format(yesterday);
                    return ListView.builder(
                        cacheExtent: 100000.0,
                        key: const PageStorageKey('community'),
                        itemCount: length,
                        itemBuilder: (context, index) {
                          return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('GamesData')
                                  .doc(snapshot.data!.docs[index].id.toString())
                                  .collection('Games')
                                  .doc(formattedDateFinal.trim())
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
                                            '2021-12-27 ${snapshot.data!.docs[index]['start']}:00')
                                        .subtract(const Duration(minutes: 10)));
                                // int formatteddate = snapshot2.data!.docs.length;

                                String formattedclose = DateFormat('hh:mm a')
                                    .format(DateTime.parse(
                                            '2012-02-27 ${snapshot.data!.docs[index]['end']}:00')
                                        .subtract(const Duration(minutes: 10)));
                                double openCheck = double.parse(snapshot
                                    .data!.docs[index]['start']
                                    .trim()
                                    .replaceAll(":", ""));
                                double closeCheck = double.parse(snapshot
                                    .data!.docs[index]['end']
                                    .trim()
                                    .replaceAll(":", ""));

                                return StatefulBuilder(
                                    key: UniqueKey(),
                                    builder: (context, setState) {
                                      return GestureDetector(
                                        onTap: () {
                                          (DateTime.now().hour.toDouble() +
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
                                                          DateTime.parse('2021-12-27 ${snapshot.data!.docs[index]['end']}:00').subtract(const Duration(minutes: 10)).hour.toDouble() +
                                                              DateTime.parse('2021-12-27 ${snapshot.data!.docs[index]['end']}:00')
                                                                      .subtract(const Duration(minutes: 10))
                                                                      .minute
                                                                      .toDouble() /
                                                                  60) &&
                                                      activeUser ||
                                                  closeCheck < openCheck && activeUser
                                              ?
                                              //HapticFeedback.vibrate();
                                              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                                  return SelectGame(
                                                      snapshot.data!
                                                          .docs[index]['name']
                                                          .toUpperCase(),
                                                      snapshot.data!
                                                          .docs[index]['id']
                                                          .toString()
                                                          .trim(),
                                                      openCheck > closeCheck &&
                                                          DateTime.now()
                                                                      .hour
                                                                      .toDouble() +
                                                                  DateTime.now()
                                                                          .minute
                                                                          .toDouble() /
                                                                      60 <
                                                              DateTime.parse(
                                                                          '2021-12-27 ${snapshot.data!.docs[index]['end']}:00')
                                                                      .subtract(const Duration(
                                                                          minutes:
                                                                              10))
                                                                      .hour
                                                                      .toDouble() +
                                                                  DateTime.parse('2021-12-27 ${snapshot.data!.docs[index]['end']}:00')
                                                                          .subtract(
                                                                              const Duration(minutes: 10))
                                                                          .minute
                                                                          .toDouble() /
                                                                      60);
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
                                          builder:
                                              (context, animation, child) =>
                                                  Transform.translate(
                                            offset: Offset(
                                                deltaX * shake(animation), 0),
                                            child: Card(
                                              // child: ,

                                              color: Colors.transparent,
                                              elevation: 0,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20))),
                                              // child: ,

                                              child: SizedBox(
                                                height: 120,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () => Navigator
                                                                  .of(context)
                                                              .push(MaterialPageRoute(
                                                                  builder:
                                                                      (context) {
                                                            return Charts(snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                ['id']);
                                                          })),
                                                          child: SizedBox(
                                                            height: 30,
                                                            width: 30,
                                                            child: SvgPicture
                                                                .asset(
                                                              'assets/charts.svg',
                                                            ),
                                                          ),
                                                        ),
                                                        Column(
                                                          children: [
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.68,
                                                              child: Center(
                                                                child:
                                                                    TextScroll(
                                                                  snapshot
                                                                      .data!
                                                                      .docs[
                                                                          index]
                                                                          [
                                                                          'name']
                                                                      .toUpperCase(),
                                                                  // maxLines: 1,
                                                                  // overflow:
                                                                  //     TextOverflow
                                                                  //         .ellipsis,

                                                                  velocity: const Velocity(
                                                                      pixelsPerSecond:
                                                                          Offset(
                                                                              30,
                                                                              0)),
                                                                  delayBefore:
                                                                      const Duration(
                                                                          seconds:
                                                                              2),
                                                                  pauseBetween:
                                                                      const Duration(
                                                                          seconds:
                                                                              3),
                                                                  mode: TextScrollMode
                                                                      .bouncing,
                                                                  selectable:
                                                                      false,

                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: GoogleFonts.getFont(
                                                                      'Roboto Slab',
                                                                      textStyle:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            23,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      )),
                                                                ),
                                                              ),
                                                            ),
                                                            (openCheck > closeCheck &&
                                                                    DateTime.now().hour.toDouble() +
                                                                            DateTime.now().minute.toDouble() /
                                                                                60 <
                                                                        DateTime.parse('2021-12-27 ${snapshot.data!.docs[index]['end']}:00').subtract(const Duration(minutes: 10)).hour.toDouble() +
                                                                            DateTime.parse('2021-12-27 ${snapshot.data!.docs[index]['end']}:00').subtract(const Duration(minutes: 10)).minute.toDouble() /
                                                                                60)
                                                                ? FutureBuilder(
                                                                    future: FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'GamesData')
                                                                        .doc(snapshot
                                                                            .data!
                                                                            .docs[
                                                                                index]
                                                                            .id
                                                                            .toString())
                                                                        .collection(
                                                                            'Games')
                                                                        .doc(formattedYestardayFinal
                                                                            .trim())
                                                                        .get(),
                                                                    builder:
                                                                        (context, AsyncSnapshot<DocumentSnapshot> snapshot3) {
                                                                      return snapshot3.data!['Numbers'].toUpperCase() ==
                                                                              ''
                                                                          ? Text(
                                                                              '* * * - * * - * *',
                                                                              style: GoogleFonts.getFont('Pacifico',
                                                                                  textStyle: const TextStyle(
                                                                                      fontSize: 20,
                                                                                      letterSpacing: 2.0,
                                                                                      //fontWeight: FontWeight.bold,
                                                                                      color: Color.fromRGBO(255, 178, 102, 1))))
                                                                          : Text(
                                                                              snapshot3.data!['Numbers'].toUpperCase(),
                                                                              style: GoogleFonts.getFont('Pacifico',
                                                                                  textStyle: const TextStyle(
                                                                                      fontSize: 20,
                                                                                      letterSpacing: 2.0,
                                                                                      //fontWeight: FontWeight.bold,
                                                                                      color: Color.fromRGBO(255, 178, 102, 1))),
                                                                            );
                                                                    })
                                                                : snapshot2.data!['Numbers'].toUpperCase() == ''
                                                                    ? Text('* * * - * * - * *',
                                                                        style: GoogleFonts.getFont('Pacifico',
                                                                            textStyle: const TextStyle(
                                                                                fontSize: 20,
                                                                                //fontWeight: FontWeight.bold,
                                                                                letterSpacing: 2.0,
                                                                                color: Color.fromRGBO(255, 178, 102, 1))))
                                                                    : Text(
                                                                        snapshot2
                                                                            .data!['Numbers']
                                                                            .toUpperCase(),
                                                                        style: GoogleFonts.getFont(
                                                                            'Pacifico',
                                                                            textStyle: const TextStyle(
                                                                                fontSize: 20,
                                                                                //fontWeight: FontWeight.bold,
                                                                                letterSpacing: 2.0,
                                                                                color: Color.fromRGBO(255, 178, 102, 1))),
                                                                      ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                Text(
                                                                  'Open- $formattedopen',
                                                                  //style: TextStyle(),
                                                                ),
                                                                const SizedBox(
                                                                  width: 20,
                                                                ),
                                                                Text(
                                                                  'Close- $formattedclose',
                                                                  //style: TextStyle(),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        (DateTime.now().hour.toDouble() +
                                                                            DateTime.now().minute.toDouble() /
                                                                                60 >=
                                                                        DateTime.parse('2021-12-27 00:00:00').hour.toDouble() +
                                                                            DateTime.parse('2021-12-27 00:00:00').minute.toDouble() /
                                                                                60) &&
                                                                    (DateTime.now().hour.toDouble() +
                                                                            DateTime.now().minute.toDouble() /
                                                                                60 <
                                                                        DateTime.parse('2021-12-27 ${snapshot.data!.docs[index]['end']}:00').subtract(const Duration(minutes: 10)).hour.toDouble() +
                                                                            DateTime.parse('2021-12-27 ${snapshot.data!.docs[index]['end']}:00').subtract(const Duration(minutes: 10)).minute.toDouble() /
                                                                                60) ||
                                                                closeCheck <
                                                                    openCheck
                                                            ? Image.asset(
                                                                'assets/play.png',
                                                                width: 35,
                                                                height: 35,
                                                              )
                                                            : Image.asset(
                                                                'assets/close.png',
                                                                width: 30,
                                                                height: 30,
                                                              )
                                                      ],
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              18.0, 0, 18, 0),
                                                      child: Divider(
                                                        color: Colors.white,
                                                        thickness: 2,
                                                        height: 10,
                                                      ),
                                                    ),
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
                  })),
        ],
      ),
    );
  }
}
