import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:play_integrity_flutter/models/play_integrity_model.dart';
import 'package:play_integrity_flutter/play_integrity_flutter.dart';
import 'package:play_integrity_flutter/play_integrity_flutter_platform_interface.dart';
import 'package:play_integrity_flutter/play_integrity_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPlayIntegrityFlutterPlatform
    with MockPlatformInterfaceMixin
    implements PlayIntegrityFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<GooglePlayServicesAvailability?> googlePlayServicesAvailability() {
    // TODO: implement googlePlayServicesAvailability
    throw UnimplementedError();
  }

  @override
  Future<PlayIntegrity> playIntegrityPayload(String nonce, String decryptionKey, String verificationKey) {
    // TODO: implement playIntegrityPayload
    throw UnimplementedError();
  }

  @override
  Future<PlayIntegrity> playIntegrityWithFormattedNoncePayload(Uint8List nonce, String decryptionKey, String verificationKey) {
    // TODO: implement playIntegrityWithFormattedNoncePayload
    throw UnimplementedError();
  }
}

void main() {
  final PlayIntegrityFlutterPlatform initialPlatform = PlayIntegrityFlutterPlatform.instance;

  test('$MethodChannelPlayIntegrityFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPlayIntegrityFlutter>());
  });

  test('getPlatformVersion', () async {
    PlayIntegrityFlutter playIntegrityFlutterPlugin = PlayIntegrityFlutter();
    MockPlayIntegrityFlutterPlatform fakePlatform = MockPlayIntegrityFlutterPlatform();
    PlayIntegrityFlutterPlatform.instance = fakePlatform;

    expect(await playIntegrityFlutterPlugin.getPlatformVersion(), '42');
  });
}
