import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static String get bannerAdUnitId {
    // Replace with your own ad unit ID.
    return 'ca-app-pub-2979093467620072/9399839997';
  }

  static String get interstitialAdUnitId {
    // Replace with your own ad unit ID.
    return 'ca-app-pub-2979093467620072/2823157508';
  }

  static BannerAd getBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
  }

  static InterstitialAd? _interstitialAd;

  static void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  static InterstitialAd? getInterstitialAd() {
    return _interstitialAd;
  }
}
