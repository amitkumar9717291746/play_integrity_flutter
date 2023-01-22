import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:play_integrity_flutter/models/play_integrity_model.dart';
import 'package:play_integrity_flutter/play_integrity_flutter.dart';
import 'package:play_integrity_flutter/play_integrity_flutter_platform_interface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _playIntegrityFlutterPlugin = PlayIntegrityFlutter();
  GooglePlayServicesAvailability? _gmsStatus;
  PlayIntegrity? _playIntegrity;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initGooglePlayServicesAvailability();
    initPlayIntegrity();
    initPlayIntegrityWithFormattedNonce();
  }


  Future<void> initPlayIntegrityWithFormattedNonce() async {
    PlayIntegrity? playIntegrity;
    Uint8List nonce = Uint8List(16);
    try {
      playIntegrity = await _playIntegrityFlutterPlugin.playIntegrityWithFormattedNoncePayload(
          nonce, 'decryptionKey', 'verificationKey');
    } on Exception {
      playIntegrity = null;
    }

    if (!mounted) return;

    setState(() {
      _playIntegrity = playIntegrity;
    });
  }

  Future<void> initPlayIntegrity() async {
    PlayIntegrity? playIntegrity;

    try {
      playIntegrity = await _playIntegrityFlutterPlugin.playIntegrityPayload(
          'nonce', 'decryptionKey', 'verificationKey');
    } on Exception {
      playIntegrity = null;
    }

    if (!mounted) return;

    setState(() {
      _playIntegrity = playIntegrity;
    });
  }

  Future<void> initGooglePlayServicesAvailability() async {
    GooglePlayServicesAvailability? gmsAvailability;
    try {
      gmsAvailability =
          await _playIntegrityFlutterPlugin.googlePlayServicesAvailability();
    } on PlatformException {
      gmsAvailability = null;
    }

    if (!mounted) return;

    setState(() {
      _gmsStatus = gmsAvailability;
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _playIntegrityFlutterPlugin.getPlatformVersion() ??
              'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
              Text('$_gmsStatus\n'),
            ],
          ),
        ),
      ),
    );
  }
}
