import 'dart:developer';
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
      return 'ca-app-pub-2979093467620072/2915636747';
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2979093467620072/9399839997';
    } else {
      // iOS
      return  'ca-app-pub-2979093467620072/9399839997';
    }
  }

  static BannerAd createBannerAd(BannerAdListener listener) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: listener,
    )..load();
  }

  static void createInterstitialAd(
    void Function(InterstitialAd) onAdLoaded,
  ) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (LoadAdError error) {
          log('InterstitialAd failed to load: $error');
        },
      ),
    );
  }
}
