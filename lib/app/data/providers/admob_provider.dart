import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobProvider {
  String? get bannerUnitId {
    if (kReleaseMode) {
      if (Platform.isIOS) {
        return 'ca-app-pub-8692533094122680/3188446671';
      } else if (Platform.isAndroid) {
        return 'ca-app-pub-8692533094122680/1948642928';
      }
    } else {
      if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2435281174';
      } else if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/9214589741';
      }
    }
    return null;
  }

  String? get interstitialUnitId {
    if (kReleaseMode) {
      if (Platform.isIOS) {
        return 'ca-app-pub-8692533094122680/8256940529';
      } else if (Platform.isAndroid) {
        return 'ca-app-pub-8692533094122680/9973330969';
      }
    } else {
      if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910';
      } else if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712';
      }
    }
    return null;
  }

  String? get rewardUnitId {
    if (kReleaseMode) {
      if (Platform.isIOS) {
        return 'ca-app-pub-8692533094122680/5623038325';
      } else if (Platform.isAndroid) {
        return 'ca-app-pub-8692533094122680/8322479585';
      }
    } else {
      if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/1712485313';
      } else if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/5224354917';
      }
    }
    return null;
  }

  final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => print('Ad Loaded'),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      print(error);
    },
    onAdOpened: (ad) => print('Ad Opened'),
    onAdClosed: (ad) => print('Ad Closed'),
  );
}
