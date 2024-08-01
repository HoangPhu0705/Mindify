import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:frontend/services/functions/PaymentService.dart';
import 'package:frontend/services/models/course.dart';
import 'package:frontend/utils/colors.dart';
import 'package:frontend/utils/spacing.dart';
import 'package:frontend/utils/toasts.dart';
import 'package:getwidget/getwidget.dart';
import 'package:frontend/utils/constants.dart';

class PaymentPage extends StatefulWidget {
  final String userId;
  final String courseId;
  final Course course;
  final int price;

  const PaymentPage({
    super.key,
    required this.userId,
    required this.courseId,
    required this.price,
    required this.course,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final paymentService = PaymentService();
  ScrollController scrollController = ScrollController();
  QuillController quillController = QuillController.basic();

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey = AppConstants.PUBLIC_KEY_STRIPE;
    Stripe.instance.applySettings();
    quillController.document = Document.fromJson(
      jsonDecode(widget.course.description),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: AppColors.ghostWhite,
        backgroundColor: AppColors.ghostWhite,
        centerTitle: true,
        title: const Text(
          'Purchase course',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.course.thumbnail,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            AppSpacing.mediumVertical,
            Text(
              widget.course.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.smallVertical,
            Text(
              'Instructor: ${widget.course.instructorName}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            AppSpacing.mediumVertical,
            const Text(
              'Description:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.smallVertical,
            _buildQuillEditor(
              quillController,
              scrollController,
            ),
            AppSpacing.mediumVertical,
            const Divider(),
            AppSpacing.mediumVertical,
            Text(
              'Price: ${widget.price}đ',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.mediumVertical,
            SizedBox(
              width: double.infinity,
              child: GFButton(
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
                          customerEphemeralKeySecret:
                              paymentInfo['ephemeralKey'],
                        ),
                      );

                      try {
                        await Stripe.instance.presentPaymentSheet();
                        Map<String, dynamic> confirmation =
                            await paymentService.confirmPayment(intentId);
                        showSuccessToast(context, 'Payment successful');
                        Navigator.pop(context, true);
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
                        showErrorToast(
                            context, 'Payment confirmation error: $e');
                      }
                    }
                  } catch (e) {
                    log('Payment intent error: $e');
                    showErrorToast(context, 'Payment intent error: $e');
                  }
                },
                text: "Proceed to Payment",
                color: AppColors.deepBlue,
                textStyle: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuillEditor(
      QuillController controller, ScrollController scrollController) {
    return Container(
      // width: double.infinity,
      // height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.ghostWhite,
        borderRadius: BorderRadius.circular(5),
      ),
      child: quill.QuillEditor.basic(
        focusNode: FocusNode(canRequestFocus: false),
        scrollController: scrollController,
        configurations: QuillEditorConfigurations(
          controller: controller,
          scrollPhysics: const NeverScrollableScrollPhysics(),
          autoFocus: false,
          scrollable: true,
          showCursor: false,
          sharedConfigurations: const QuillSharedConfigurations(
            locale: Locale('en'),
          ),
        ),
      ),
    );
  }
}
