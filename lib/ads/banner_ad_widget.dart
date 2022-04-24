import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logging/logging.dart';

/// Displays a banner ad from Google AdMob.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  static final _log = Logger('BannerAdWidget');

  static const _testAdId = 'ca-app-pub-3940256099942544/6300978111';
  static const _bannerAdId = 'ca-app-pub-3524048476448413/4431070537';

  BannerAd? _bannerAd;
  bool _isLoaded = false;
  late Orientation _currentOrientation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentOrientation = MediaQuery.of(context).orientation;
    _loadAd();
  }

  /// Load another ad, disposing of the current ad if there is one.
  Future<void> _loadAd() async {
    await _bannerAd?.dispose();

    setState(() {
      _bannerAd = null;
      _isLoaded = false;
    });

    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      _log.warning('Unable to get height of anchored banner.');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: (kDebugMode) ? _testAdId : _bannerAdId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          _log.info('$ad loaded: ${ad.responseInfo}');
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          _log.warning('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );

    return _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    /// Gets a widget containing the ad, if one is loaded.
    ///
    /// Returns an empty container if no ad is loaded, or the orientation
    /// has changed. Also loads a new ad if the orientation changes.
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_currentOrientation == orientation &&
            _bannerAd != null &&
            _isLoaded) {
          return Container(
            color: Colors.grey[800],
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          );
        }

        // Reload the ad if the orientation changes.
        if (_currentOrientation != orientation) {
          _currentOrientation = orientation;
          _loadAd();
        }

        return Container();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
  }
}
