import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'models/play_integrity_model.dart';
import 'play_integrity_flutter_method_channel.dart';

abstract class PlayIntegrityFlutterPlatform extends PlatformInterface {
  /// Constructs a PlayIntegrityFlutterPlatform.
  PlayIntegrityFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static PlayIntegrityFlutterPlatform _instance =
      MethodChannelPlayIntegrityFlutter();

  /// The default instance of [PlayIntegrityFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelPlayIntegrityFlutter].
  static PlayIntegrityFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PlayIntegrityFlutterPlatform] when
  /// they register themselves.
  static set instance(PlayIntegrityFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<GooglePlayServicesAvailability?> googlePlayServicesAvailability() {
    throw UnimplementedError(
        'googlePlayServicesAvailability() has not been implemented.');
  }

  Future<PlayIntegrity> playIntegrityPayload(
      String nonce, String decryptionKey, String verificationKey) {
    throw UnimplementedError(
        'playIntegrityPayload() has not been implemented.');
  }

  Future<PlayIntegrity> playIntegrityWithFormattedNoncePayload(
      Uint8List nonce, String decryptionKey, String verificationKey) {
    throw UnimplementedError(
        'playIntegrityWithFormattedNoncePayload() has not been implemented.');
  }
}

enum GooglePlayServicesAvailability {
  success,
  serviceMissing,
  serviceUpdating,
  serviceVersionUpdateRequired,
  serviceDisabled,
  serviceInvalid
}
