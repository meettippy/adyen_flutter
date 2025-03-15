import 'package:flutter_test/flutter_test.dart';
import 'package:adyen_flutter/adyen_flutter.dart';
import 'package:adyen_flutter/adyen_flutter_platform_interface.dart';
import 'package:adyen_flutter/adyen_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAdyenFlutterPlatform
    with MockPlatformInterfaceMixin
    implements AdyenFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AdyenFlutterPlatform initialPlatform = AdyenFlutterPlatform.instance;

  test('$MethodChannelAdyenFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAdyenFlutter>());
  });

  test('getPlatformVersion', () async {
    AdyenFlutter adyenFlutterPlugin = AdyenFlutter();
    MockAdyenFlutterPlatform fakePlatform = MockAdyenFlutterPlatform();
    AdyenFlutterPlatform.instance = fakePlatform;

    // expect(await adyenFlutterPlugin.getPlatformVersion(), '42');
  });
}
