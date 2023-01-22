import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_integrity_flutter/play_integrity_flutter_method_channel.dart';

void main() {
  MethodChannelPlayIntegrityFlutter platform = MethodChannelPlayIntegrityFlutter();
  const MethodChannel channel = MethodChannel('play_integrity_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
