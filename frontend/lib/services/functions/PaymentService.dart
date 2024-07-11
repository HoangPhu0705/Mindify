import 'dart:convert';
import 'package:frontend/utils/constants.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  // static const _baseUrl = 'YOUR_BACKEND_API_BASE_URL';

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
      throw Exception('Failed to create payment intent');
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
      throw Exception('Failed to confirm payment');
    }
  }
}
