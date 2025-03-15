import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'adyen_flutter_method_channel.dart';

abstract class AdyenFlutterPlatform extends PlatformInterface {
  /// Constructs a AdyenFlutterPlatform.
  AdyenFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static AdyenFlutterPlatform _instance = MethodChannelAdyenFlutter();

  /// The default instance of [AdyenFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelAdyenFlutter].
  static AdyenFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AdyenFlutterPlatform] when
  /// they register themselves.
  static set instance(AdyenFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
