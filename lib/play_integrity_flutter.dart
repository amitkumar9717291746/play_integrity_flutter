import 'dart:typed_data';

import 'models/play_integrity_model.dart';
import 'play_integrity_flutter_platform_interface.dart';

class PlayIntegrityFlutter {
  Future<String?> getPlatformVersion() {
    return PlayIntegrityFlutterPlatform.instance.getPlatformVersion();
  }

  Future<GooglePlayServicesAvailability?> googlePlayServicesAvailability() {
    return PlayIntegrityFlutterPlatform.instance
        .googlePlayServicesAvailability();
  }

  Future<PlayIntegrity> playIntegrityPayload(
      String nonce, String decryptionKey, String verificationKey) {
    return PlayIntegrityFlutterPlatform.instance
        .playIntegrityPayload(nonce, decryptionKey, verificationKey);
  }

  Future<PlayIntegrity> playIntegrityWithFormattedNoncePayload(
      Uint8List nonce, String decryptionKey, String verificationKey) {
    return PlayIntegrityFlutterPlatform.instance
        .playIntegrityWithFormattedNoncePayload(
            nonce, decryptionKey, verificationKey);
  }
}
