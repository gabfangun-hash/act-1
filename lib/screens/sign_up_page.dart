// lib/screens/sign_up_page.dart
import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../services/auth_service.dart';
import 'dashboard_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _attemptSignUp() async {
    final name = _name.text.trim();
    final username = _username.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    final confirmPassword = _confirmPassword.text;

    if (name.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields.');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match.');
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Password must be at least 6 characters.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _authService.signUpWithEmail(
        name: name,
        username: username,
        email: email,
        password: password,
      );

      if (success) {
        _showSnackBar('Account created successfully! Please sign in.');
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/signin');
        });
      }
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = 160.0;
    final horizontalPadding = 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HeaderWidget(height: headerHeight, title: 'Remindly', showTitle: true),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 18),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(height: 6),
                                  Text(
                                    'Sign Up',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black87),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Create your account to get started',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black54, fontSize: 14),
                                  ),
                                  SizedBox(height: 24),

                                  // Name field
                                  _buildTextField(
                                    controller: _name,
                                    hint: 'John Doe',
                                    label: 'Full Name',
                                  ),
                                  SizedBox(height: 16),

                                  // Username field
                                  _buildTextField(
                                    controller: _username,
                                    hint: 'johndoe',
                                    label: 'Username',
                                  ),
                                  SizedBox(height: 16),

                                  // Email field
                                  _buildTextField(
                                    controller: _email,
                                    hint: 'john@email.com',
                                    label: 'Email',
                                  ),
                                  SizedBox(height: 16),

                                  // Password field
                                  _buildTextField(
                                    controller: _password,
                                    hint: '••••••••••',
                                    label: 'Password',
                                    obscure: true,
                                  ),
                                  SizedBox(height: 16),

                                  // Confirm Password field
                                  _buildTextField(
                                    controller: _confirmPassword,
                                    hint: '••••••••••',
                                    label: 'Confirm Password',
                                    obscure: true,
                                  ),
                                  SizedBox(height: 24),

                                  // Sign Up button
                                  SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF90CDFD),
                                        foregroundColor: Colors.black87,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: _isLoading ? null : _attemptSignUp,
                                      child: _isLoading
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : Text('Sign Up', style: TextStyle(fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),

                              Column(
                                children: [
                                  SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(context, '/signin');
                                    },
                                    child: Text(
                                      "Already have an account? Sign In",
                                      style: TextStyle(color: Color(0xFF6B46C1)),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? label,
    bool obscure = false,
  }) {
    final borderRadius = BorderRadius.circular(10.0);
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Color(0xFF2E7CE6), width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
    );
  }
}