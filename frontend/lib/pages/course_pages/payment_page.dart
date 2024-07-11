import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:frontend/services/functions/PaymentService.dart';
import 'package:getwidget/getwidget.dart';
import 'package:frontend/utils/constants.dart';

class PaymentPage extends StatefulWidget {
  final String userId;
  final String courseId;
  final int price;

  const PaymentPage({
    super.key,
    required this.userId,
    required this.courseId,
    required this.price,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final paymentService = PaymentService();

  @override
  void initState() {
    super.initState();
    // Set the publishable key for Stripe
    Stripe.publishableKey = AppConstants.PUBLIC_KEY_STRIPE;
    // Optionally set the stripe account ID
    Stripe.instance.applySettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: [
            GFButton(
              onPressed: () async {
                try {
                  Map<String, dynamic> paymentInfo = await paymentService.createPaymentIntent(widget.userId, widget.courseId);
                  if (paymentInfo['paymentIntent'] != "" && paymentInfo['paymentIntent'] != null) {
                    String _intent = paymentInfo['paymentIntent'];
                    await Stripe.instance.initPaymentSheet(
                      paymentSheetParameters: SetupPaymentSheetParameters(
                        paymentIntentClientSecret: _intent,
                        merchantDisplayName: "Mindify",
                        customerId: paymentInfo['customer'],
                        customerEphemeralKeySecret: paymentInfo['ephemeralKey'],
                        
                      ),
                    );
                    await Stripe.instance.presentPaymentSheet();
                  }
                } catch (e) {
                  log(e.toString());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment error: $e')),
                  );
                }
              },
              text: "Stripe Payment",
            ),
          ],
        ),
      ),
    );
  }
}
