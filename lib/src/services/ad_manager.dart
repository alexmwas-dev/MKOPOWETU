
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:developer' as developer;

class AdManager {
  static const String _androidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _androidInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return _androidBannerAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _androidInterstitialAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static BannerAd createBannerAd(BannerAdListener listener) {
    final BannerAd bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: listener,
    );
    return bannerAd;
  }

  static void loadAndShowInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) =>
                developer.log('$ad onAdShowedFullScreenContent.'),
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              developer.log('$ad onAdFailedToShowFullScreenContent: $error');
              ad.dispose();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          developer.log('InterstitialAd failed to load: $error');
        },
      ),
    );
  }
}
