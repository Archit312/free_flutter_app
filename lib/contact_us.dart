import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: FutureBuilder(
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
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text('Mobile No'),
                      Text(snapshot.data!['whatsApp']),
                      IconButton(
                          onPressed: () async =>
                              launch("tel://${snapshot.data!['whatsApp']}"),
                          icon: Image.asset('assets/phone.png')),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text('Mobile No 2'),
                      Text(snapshot.data!['whatsApp']),
                      IconButton(
                          onPressed: () async =>
                              launch("tel://${snapshot.data!['whatsApp']}"),
                          icon: Image.asset('assets/phone.png')),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text('Whats App'),
                      Text(snapshot.data!['whatsApp']),
                      IconButton(
                          onPressed: () async => await launch(
                              "https://wa.me/+91${snapshot.data!['whatsApp']}?text=I want to add money to my account."),
                          icon: Image.asset('assets/whatsApp.png')),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text('Email'),
                      Text(snapshot.data!['email']),
                      IconButton(
                        onPressed: () async =>
                            await launch("mailto:${snapshot.data!['email']}}"),
                        icon: const Icon(Icons.email),
                      )
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}
