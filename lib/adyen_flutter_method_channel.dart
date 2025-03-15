import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'adyen_flutter_platform_interface.dart';

/// An implementation of [AdyenFlutterPlatform] that uses method channels.
class MethodChannelAdyenFlutter extends AdyenFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('adyen_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
