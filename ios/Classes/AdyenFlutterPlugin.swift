import Flutter
import UIKit
import AdyenPOS

public class SwiftAdyenFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, ConnectionObserver {

    private var discoveredReaders: [String: Reader] = [:]
    private var eventSink: FlutterEventSink?
    


    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "adyen_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftAdyenFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
       
        let eventChannel = FlutterEventChannel(name: "adyen_flutter/events", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)

    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }


    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initializeSdk":
            if let args = call.arguments as? [String: Any],
               let environmentStr = args["environment"] as? String,
               let merchantAccount = args["merchantAccount"] as? String,
               let clientKey = args["clientKey"] as? String {
                initializeSdk(environmentStr: environmentStr, merchantAccount: merchantAccount, clientKey: clientKey)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing args", details: nil))
            }
        case "discoverReaders":
            discoverReaders(result: result)

        case "connectToReader":
            guard let args = call.arguments as? [String: Any],
                  let serialNumber = args["serialNumber"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing serialNumber", details: nil))
                return
            }
            connectToReader(serialNumber: serialNumber, result: result)

        case "startPayment":
            guard let args = call.arguments as? [String: Any],
                  let amount = args["amount"] as? Int,
                  let currency = args["currency"] as? String,
                  let reference = args["reference"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing payment args", details: nil))
                return
            }
            startPayment(amount: amount, currency: currency, reference: reference, result: result)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initializeSdk(environmentStr: String, merchantAccount: String, clientKey: String) {
        let environment: Environment = environmentStr.uppercased() == "LIVE" ? .live : .test

        let configuration = TerminalConfiguration(
            environment: environment,
            clientKey: clientKey,
            merchantAccount: merchantAccount
        )

        Terminal.initialize(configuration: configuration)
    }

    private func discoverReaders(result: @escaping FlutterResult) {
        let discoveryConfiguration = ReaderDiscoveryConfiguration(readerTypes: [.any], scanMethod: .bluetooth)

        Terminal.shared.discoverReaders(discoveryConfiguration) { readers, error in
            if let error = error {
                result(FlutterError(code: "DISCOVERY_ERROR", message: error.localizedDescription, details: nil))
                return
            }

            let readerList = readers.map { reader in
                return [
                    "name": reader.model,
                    "serialNumber": reader.serialNumber
                ]
            }

            result(readerList)
        }
    }


    private func connectToReader(serialNumber: String, result: @escaping FlutterResult) {
        guard let reader = discoveredReaders[serialNumber] else {
            result(FlutterError(code: "READER_NOT_FOUND", message: "Reader not found: \(serialNumber)", details: nil))
            return
        }

        Terminal.shared.connectReader(reader) { connectedReader, error in
            if let error = error {
                self.eventSink?("connection_failed: \(error.localizedDescription)")
                result(FlutterError(code: "CONNECTION_FAILED", message: error.localizedDescription, details: nil))
                return
            }

            guard let _ = connectedReader else {
                self.eventSink?("connection_failed: unknown error")
                result(FlutterError(code: "CONNECTION_FAILED", message: "Unknown error", details: nil))
                return
            }

            Terminal.shared.addConnectionObserver(self)

            self.eventSink?("connected")
            result(true)
        }
    }

    public func didConnect(reader: Reader) {
        eventSink?("connected")
    }

    public func didDisconnect(reader: Reader, error: Error?) {
        if let error = error {
            eventSink?("disconnected: \(error.localizedDescription)")
        } else {
            eventSink?("disconnected")
        }
    }
                    
    private func startPayment(amount: Int, currency: String, reference: String, result: @escaping FlutterResult) {
        let paymentAmount = Amount(currency: currency, value: amount)
        let paymentRequest = PaymentRequest(amount: paymentAmount, reference: reference)

        Terminal.shared.submitPayment(paymentRequest) { paymentResult, error in
            if let error = error {
                result(FlutterError(code: "PAYMENT_FAILED", message: error.localizedDescription, details: nil))
                return
            }

            guard let paymentResult = paymentResult else {
                result(FlutterError(code: "PAYMENT_FAILED", message: "Unknown error", details: nil))
                return
            }

            var status: String

            switch paymentResult.result {
            case .authorized:
                status = "captured"
            case .declined:
                status = "declined"
            case .cancelled:
                status = "cancelled"
            @unknown default:
                status = "unknown"
            }

            let paymentData: [String: Any] = [
                "status": status,
                "pspReference": paymentResult.pspReference
            ]

            result(paymentData)
        }
    }

    deinit {
        Terminal.shared.removeConnectionObserver(self)
    }
}
