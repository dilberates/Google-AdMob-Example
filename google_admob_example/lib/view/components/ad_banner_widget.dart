import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../../core/providers/game_provider.dart';

class AdBannerWidget extends StatelessWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (gameProvider.bannerAd == null) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: gameProvider.bannerAd!.size.width.toDouble(),
          height: gameProvider.bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: gameProvider.bannerAd!),
        );
      },
    );
  }
} 