import 'dart:convert';
import 'dart:io'; // ✅ Handles network errors
import 'dart:async'; // ✅ Fixes TimeoutException
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = "https://nestly.onrender.com"; // ✅ Backend URL

  // ✅ Login API Call
  static Future<String> loginUser(String email, String password) async {
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
        print("✅ Login Successful!");
        return "success";
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        print("❌ Login Failed: $errorMessage");
        return errorMessage;
      }
    } catch (error) {
      print("🔥 Error during API call: $error");
      return _handleNetworkError(error);
    }
  }

  // ✅ Register API Call
  static Future<String> registerUser(String firstName, String lastName, String email, String password, String dob) async {
    final Uri url = Uri.parse("$apiUrl/register");

    print("🟡 Sending register request to: $url with email: $email");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "password": password,
          "dob": dob
        }),
      ).timeout(const Duration(seconds: 10));

      print("🔵 API Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 201) {
        print("✅ Registration Successful!");
        return "success";
      } else {
        final errorMessage = jsonDecode(response.body)['message'];
        print("❌ Registration Failed: $errorMessage");
        return errorMessage;
      }
    } catch (error) {
      print("🔥 Error during API call: $error");
      return _handleNetworkError(error);
    }
  }

  // ✅ Fetch Guards
  static Future<List<Map<String, dynamic>>> fetchGuards() async {
    final Uri url = Uri.parse("$apiUrl/guards");

    print("🟡 Fetching guards from: $url");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print("✅ Guards fetched successfully!");
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception("❌ Failed to fetch guards");
      }
    } catch (error) {
      print("🔥 Error fetching guards: $error");
      return [];
    }
  }

  // ✅ Fetch Visitors
  static Future<List<Map<String, dynamic>>> fetchVisitors() async {
    final Uri url = Uri.parse("$apiUrl/visitors");

    print("🟡 Fetching visitors from: $url");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print("✅ Visitors fetched successfully!");
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception("❌ Failed to fetch visitors");
      }
    } catch (error) {
      print("🔥 Error fetching visitors: $error");
      return [];
    }
  }

  // ✅ Add Visitor
  static Future<String> addVisitor(String name, String relation, String reason) async {
    final Uri url = Uri.parse("$apiUrl/visitors");

    print("🟡 Adding visitor: $name");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "relation": relation, "reason": reason}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        print("✅ Visitor added successfully!");
        return "success";
      } else {
        return jsonDecode(response.body)['message'];
      }
    } catch (error) {
      print("🔥 Error adding visitor: $error");
      return _handleNetworkError(error);
    }
  }

  // ✅ Delete Visitor
  static Future<String> deleteVisitor(int id) async {
    final Uri url = Uri.parse("$apiUrl/visitors/$id");

    print("🟡 Deleting visitor with ID: $id");

    try {
      final response = await http.delete(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print("✅ Visitor deleted successfully!");
        return "success";
      } else {
        return jsonDecode(response.body)['message'];
      }
    } catch (error) {
      print("🔥 Error deleting visitor: $error");
      return _handleNetworkError(error);
    }
  }

  // ✅ Fetch My Visitors
  static Future<List<Map<String, dynamic>>> fetchMyVisitors() async {
  final Uri url = Uri.parse("$apiUrl/myvisitors");

  print("🟡 Fetching my visitors from: $url");

  try {
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    print("🔵 API Response Code: ${response.statusCode}");
    print("🔵 API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(jsonDecode(response.body));

      if (data.isEmpty) {
        print("❌ No visitors found in the database.");
      } else {
        print("✅ My Visitors fetched successfully!");
      }

      return data;
    } else {
      print("❌ Failed to fetch my visitors. Status Code: ${response.statusCode}");
      return [];
    }
  } catch (error) {
    print("🔥 Error fetching my visitors: $error");
    return [];
  }
}


  // ✅ Add My Visitor
  static Future<String> addMyVisitor(String name, String category) async {
    final Uri url = Uri.parse("$apiUrl/myvisitors");

    print("🟡 Adding my visitor: $name");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "category": category}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        print("✅ My Visitor added successfully!");
        return "success";
      } else {
        return jsonDecode(response.body)['message'];
      }
    } catch (error) {
      print("🔥 Error adding my visitor: $error");
      return _handleNetworkError(error);
    }
  }

  // ✅ Delete My Visitor
  static Future<String> deleteMyVisitor(int id) async {
    final Uri url = Uri.parse("$apiUrl/myvisitors/$id");

    print("🟡 Deleting my visitor with ID: $id");

    try {
      final response = await http.delete(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print("✅ My Visitor deleted successfully!");
        return "success";
      } else {
        return jsonDecode(response.body)['message'];
      }
    } catch (error) {
      print("🔥 Error deleting my visitor: $error");
      return _handleNetworkError(error);
    }
  }

  // ✅ Handle Network Errors
  static String _handleNetworkError(dynamic error) {
    if (error is SocketException) {
      print("❌ No internet connection or server is down.");
      return "❌ Server not reachable. Check Render status.";
    } else if (error is TimeoutException) {
      print("❌ Request timed out.");
      return "❌ Network timeout. Check internet connection.";
    } else if (error is HttpException) {
      print("❌ HTTP error: ${error.message}");
      return "❌ HTTP error occurred.";
    } else {
      print("❌ Unknown error: $error");
      return "❌ Network error. Check internet & try again.";
    }
  }
}

