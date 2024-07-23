import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:frontend/services/functions/PaymentService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:getwidget/getwidget.dart';
import 'package:frontend/utils/constants.dart';

class PaymentPage extends StatefulWidget {
  final String userId;
  final String courseId;
  final Course course;
  final int price;

  const PaymentPage({
    Key? key,
    required this.userId,
    required this.courseId,
    required this.price,
    required this.course,
  }) : super(key: key);

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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Payment'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.course.thumbnail,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16.0),
            Text(
              widget.course.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Instructor: ${widget.course.instructorName}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 16.0),
            Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.course.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Divider(),
            SizedBox(height: 16.0),
            Text(
              'Price: \$${widget.price}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            GFButton(
              onPressed: () async {
                try {
                  Map<String, dynamic> paymentInfo = await paymentService
                      .createPaymentIntent(widget.userId, widget.courseId);
                  if (paymentInfo['paymentIntent'] != "" &&
                      paymentInfo['paymentIntent'] != null) {
                    String intent = paymentInfo['paymentIntent'];
                    String intentId =
                        paymentInfo['paymentIntentId']; // Store the ID

                    await Stripe.instance.initPaymentSheet(
                      paymentSheetParameters: SetupPaymentSheetParameters(
                        paymentIntentClientSecret: intent,
                        merchantDisplayName: "Mindify",
                        customerId: paymentInfo['customer'],
                        customerEphemeralKeySecret: paymentInfo['ephemeralKey'],
                      ),
                    );

                    try {
                      await Stripe.instance.presentPaymentSheet();
                      Map<String, dynamic> confirmation =
                          await paymentService.confirmPayment(intentId);
                      showSuccessToast(context, 'Payment successful');
                    } on StripeException catch (e) {
                      if (e.error.code == FailureCode.Canceled) {
                        showErrorToast(context, 'Payment flow canceled.');
                      } else {
                        log('Confirmation error: $e');
                        showErrorToast(
                            context, 'Payment confirmation error: $e');
                      }
                    } catch (e) {
                      log('Payment confirmation error: $e');
                      showErrorToast(context, 'Payment confirmation error: $e');
                    }
                  }
                } catch (e) {
                  log('Payment intent error: $e');
                  showErrorToast(context, 'Payment intent error: $e');
                }
              },
              text: "Proceed to Payment",
              color: AppColors.deepBlue,
              textStyle: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
