import 'dart:convert';
import 'dart:io'; // ✅ Handles network errors
import 'dart:async'; // ✅ Fixes TimeoutException
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = "https://nestly.onrender.com"; // ✅ Backend URL

  // ✅ Login API Call with detailed debugging & retry mechanism
  static Future<String> loginUser(String email, String password) async {
    final Uri url = Uri.parse("$apiUrl/login");

    print("🟡 Sending login request to: $url with email: $email");

    int retryCount = 0;
    while (retryCount < 2) { // ✅ Retry up to 2 times if failure
      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"email": email, "password": password}),
        ).timeout(Duration(seconds: 10)); // ✅ Timeout after 10 seconds

        print("🔵 Raw API Response: ${response.statusCode} ${response.body}");

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

        if (error is SocketException) {
          print("❌ No internet connection or server is down.");
          return "❌ Server not reachable. Check Render status.";
        } else if (error is TimeoutException) {
          print("❌ Request timed out.");
          return "❌ Network timeout. Check internet connection.";
        } else {
          print("❌ Unknown error: $error");
          return "❌ Network error. Check internet & try again.";
        }
      }

      retryCount++;
      print("🔄 Retrying login... Attempt: $retryCount");
      await Future.delayed(Duration(seconds: 2)); // ✅ Wait before retrying
    }

    return "❌ Login failed after multiple attempts.";
  }
}
