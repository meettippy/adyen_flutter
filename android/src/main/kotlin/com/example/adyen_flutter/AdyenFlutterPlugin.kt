package com.yourcompany.adyen_flutter

import android.app.Application
import androidx.annotation.NonNull
import com.adyen.checkout.terminal.Terminal
import com.adyen.checkout.terminal.TerminalConfiguration
import com.adyen.checkout.terminal.Environment

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AdyenFlutterPlugin: FlutterPlugin, MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var terminal: Terminal
    private val discoveredReaders = mutableMapOf<String, Reader>()

    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "adyen_flutter")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "adyen_flutter/events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "initializeSdk" -> {
                val environmentStr = call.argument<String>("environment") ?: "TEST"
                val merchantAccount = call.argument<String>("merchantAccount") ?: ""
                val clientKey = call.argument<String>("clientKey") ?: ""

                initializeSdk(environmentStr, merchantAccount, clientKey)
                result.success(null)
            }

            "discoverReaders" -> {
                discoverReaders(result)
            }

            "connectToReader" -> {
                val serialNumber = call.argument<String>("serialNumber") ?: ""
                connectToReader(serialNumber, result)
            }

            "startPayment" -> {
                val amount = call.argument<Int>("amount") ?: 0
                val currency = call.argument<String>("currency") ?: "USD"
                val reference = call.argument<String>("reference") ?: "flutter-txn"

                startPayment(amount, currency, reference, result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initializeSdk(environmentStr: String, merchantAccount: String, clientKey: String) {
        val env = if (environmentStr == "LIVE") Environment.LIVE else Environment.TEST

        val terminalConfig = TerminalConfiguration.Builder(
            environment = env,
            clientKey = clientKey,
            merchantAccount = merchantAccount
        ).build()

        Terminal.init(terminalConfig)
    }

    private fun discoverReaders(result: MethodChannel.Result) {
        val configuration = ReaderDiscoveryConfiguration(ReaderType.ALL, ScanMethod.BLUETOOTH)

        terminal.discoverReaders(configuration, object : ReaderDiscoveryListener {
            override fun onReaderDiscovered(reader: Reader) {
                val readerInfo = mapOf(
                    "name" to reader.model,
                    "serialNumber" to reader.serialNumber
                )
                // Send list of readers (or use EventChannel for real-time discovery)
                result.success(listOf(readerInfo))  // Simplified. Ideally use EventChannel or cache readers.
            }

            override fun onDiscoveryStopped() {
                // Optional: Notify discovery stopped.
            }
        })
    }

    private fun connectToReader(serialNumber: String, result: MethodChannel.Result) {
        val reader = discoveredReaders[serialNumber]

        if (reader == null) {
            result.error("READER_NOT_FOUND", "Reader not found with serial: $serialNumber", null)
            return
        }

        terminal.connectReader(reader, object : ConnectionListener {
            override fun onConnect(reader: Reader) {
                result.success(true) 
                eventSink?.success("connected") 
            }

            override fun onDisconnect(reader: Reader) {
                eventSink?.success("disconnected") 
            }

            override fun onFailure(reader: Reader, error: TerminalException) {
                result.error("CONNECTION_FAILED", error.message, null)
                eventSink?.success("connection_failed: ${error.message}") 
            }
        })
    }


    private fun startPayment(amount: Int, currency: String, reference: String, result: MethodChannel.Result) {
        val paymentAmount = Amount.Builder()
            .currency(currency)
            .value(amount.toLong())  // Adyen expects long for minor units
            .build()

        val paymentRequest = PaymentRequest.Builder(paymentAmount, reference).build()

        terminal.submitPayment(paymentRequest, object : PaymentResultListener {
            override fun onPaymentCompleted(paymentResult: PaymentResult) {
                val status = when (paymentResult.result) {
                    PaymentResult.Result.AUTHORIZED -> "captured"
                    PaymentResult.Result.DECLINED -> "declined"
                    PaymentResult.Result.CANCELLED -> "cancelled"
                    else -> "unknown"
                }

                val paymentData = mapOf(
                    "status" to status,
                    "pspReference" to paymentResult.pspReference
                )

                result.success(paymentData)
            }


            override fun onPaymentFailed(error: TerminalException) {
                result.error("PAYMENT_FAILED", error.message, null)
            }
        })
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
