import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:frontend/services/functions/PaymentService.dart';
import 'package:frontend/utils/toasts.dart';
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
    Stripe.publishableKey = AppConstants.PUBLIC_KEY_STRIPE;
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
                    String _intentId = paymentInfo['paymentIntentId']; // Store the ID
                    await Stripe.instance.initPaymentSheet(
                      paymentSheetParameters: SetupPaymentSheetParameters(
                        paymentIntentClientSecret: _intent,
                        merchantDisplayName: "Mindify",
                        customerId: paymentInfo['customer'],
                        customerEphemeralKeySecret: paymentInfo['ephemeralKey'],
                      ),
                    );

                    await Stripe.instance.presentPaymentSheet();

                    try {
                      Map<String, dynamic> confirmation = await paymentService.confirmPayment(_intentId); // Use the ID here
                      showSuccessToast(context, 'Payment successful: ${confirmation['success']}');
                    } catch (e) {
                      log('Confirmation error: $e');
                      showErrorToast(context, 'Payment confirmation error: $e');
                    }
                  }
                } catch (e) {
                  log('Payment intent error: $e');
                  showErrorToast(context, 'Payment intent error: $e');
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
