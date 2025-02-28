import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = "https://nestly.onrender.com"; // ✅ Backend URL

  // ✅ Login API Call
  static Future<String> loginUser(String email, String password) async {
    final Uri url = Uri.parse("$apiUrl/login");

    print("🟡 Sending login request to: $url with email: $email"); // ✅ Debugging

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("🔵 Raw API Response: ${response.body}"); // ✅ Debugging API response

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token']; // ✅ Extract JWT token
        print("✅ Login Successful! Token: $token");

        return "success";
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        print("❌ Login Failed: $errorMessage");
        return errorMessage;
      }
    } catch (error) {
      print("🔥 Error during API call: $error");
      return "❌ Network error. Check internet & try again.";
    }
  }
}
