import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SOSPage extends StatefulWidget {
  final int userId; // ✅ Require userId

  const SOSPage({super.key, required this.userId});

  @override
  _SOSPageState createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  String reporterName = "Anonymous"; // ✅ Default Name
  bool isSending = false; // ✅ Loading Indicator
  bool isLoading = true; // ✅ Track if user data is still loading

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // ✅ Fetch user's name automatically
  }

  // ✅ Fetch User's Name from the Server
  Future<void> _fetchUserName() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print("❌ No token found!");
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://localhost:5001/users/${widget.userId}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // ✅ Send JWT token
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          reporterName = userData['firstname'] ?? "Anonymous"; // ✅ Autofill name
          isLoading = false;
        });
      } else {
        print("❌ Failed to fetch user name: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (error) {
      print("🔥 Error fetching user name: $error");
      setState(() => isLoading = false);
    }
  }

  // ✅ Send SOS Email
  Future<void> sendEmail(String subject, String message) async {
    if (isSending || isLoading) return; // ✅ Prevent sending if name is still loading

    setState(() {
      isSending = true;
    });

    final url = Uri.parse("http://localhost:5001/send-email");

    String emailMessage = "**Reported by: $reporterName**\n\n$message"; // ✅ Include name

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "subject": subject,
          "message": emailMessage,
        }),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      // ✅ Show Success Message
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ SOS alert sent successfully!"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to send SOS alert"), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      print("🔥 Error sending email: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error sending email!"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: const Text('SOS', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.lightBlue[100],
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ✅ SOS Icon
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.red[700],
              child: const Text(
                'SOS',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ✅ **Larger SOS Buttons in Grid Layout**
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: SOSButton(
                            label: 'Medical Emergency',
                            icon: Icons.local_hospital,
                            color: Colors.blueGrey[700],
                            isSending: isSending || isLoading,
                            onPressed: () => sendEmail("Medical Emergency", "A medical emergency has been reported."),
                          ),
                        ),
                        const SizedBox(width: 20), // Space between buttons
                        Expanded(
                          child: SOSButton(
                            label: 'Fire/Gas Leak Emergency',
                            icon: Icons.fire_extinguisher,
                            color: Colors.blue[400],
                            isSending: isSending || isLoading,
                            onPressed: () => sendEmail("Fire/Gas Leak Emergency", "Fire or gas leak emergency reported."),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // Space between rows
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: SOSButton(
                            label: 'Lift Emergency',
                            icon: Icons.elevator,
                            color: Colors.blueGrey[600],
                            isSending: isSending || isLoading,
                            onPressed: () => sendEmail("Lift Emergency", "Someone is stuck in the lift."),
                          ),
                        ),
                        const SizedBox(width: 20), // Space between buttons
                        Expanded(
                          child: SOSButton(
                            label: 'Theft/Others',
                            icon: Icons.help_outline,
                            color: Colors.blueGrey[400],
                            isSending: isSending || isLoading,
                            onPressed: () => sendEmail("Security Alert", "A security concern has been reported."),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ **Reusable SOS Button Widget (Now Bigger)**
class SOSButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final bool isSending;
  final VoidCallback onPressed;

  const SOSButton({
    super.key,
    required this.label,
    required this.icon,
    this.color,
    required this.isSending,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180, // ✅ Increased height for full-screen usage
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: isSending ? null : onPressed, // ✅ Disable if sending
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isSending
                ? const CircularProgressIndicator(color: Colors.white) // ✅ Show loading
                : Icon(icon, size: 60, color: Colors.white), // ✅ Bigger icon
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 20), // ✅ Bigger text
            ),
          ],
        ),
      ),
    );
  }
}
