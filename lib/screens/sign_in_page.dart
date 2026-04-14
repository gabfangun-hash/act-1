// lib/screens/sign_in_page.dart
import 'package:flutter/material.dart';
import '../widgets/header_widget.dart';
import '../services/auth_service.dart';
import 'dashboard_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _attemptSignIn() async {
    final username = _username.text.trim();
    final password = _password.text;

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter username and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _authService.signInWithEmail(
        username: username,
        password: password,
      );

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
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
                                    'Sign In',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black87),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Sign in to continue to Remindly',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black54, fontSize: 14),
                                  ),
                                  SizedBox(height: 24),

                                  // Username field
                                  _buildTextField(
                                    controller: _username,
                                    hint: 'johndoe',
                                    label: 'Username',
                                  ),
                                  SizedBox(height: 16),

                                  // Password field
                                  _buildTextField(
                                    controller: _password,
                                    hint: '••••••••••',
                                    label: 'Password',
                                    obscure: true,
                                  ),
                                  SizedBox(height: 8),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        _showForgotPasswordDialog();
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size(0, 0),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text('Forgot Password?', style: TextStyle(color: Color(0xFF2E7CE6))),
                                    ),
                                  ),
                                  SizedBox(height: 12),

                                  // Sign In button
                                  SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF90CDFD),
                                        foregroundColor: Colors.black87,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: _isLoading ? null : _attemptSignIn,
                                      child: _isLoading
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : Text('Sign In', style: TextStyle(fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),

                              Column(
                                children: [
                                  SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(context, '/signup');
                                    },
                                    child: Text(
                                      "Don't have an account? Sign Up",
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

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    final otpController = TextEditingController();
    final passwordController = TextEditingController();
    int step = 1; // 1: Email, 2: OTP, 3: New Password

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(step == 1 ? 'Reset Password' : step == 2 ? 'Enter OTP' : 'New Password'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (step == 1) ...[
                      Text('Enter your email address'),
                      SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'your@email.com',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ] else if (step == 2) ...[
                      Text('Enter the OTP sent to your email'),
                      SizedBox(height: 16),
                      TextField(
                        controller: otpController,
                        decoration: InputDecoration(
                          hintText: '000000',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ] else ...[
                      Text('Enter your new password'),
                      SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '••••••••••',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (step == 1) {
                      if (emailController.text.isEmpty) {
                        _showSnackBar('Please enter your email');
                        return;
                      }

                      setState(() => _isLoading = true);
                      try {
                        await _authService.sendOtpForPasswordReset(
                          email: emailController.text,
                        );
                        setState(() => step = 2);
                        _showSnackBar('OTP sent to your email!');
                      } catch (e) {
                        _showSnackBar(e.toString().replaceAll('Exception: ', ''));
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    } else if (step == 2) {
                      if (otpController.text.isEmpty) {
                        _showSnackBar('Please enter OTP');
                        return;
                      }
                      setState(() => step = 3);
                    } else {
                      if (passwordController.text.isEmpty) {
                        _showSnackBar('Please enter new password');
                        return;
                      }

                      setState(() => _isLoading = true);
                      try {
                        await _authService.verifyOtpAndResetPassword(
                          email: emailController.text,
                          otp: otpController.text,
                          newPassword: passwordController.text,
                        );
                        Navigator.pop(context);
                        _showSnackBar('Password reset successful! Please sign in.');
                      } catch (e) {
                        _showSnackBar(e.toString().replaceAll('Exception: ', ''));
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  child: _isLoading
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                      : Text(step == 3 ? 'Reset Password' : 'Next'),
                ),
              ],
            );
          },
        );
      },
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