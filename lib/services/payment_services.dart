import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:gzresturent/core/utility.dart';
import 'package:gzresturent/main.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  final BuildContext context;
  final void Function(String paymentIntentId, bool success) onPaymentSuccess;

  PaymentService(this.context, {required this.onPaymentSuccess});

  Map<String, dynamic>? _paymentIntentData;

  /// Call this on button press
  Future<void> startPayment(String amount, String currency) async {
    try {
      _paymentIntentData = await _createPaymentIntent(amount, currency);
      final paymentIntentId = _paymentIntentData?['paymentIntentId'];

      log('payment intent data is ${paymentIntentId}');

      if (_paymentIntentData == null ||
          !_paymentIntentData!.containsKey('client_secret')) {
        print("❌ PaymentIntent creation failed or missing client_secret.");
        showSnackBar(
          context,
          '"❌ PaymentIntent creation failed or missing client_secret."',
        );
        return;
      }

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Gangehiz Khan Restaurant',
          paymentIntentClientSecret: _paymentIntentData!['client_secret'],
          style: ThemeMode.system,
          allowsDelayedPaymentMethods: true,
        ),
      );

      // Present payment UI
      await _presentPaymentSheet(paymentIntentId);
    } catch (e, st) {
      print("❌ Error in startPayment: $e");
      print(st);
    }
  }

  Future<void> _presentPaymentSheet(String paymentIntentId) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      _paymentIntentData = null;

      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text("✅ Payment successful")));

      // ✅ Call the callback with paymentIntentId and true
      onPaymentSuccess(paymentIntentId, true);
    } on StripeException catch (e) {
      print("⚠️ StripeException: $e");

      // ❌ Payment cancelled
      onPaymentSuccess(paymentIntentId, false);

      // showDialog(
      //   context: context,
      //   builder: (_) => const AlertDialog(content: Text("❌ Payment cancelled")),
      // );
    } catch (e) {
      print("❌ Error presenting payment sheet: $e");

      // ❌ Some other failure
      onPaymentSuccess(paymentIntentId, false);
    }
  }

  Future<Map<String, dynamic>?> _createPaymentIntent(
    String amount,
    String currency,
  ) async {
    try {
      final url = Uri.parse(
        'https://us-central1-genghis-khan-restaurant.cloudfunctions.net/createPaymentIntent',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount, 'currency': currency}),
      );

      final json = jsonDecode(response.body);
      print("📦 Firebase Function response: $json");
      return json;
    } catch (e) {
      print("❌ Error calling Firebase Function: $e");
      return null;
    }
  }

  Future<void> refundPayment(String paymentIntentId, {String? amount}) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://us-central1-genghis-khan-restaurant.cloudfunctions.net/refundPayment',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'paymentIntentId': paymentIntentId,
          if (amount != null) 'amount': amount, // Optional
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("✅ Refund successful: $data");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("💸 Refund processed successfully")),
        );
      } else {
        print("❌ Refund failed: ${data['error']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Refund failed: ${data['error']}")),
        );
      }
    } catch (e) {
      print("❌ Exception during refund: $e");
    }
  }
}
