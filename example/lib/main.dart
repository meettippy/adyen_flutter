import 'package:flutter/material.dart';
import 'package:adyen_flutter/adyen_flutter.dart'; // ✅ importing from lib

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AdyenTestScreen(),
    );
  }
}

class AdyenTestScreen extends StatefulWidget {
  @override
  _AdyenTestScreenState createState() => _AdyenTestScreenState();
}

class _AdyenTestScreenState extends State<AdyenTestScreen> {
  String _status = 'Idle';

  Future<void> initialize() async {
    try {
      await AdyenFlutter.initializeSdk(
        environment: 'TEST', // 'LIVE' for production
        merchantAccount: 'DirectTips', // Replace!
        clientKey: 'YOUR_CLIENT_KEY', // Replace!
      );
      setState(() {
        _status = 'SDK Initialized!';
      });
    } catch (e) {
      setState(() {
        _status = 'Initialization Failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adyen Flutter Plugin Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: initialize,
              child: const Text('Initialize SDK'),
            ),
            const SizedBox(height: 20),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
