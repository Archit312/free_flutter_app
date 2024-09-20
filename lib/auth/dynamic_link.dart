import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

StreamController<String> controller = StreamController<String>();

class DynamicLinkService {
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  Future<String> retrieveDynamicLink(BuildContext context) async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    var finalid = '';
    var tem = _handleDeepLink(data!, context);
    if (tem != '') {
      return tem;
    }
    dynamicLinks.onLink.listen((event) {
      final Uri deepLink = event.link;
      String? id;
      if (deepLink.queryParameters.containsKey('id')) {
        id = deepLink.queryParameters['id']!;
        finalid = id;
      }
    });
    return finalid;
  }

  _handleDeepLink(PendingDynamicLinkData data, BuildContext context) {
    final Uri deepLink = data.link;
    String? id;
    if (deepLink.queryParameters.containsKey('id')) {
      id = deepLink.queryParameters['id']!;
      return id;
    }
    }

  Future<Uri> createDynamicLink(String id) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://mumbaibazarmain.page.link',
      link: Uri.parse('https://www.mainmumbaibazar.com/?id=$id'),
      androidParameters: const AndroidParameters(
        packageName: 'com.dpBoss.mainmumbaibazar',
        minimumVersion: 1,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Main Mumbai Bazar',
        description: 'Download the app now',
        imageUrl: Uri.parse(
            'https://firebasestorage.googleapis.com/v0/b/mainmumbaibaazar.appspot.com/o/logo.jpg?alt=media&token=cdcff20f-4631-47fa-a956-f5ef91b2f85d'),
      ),
    );
    ShortDynamicLink shortDynamicLink =
        await dynamicLinks.buildShortLink(parameters);
    final Uri shortUrl = shortDynamicLink.shortUrl;
    return shortUrl;
  }
}
