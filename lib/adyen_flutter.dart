import 'package:flutter/services.dart';

enum PaymentStatus { captured, declined, cancelled, unknown }

PaymentStatus _mapStatus(String status) {
  switch (status.toLowerCase()) {
    case 'captured':
      return PaymentStatus.captured;
    case 'declined':
      return PaymentStatus.declined;
    case 'cancelled':
      return PaymentStatus.cancelled;
    default:
      return PaymentStatus.unknown;
  }
}

class PaymentResult {
  final PaymentStatus status;
  final String pspReference;

  PaymentResult({
    required this.status,
    required this.pspReference,
  });

  factory PaymentResult.fromMap(Map<dynamic, dynamic> map) {
    return PaymentResult(
      status: _mapStatus(map['status'] as String? ?? 'unknown'),
      pspReference: map['pspReference'] as String? ?? '',
    );
  }
}

class AdyenFlutter {
  static const MethodChannel _channel = MethodChannel('adyen_flutter');
  static const EventChannel _eventChannel =
      EventChannel('adyen_flutter/events');

  static Stream<String>? _connectionStream;

  static Stream<String> get connectionStatusStream {
    _connectionStream ??= _eventChannel.receiveBroadcastStream().cast<String>();
    return _connectionStream!;
  }

  /// Initialize the SDK with environment and merchant account
  static Future<void> initializeSdk({
    required String environment,
    required String merchantAccount,
    required String clientKey,
  }) async {
    await _channel.invokeMethod('initializeSdk', {
      'environment': environment,
      'merchantAccount': merchantAccount,
      'clientKey': clientKey,
    });
  }

  static Future<List<Map<String, dynamic>>> discoverReaders() async {
    final List<dynamic> readers =
        await _channel.invokeMethod('discoverReaders');
    return readers.cast<Map<String, dynamic>>();
  }

  static Future<bool> connectToReader({
    required String serialNumber,
  }) async {
    final bool success = await _channel.invokeMethod('connectToReader', {
      'serialNumber': serialNumber,
    });
    return success;
  }

  static Future<PaymentResult> startPayment({
    required int amount,
    required String currency,
    required String reference,
  }) async {
    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('startPayment', {
      'amount': amount,
      'currency': currency,
      'reference': reference,
    });

    return PaymentResult.fromMap(result);
  }
}
