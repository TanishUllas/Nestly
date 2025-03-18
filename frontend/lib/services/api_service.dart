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
          final int userId = responseData["user"]["id"]; // ✅ Ensure correct ID

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

  // ✅ Fetch User Profile (Uses Token for Authentication)
  static Future<Map<String, dynamic>> fetchUser(int userId) async {
    final Uri url = Uri.parse("$apiUrl/users/$userId");
    final String? token = await _getToken();

    if (token == null) {
      print("❌ No token found, cannot fetch user");
      return {"error": "Unauthorized"};
    }

    print("🟡 Fetching user profile from: $url");

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10));

      print("🔵 API Response: ${response.statusCode} ${response.body}");

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

  // ✅ Update User Profile
  static Future<Map<String, dynamic>> updateUser(
      int userId, String firstName, String lastName, String email, String dob, [String? password]) async {
    final Uri url = Uri.parse("$apiUrl/users/$userId");
    final String? token = await _getToken();

    print("🟡 Updating user profile: ID=$userId");

    final body = {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "dob": dob,
    };
    if (password != null && password.isNotEmpty) {
      body["password"] = password;
    }

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      print("🔵 API Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": _extractErrorMessage(response.body)};
      }
    } catch (error) {
      print("🔥 Error updating user: $error");
      return {"error": _handleNetworkError(error)};
    }
  }

  // ✅ Fetch Guards
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

  // ✅ Fetch My Visitors (Based on User ID)
  static Future<List<Map<String, dynamic>>> fetchMyVisitors(int userId) async {
    final Uri url = Uri.parse("$apiUrl/myvisitors/user/$userId");
    final String? token = await _getToken();

    if (token == null) {
      print("❌ No token found, returning empty list");
      return [];
    }

    print("🟡 Fetching visitors for userId: $userId from: $url");

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10));

      print("🔵 API Response: ${response.statusCode}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        print("❌ No visitors found for this user");
        return [];
      } else {
        print("❌ Unexpected error: ${response.body}");
        return [];
      }
    } catch (error) {
      print("🔥 Error fetching visitors: $error");
      return [];
    }
  }

  // ✅ Delete a visitor
  static Future<bool> deleteVisitor(int visitorId) async {
  final Uri url = Uri.parse("$apiUrl/myvisitors/$visitorId");
  final String? token = await _getToken();

  if (token == null) {
    print("❌ No token found");
    return false;
  }

  try {
    final response = await http.delete(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    print("🔵 Delete Response: ${response.statusCode}");

    if (response.statusCode == 200) {
      return true;
    } else {
      print("❌ Failed to delete visitor: ${response.body}");
      return false;
    }
  } catch (error) {
    print("🔥 Error deleting visitor: $error");
    return false;
  }
}

// ✅ Fetch visitors who arrived in the last 10 minutes
static Future<List<Map<String, dynamic>>> fetchRecentVisitors(int userId) async {
  final Uri url = Uri.parse("$apiUrl/visitors/recent/$userId");
  final String? token = await _getToken();

  try {
    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      
      // Ensure data is a list of maps
      if (jsonData is List) {
        return jsonData.cast<Map<String, dynamic>>();
      } else {
        print("🚨 Unexpected response format: $jsonData");
        return [];
      }
    } else {
      print("❌ Failed to fetch visitors: ${response.statusCode} - ${response.body}");
      return [];
    }
  } catch (error) {
    print("🔥 Error fetching recent visitors: $error");
    return [];
  }
}

static Future<bool> updateVisitorStatus(int visitorId, String status) async {
  final Uri url = Uri.parse("$apiUrl/visitors/$visitorId/status");
  final String? token = await _getToken();

  if (token == null) {
    print("❌ No token found.");
    return false;
  }

  try {
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      body: jsonEncode({"status": status}), // ✅ Only updating status
    );

    print("🔵 API Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      print("✅ Visitor status updated to $status successfully");
      return true; // ✅ Just return true, don't trigger extra logic
    } else {
      print("❌ Failed to update visitor status: ${response.body}");
      return false;
    }
  } catch (error) {
    print("🔥 Error updating visitor status: $error");
    return false;
  }
}

  // ✅ Add Visitor to My Visitors
  static Future<bool> addToMyVisitors(int userId, String name, String category) async {
    final Uri url = Uri.parse("$apiUrl/myvisitors/add");
    final String? token = await _getToken();
    if (token == null) return false;
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
        body: jsonEncode({"user_id": userId, "name": name, "category": category}),
      );
      return response.statusCode == 200;
    } catch (error) {
      return false;
    }
  }

  // ✅ Normalize Date Format (YYYY-MM-DD)
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "";
    return dateString.split("T")[0]; // Removes time part
  }

  // ✅ Get User ID from SharedPreferences
  static Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId") ?? 0; // ✅ Return userId or 0 if not found
  }

  // ✅ Get Token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
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
