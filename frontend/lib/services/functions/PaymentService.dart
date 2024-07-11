import 'dart:convert';
import 'dart:developer';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  Future<Map<String, dynamic>> createPaymentIntent(String userId, String courseId) async {
    final url = '${AppConstants.TRANSACTION_API}/createPaymentIntent';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'courseId': courseId}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create payment intent: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> confirmPayment(String paymentIntentId) async {
    final url = '${AppConstants.TRANSACTION_API}/confirmPayment';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'paymentIntentId': paymentIntentId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      log('Error confirming payment: ${response.body}');
      throw Exception('Failed to confirm payment: ${response.body}');
    }
  }
}
