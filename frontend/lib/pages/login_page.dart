import 'package:flutter/material.dart';
import 'package:nestly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false; // ✅ "Remember Me" state
  bool isLoading = false; // ✅ Loading state

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  // ✅ Load saved email if "Remember Me" was checked
  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString("savedEmail");
    bool savedRememberMe = prefs.getBool("rememberMe") ?? false;

    if (savedEmail != null && savedRememberMe) {
      setState(() {
        emailController.text = savedEmail;
        rememberMe = savedRememberMe;
      });
    }
  }

  // ✅ Handle Login Process
  void _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("❌ Please enter email and password.");
      return;
    }

    setState(() {
      isLoading = true; // ✅ Show loading state
    });

    print("🟡 Attempting login for: $email");

    try {
      final response = await ApiService.loginUser(email, password);

      if (response.containsKey("error")) {
        _showMessage(response["error"] ?? "❌ Unexpected error.");
      } else {
        final user = response["user"] ?? {};
        final String? token = response["token"];

        if (user.isNotEmpty && token != null) {
          final int userId = user["id"] ?? 0;

          if (userId > 0) {
            // ✅ Save userId & token
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt("userId", userId);
            await prefs.setString("token", token);

            // ✅ Save email if "Remember Me" is checked
            if (rememberMe) {
              await prefs.setString("savedEmail", email);
              await prefs.setBool("rememberMe", true);
            } else {
              await prefs.remove("savedEmail");
              await prefs.setBool("rememberMe", false);
            }

            _showMessage("✅ Login Successful!", success: true);

            // ✅ Navigate to HomeDashboard with `userId`
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home_dashboard',
              arguments: userId,
              (route) => false, // Clears navigation stack
            );
          } else {
            _showMessage("❌ Invalid user data. Please try again.");
          }
        } else {
          _showMessage("❌ Server error. Try again.");
        }
      }
    } catch (error) {
      print("🔥 Error during login: $error");
      _showMessage("❌ Login failed. Check console for details.");
    } finally {
      setState(() {
        isLoading = false; // ✅ Hide loading state
      });
    }
  }

  // ✅ Show Snackbar Message
  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[100],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blueGrey[800]),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.lightBlue[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'LOGIN',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Kindly login to continue.',
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),

                // ✅ Email Input Field
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: Colors.blueGrey[800]),
                    labelText: 'Email...',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // ✅ Password Input Field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.fingerprint, color: Colors.blueGrey[800]),
                    labelText: 'Password...',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // ✅ "Remember Me" Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                    ),
                    Text(
                      'Remember me',
                      style: TextStyle(color: Colors.blueGrey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // ✅ Login Button
                ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.lightBlue[100])
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.lightBlue[100],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.lightBlue[100],
                            ),
                          ],
                        ),
                ),
                SizedBox(height: 16),

                // ✅ Navigate to Registration Page
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text(
                    "Don't have an account? Sign-Up",
                    style: TextStyle(color: Colors.blueGrey[700]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
