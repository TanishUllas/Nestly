import 'package:flutter/material.dart';
import 'package:nestly/services/api_service.dart'; // ✅ Import API service

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false; // ✅ State for "Remember Me" checkbox
  bool isLoading = false; // ✅ Loading state to disable button

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

    print("🟡 Attempting login for: $email"); // ✅ Debugging

    try {
      String response = await ApiService.loginUser(email, password);
      print("🟢 API Response: $response"); // ✅ Debugging API response

      if (response == "success") {
        _showMessage("✅ Login Successful!", success: true);
        Navigator.pushNamed(context, '/home_dashboard');
      } else {
        _showMessage(response);
      }
    } catch (error) {
      print("🔥 Error during login: $error"); // ✅ Debugging errors
      _showMessage("❌ Login failed. Check console for details.");
    } finally {
      setState(() {
        isLoading = false; // ✅ Hide loading state
      });
    }
  }

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
                ElevatedButton(
                  onPressed: isLoading ? null : _login, // ✅ Disable when loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.lightBlue[100]) // ✅ Show loading
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
