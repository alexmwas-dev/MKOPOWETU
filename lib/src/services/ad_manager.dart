import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  // Use test ad unit IDs for development.
  // Replace with your own ad unit IDs for production.
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2979093467620072/2915636747';
    } else {
      // iOS
      return 'ca-app-pub-3940256099942544/2934735716';
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2979093467620072/9399839997';
    } else {
      // iOS
      return 'ca-app-pub-3940256099942544/4411468910';
    }
  }

  static BannerAd createBannerAd(BannerAdListener listener) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: listener,
    );
  }
}
