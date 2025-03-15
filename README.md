![Adyen Logo](https://authn-test.adyen.com/authn/img/adyen.svg)

# Adyen Flutter Plugin (`adyen_flutter`)

This Flutter plugin is a **bridge** to the **Adyen POS Mobile SDK** for iOS and Android. It allows your Flutter app to **integrate with Adyen payment terminals**, such as the **NYC1** and **S1F2**, and process **in-person card-present payments**.

---

## ✅ Features

- Initialize the **Adyen POS Mobile SDK**.
- Discover nearby payment terminals (Bluetooth/LAN).
- Connect to a selected terminal.
- Start and manage **in-person payments**.
- Listen to **terminal connection events** (connected, disconnected, failed).

---

## ✅ Supported Adyen Devices

- **NYC1** (Chip Reader)
- **S1F2** (All-in-One Android Terminal)

---

## ✅ Requirements

| Platform   | Version               |
|------------|-----------------------|
| **Flutter**| `3.0.0` or higher     |
| **iOS**    | iOS 13.0+             |
| **Android**| API 21+ (Lollipop)    |

---

## ✅ Adyen SDK Dependencies

This plugin wraps the **Adyen POS Mobile SDK**:

- **iOS**: `adyen-pos-mobile-ios-test` (Swift Package Manager)  
  [Adyen POS Mobile iOS Documentation](https://docs.adyen.com/point-of-sale/android/pos-terminal-api)
- **Android**: `com.adyen.checkout:terminal` (Maven Central)

➡️ **Important**: You must have **access to Adyen’s POS Mobile SDK**. Contact [Adyen Support](https://www.adyen.com/contact) for access to:

- iOS SPM repo: `https://github.com/Adyen/adyen-pos-mobile-ios-test`
- Android Maven repository credentials (if not public).

---

## ✅ Installation

### 1. Add Dependency to `pubspec.yaml`

If the plugin is hosted in your **private GitHub repo**:

```yaml
dependencies:
  adyen_flutter:
    git:
      url: git@github.com:meettippy/adyen_flutter.git
      ref: v0.0.1 # or the latest version
```

---

### 2. iOS Setup (Runner App)

#### ✅ Add AdyenPOS SDK via Swift Package Manager

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Go to **File > Add Packages...**
3. Enter the Adyen SPM URL:

   ```
   https://github.com/Adyen/adyen-pos-mobile-ios-test
   ```

4. Add `AdyenPOSTEST` to your **Runner app target**.

#### ✅ Add Capabilities

- **Bluetooth**
- **Local Network** (for LAN communication)

#### ✅ Info.plist

Add the following keys:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to connect to payment terminals.</string>
<key>NSLocalNetworkUsageDescription</key>
<string>This app connects to terminals on your local network.</string>
```

---

### 3. Android Setup

#### ✅ Add Dependencies

`adyen_flutter` handles linking the Adyen POS SDK. Ensure you have:

- `minSdkVersion 21` in your `android/app/build.gradle`.

#### ✅ Permissions in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

---

## ✅ Usage

### 1. Initialize SDK

```dart
await AdyenFlutter.initializeSdk(
  environment: 'TEST', // or 'LIVE'
  merchantAccount: 'YOUR_MERCHANT_ACCOUNT',
  clientKey: 'YOUR_CLIENT_KEY',
);
```

### 2. Discover Readers

```dart
List<Map<String, dynamic>> readers = await AdyenFlutter.discoverReaders();

if (readers.isNotEmpty) {
  String serialNumber = readers.first['serialNumber'];
  await AdyenFlutter.connectToReader(serialNumber: serialNumber);
}
```

### 3. Start a Payment

```dart
PaymentResult paymentResult = await AdyenFlutter.startPayment(
  amount: 5000, // Minor units (50.00 USD)
  currency: 'USD',
  reference: 'TXN12345',
);

switch (paymentResult.status) {
  case PaymentStatus.captured:
    print("Payment successful!");
    break;
  case PaymentStatus.declined:
    print("Payment declined.");
    break;
  case PaymentStatus.cancelled:
    print("Payment was cancelled.");
    break;
  default:
    print("Unknown payment status.");
}
```

### 4. Listen for Terminal Connection Events

```dart
AdyenFlutter.connectionStatusStream.listen((status) {
  print("Connection Status: $status");

  if (status == "connected") {
    // Show connected UI
  } else if (status == "disconnected") {
    // Attempt reconnect or notify user
  }
});
```

---

## ✅ Available Methods

| Method               | Description                                          |
|----------------------|------------------------------------------------------|
| `initializeSdk()`    | Initializes the Adyen POS SDK.                       |
| `discoverReaders()`  | Returns a list of available readers (Bluetooth/LAN). |
| `connectToReader()`  | Connects to a selected reader by serial number.      |
| `startPayment()`     | Starts a payment transaction on the connected reader.|

---

## ✅ Available Events

| Event                | Description                        |
|----------------------|------------------------------------|
| `connected`          | Reader successfully connected.     |
| `disconnected`       | Reader disconnected.               |
| `connection_failed`  | Failed to connect to reader.       |

---

## ✅ Versioning

This plugin uses **semantic versioning**:

- Latest release: `v0.0.1`

Check available versions on your GitHub repo or by running:

```bash
git tag
```

---

## ✅ Roadmap

| Feature                        | Status                    |
|--------------------------------|---------------------------|
| Payments                      | ✅ Complete               |
| Connection Events             | ✅ Complete               |
| Refunds/Cancellations         | ❌ Not supported in app   |
| Battery/Reader Info           | ⏳ Planned                |
| Auto-Reconnection Logic       | ⏳ Planned                |
| Reader Firmware Update Support| ⏳ Planned                |
| Error & Retry Strategies      | ⏳ Planned                |
| Transaction History           | ⏳ Planned (via backend)  |
| Multi-Reader Support          | ⏳ Planned                |

---

## ✅ Known Limitations

- Refunds and cancellations are **not** handled in-app. Use your **backend** or **Adyen Dashboard** for these actions.
- You **must** provision WiFi credentials to devices like **NYC1** using the **Adyen Provisioning App**.

---

## ✅ Links and Resources

- [Adyen Documentation](https://docs.adyen.com/point-of-sale)
- [Adyen POS Mobile SDK iOS](https://github.com/Adyen/adyen-pos-mobile-ios-test)
- [Contact Adyen](https://www.adyen.com/contact)

---

## ✅ License

This plugin is proprietary and intended for internal use by `Tippy`.

---

# ✅ Final Notes

1. This plugin requires **Adyen POS SDK access** from Adyen.
2. You are responsible for PCI compliance related to card-present transactions.
3. Test thoroughly on **physical terminals** (NYC1, S1F2).
