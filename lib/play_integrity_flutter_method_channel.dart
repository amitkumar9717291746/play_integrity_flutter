import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models/play_integrity_model.dart';
import 'play_integrity_flutter_platform_interface.dart';

/// An implementation of [PlayIntegrityFlutterPlatform] that uses method channels.
class MethodChannelPlayIntegrityFlutter extends PlayIntegrityFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('play_integrity_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  //Check if you have the google play service enabled
  @override
  Future<GooglePlayServicesAvailability?>
      googlePlayServicesAvailability() async {
    final String result =
        await methodChannel.invokeMethod('checkGooglePlayServicesAvailability');

    switch (result) {
      case 'success':
        return GooglePlayServicesAvailability.success;
      case 'service_missing':
        return GooglePlayServicesAvailability.serviceMissing;
      case 'service_updating':
        return GooglePlayServicesAvailability.serviceUpdating;
      case 'service_version_update_required':
        return GooglePlayServicesAvailability.serviceVersionUpdateRequired;
      case 'service_disabled':
        return GooglePlayServicesAvailability.serviceDisabled;
      case 'service_invalid':
        return GooglePlayServicesAvailability.serviceInvalid;
    }

    return null;
  }

  @override
  Future<PlayIntegrity> playIntegrityPayload(
      String nonce, String decryptionKey, String verificationKey) async {
    final String payload =
        await methodChannel.invokeMethod('requestPlayIntegrity', {
      "nonce_string": nonce,
      "decryption_key": decryptionKey,
      "verification_key": verificationKey
    });

    return PlayIntegrity.fromJson(jsonDecode(payload));
  }

  @override
  Future<PlayIntegrity> playIntegrityWithFormattedNoncePayload(
      Uint8List nonce, String decryptionKey, String verificationKey) async {
    final String payload =
        await methodChannel.invokeMethod('requestPlayIntegrity', {
      "nonce_bytes": nonce,
      "decryption_key": decryptionKey,
      "verification_key": verificationKey
    });

    return PlayIntegrity.fromJson(jsonDecode(payload));
  }
}
