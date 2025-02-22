import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;
import 'dart:math';

class GameProvider extends ChangeNotifier {
  // Oyun durumu değişkenleri
  int _score = 0;
  int get score => _score;

  List<Color> _colors = []; // Kart renkleri
  List<bool> _isFlipped = []; // Kartların çevrilme durumu
  List<bool> _isMatched = []; // Eşleşen kartlar
  int? _firstFlippedIndex; // İlk çevrilen kartın indeksi
  bool _canFlip = true; // Kart çevirme izni

  List<Color> get colors => _colors;
  List<bool> get isFlipped => _isFlipped;
  List<bool> get isMatched => _isMatched;
  bool get canFlip => _canFlip;

  // Banner reklam için değişken
  BannerAd? _bannerAd;
  BannerAd? get bannerAd => _bannerAd;

  // Geçiş reklamı için değişken
  InterstitialAd? _interstitialAd;

  // Ödüllü reklam için değişken
  RewardedAd? _rewardedAd;

  GameProvider() {
    _initializeGame();
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  void _initializeGame() {
    // Temel renkleri tanımla
    final baseColors = [
      const Color(0xFFE57373),
      const Color(0xFF64B5F6),
      const Color(0xFF81C784),
      const Color(0xFFFFD54F),
      const Color(0xFFBA68C8),
      const Color(0xFFFFB74D),
      const Color(0xFFF06292),
      const Color(0xFF4DB6AC),
    ];

    // Her renkten iki adet olacak şekilde diziyi oluştur
    _colors = [...baseColors, ...baseColors];

    // Başlangıç durumlarını ayarla
    _isFlipped = List.filled(_colors.length, false);
    _isMatched = List.filled(_colors.length, false);

    // Renkleri rastgele karıştır
    final random = Random();
    for (var i = _colors.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final tempColor = _colors[i];
      _colors[i] = _colors[j];
      _colors[j] = tempColor;
    }

    _score = 0;
    _firstFlippedIndex = null;
    _canFlip = true;
    notifyListeners();
  }

  void flipCard(int index) {
    // Kart çevirme kontrolü
    if (!_canFlip || _isFlipped[index] || _isMatched[index]) return;

    if (_firstFlippedIndex == null) {
      // İlk kart çevrildiğinde
      _isFlipped[index] = true;
      _firstFlippedIndex = index;
      notifyListeners();
    } else {
      // İkinci kart çevrildiğinde
      _isFlipped[index] = true;
      _canFlip = false;
      notifyListeners();

      // Eşleşme kontrolü için gecikme
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_colors[_firstFlippedIndex!] == _colors[index]) {
          // Kartlar eşleşti
          _isMatched[_firstFlippedIndex!] = true;
          _isMatched[index] = true;
          _score += 10;

          // Score her 30 un katları olduğunda geçiş reklamı göster
          if (_score % 30 == 0) {
            showInterstitialAd();
          }
        } else {
          // Kartlar eşleşmedi, geri çevir
          _isFlipped[_firstFlippedIndex!] = false;
          _isFlipped[index] = false;
        }

        // Yeni hamle için hazırla
        _firstFlippedIndex = null;
        _canFlip = true;
        notifyListeners();

        // Oyun bitti mi kontrol et
        if (_isMatched.every((matched) => matched)) {
          showRewardedAd(); // Oyun bittiğinde ödüllü reklam göster
        }
      });
    }
  }

  void restartGame() {
    _initializeGame();
  }

  // Banner reklamı yükleme
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: Platform.isAndroid
          // Android için test Interstitial ID
          ? 'ca-app-pub-3940256099942544/6300978111'
          // iOS için test Interstitial ID
          : 'ca-app-pub-3940256099942544/2934735716',
      listener: BannerAdListener(
        onAdLoaded: (_) => notifyListeners(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          notifyListeners();
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  // Geçiş reklamı yükleme
  void _loadInterstitialAd() {
    InterstitialAd.load(
      // Android için test Interstitial ID
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          // iOS için test Interstitial ID
          : 'ca-app-pub-3940256099942544/4411468910',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  // Ödüllü reklam yükleme
  void _loadRewardedAd() {
    RewardedAd.load(
      // Android için test Rewarded ID
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          // iOS için test Rewarded ID
          : 'ca-app-pub-3940256099942544/1712485313',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => _rewardedAd = null,
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _loadInterstitialAd();
    }
  }

  void showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (_, reward) {
          _score += 50; // Oyun sonu bonus puanı
          notifyListeners();
        },
      );
      _loadRewardedAd();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }
}
