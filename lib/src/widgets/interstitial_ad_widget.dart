import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mkopo_wetu/src/services/ad_manager.dart';
import 'dart:developer' as developer;

class InterstitialAdWidget {
  InterstitialAd? _interstitialAd;

  void loadAd() {
    AdManager.createInterstitialAd((ad) {
      developer.log('Interstitial ad loaded.');
      _interstitialAd = ad;
    });
  }

  void showAdWithCallback(void Function() onAdClosed) {
    if (_interstitialAd == null) {
      developer.log('Interstitial ad not ready.');
      onAdClosed();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        developer.log('Interstitial ad dismissed.');
        ad.dispose();
        loadAd(); // Pre-load the next ad
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        developer.log('Interstitial ad failed to show: $error');
        ad.dispose();
        loadAd(); // Pre-load the next ad
        onAdClosed();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null; // The ad can only be shown once.
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
