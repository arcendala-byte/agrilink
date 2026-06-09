import 'package:http/http.dart' as http;
import 'dart:convert';

class MpesaService {
  // Sandbox credentials (replace with your actual credentials)
  static const String consumerKey = 'YOUR_CONSUMER_KEY';
  static const String consumerSecret = 'YOUR_CONSUMER_SECRET';
  static const String passkey = 'YOUR_PASSKEY';
  static const String shortCode = '174379';
  
  Future<String?> getAccessToken() async {
    try {
      String credentials = base64.encode(utf8.encode('$consumerKey:$consumerSecret'));
      
      final response = await http.post(
        Uri.parse('https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials'),
        headers: {
          'Authorization': 'Basic $credentials',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      }
      return null;
    } catch (e) {
      print('M-Pesa error: $e');
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> initiateStkPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
  }) async {
    try {
      final token = await getAccessToken();
      if (token == null) return null;
      
      String timestamp = DateTime.now().toIso8601String();
      String password = base64.encode(utf8.encode('$shortCode$passkey$timestamp'));
      
      final response = await http.post(
        Uri.parse('https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'BusinessShortCode': shortCode,
          'Password': password,
          'Timestamp': timestamp,
          'TransactionType': 'CustomerPayBillOnline',
          'Amount': amount.toInt(),
          'PartyA': phoneNumber,
          'PartyB': shortCode,
          'PhoneNumber': phoneNumber,
          'CallBackURL': 'https://your-domain.com/mpesa-callback',
          'AccountReference': accountReference,
          'TransactionDesc': 'AgriLink Payment',
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('STK Push error: $e');
      return null;
    }
  }
}
