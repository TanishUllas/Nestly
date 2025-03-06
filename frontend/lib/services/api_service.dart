import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String apiUrl = "https://nestly.onrender.com"; // ✅ Backend URL

  // ✅ Login API Call (Extracts User ID from JWT Token)
  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final Uri url = Uri.parse("$apiUrl/login");
    print("🟡 Sending login request to: $url with email: $email");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(const Duration(seconds: 10));

      print("🔵 API Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey("token")) {
          final String token = responseData["token"];
          final int userId = _extractUserIdFromToken(token);

          // ✅ Store token & userId
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt("userId", userId);
          await prefs.setString("token", token);

          return {"user": {"id": userId}, "token": token};
        } else {
          return {"error": "Invalid response from server."};
        }
      } else {
        return {"error": _extractErrorMessage(response.body)};
      }
    } catch (error) {
      print("🔥 Error during login: $error");
      return {"error": _handleNetworkError(error)};
    }
  }

  // ✅ Fetch Guards (No Authentication Required)
  static Future<List<Map<String, dynamic>>> fetchGuards() async {
    final Uri url = Uri.parse("$apiUrl/guards");
    print("🟡 Fetching guards from: $url");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      print("🔵 API Response: ${response.statusCode}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        return [];
      }
    } catch (error) {
      print("🔥 Error fetching guards: $error");
      return [];
    }
  }

  // ✅ Fetch My Visitors (Requires Authentication)
  static Future<List<Map<String, dynamic>>> fetchMyVisitors() async {
    final Uri url = Uri.parse("$apiUrl/myvisitors");
    final String? token = await _getToken();

    if (token == null) {
      return [];
    }

    print("🟡 Fetching my visitors from: $url");

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10));

      print("🔵 API Response: ${response.statusCode}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        return [];
      }
    } catch (error) {
      print("🔥 Error fetching my visitors: $error");
      return [];
    }
  }

  // ✅ Fetch User Profile (Requires Authentication)
  static Future<Map<String, dynamic>> fetchUser(int userId) async {
    final String? token = await _getToken();

    if (token == null) {
      return {"error": "Unauthorized: No token found"};
    }

    final Uri url = Uri.parse("$apiUrl/users/$userId");
    print("🟡 Fetching user profile: ID=$userId");

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10));

      print("🔵 API Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": _extractErrorMessage(response.body)};
      }
    } catch (error) {
      print("🔥 Error fetching user: $error");
      return {"error": _handleNetworkError(error)};
    }
  }

  // ✅ Extract User ID from JWT Token
  static int _extractUserIdFromToken(String token) {
    try {
      final parts = token.split(".");
      if (parts.length != 3) return 0;

      final payload = jsonDecode(utf8.decode(base64Url.decode(_normalizeBase64(parts[1]))));
      print("🔍 Decoded JWT Payload: $payload"); // ✅ Debugging

      return payload["id"] ?? 0;
    } catch (e) {
      print("❌ Error decoding token: $e");
      return 0;
    }
  }

  // ✅ Normalize Base64 (Fixes Padding Issues)
  static String _normalizeBase64(String base64String) {
    while (base64String.length % 4 != 0) {
      base64String += "=";
    }
    return base64String;
  }

  // ✅ Get Token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ✅ Get User ID from SharedPreferences
  static Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId") ?? 0;
  }

  // ✅ Extract Error Message from Response
  static String _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      return decoded['message'] ?? "Unknown error";
    } catch (e) {
      return "Unknown error occurred.";
    }
  }

  // ✅ Handle Network Errors
  static String _handleNetworkError(dynamic error) {
    if (error is SocketException) {
      return "❌ Server not reachable. Check internet.";
    } else if (error is TimeoutException) {
      return "❌ Request timed out.";
    } else if (error is HttpException) {
      return "❌ HTTP error occurred.";
    } else if (error is FormatException) {
      return "❌ Invalid server response.";
    } else {
      return "❌ Network error.";
    }
  }
}
