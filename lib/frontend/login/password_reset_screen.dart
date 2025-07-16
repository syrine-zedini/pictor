import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../backendApi/client/api-user.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _codeSent = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  String? _successMessage;

  Future<void> _sendResetCode() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Generate a random 6-digit code
      final code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
      
      final success = await ApiService.mobilePasswordReset(
        _emailController.text.trim(),
        code,
      );

      if (success) {
        setState(() {
          _isLoading = false;
          _codeSent = true;
          _successMessage = 'Reset code sent to your email. Please check your inbox.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Email not found. Please check your email address.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ApiService.resetPassword({
        'email': _emailController.text.trim(),
        'code': _codeController.text.trim(),
        'newPassword': _newPasswordController.text,
      });

      setState(() {
        _isLoading = false;
        _successMessage = 'Password reset successfully! You can now login with your new password.';
      });

      // Navigate back to login after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              FadeInDown(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reset Password',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enter your email to receive a reset code',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                FadeIn(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (_successMessage != null) ...[
                const SizedBox(height: 20),
                FadeIn(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),
              
              // Email field
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: TextFormField(
                  controller: _emailController,
                  enabled: !_codeSent,
                  decoration: const InputDecoration(
                    labelText: '📧 Email Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Send Code Button
              if (!_codeSent) ...[
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendResetCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Send Reset Code',
                              style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ],

              // Code and Password fields (shown after code is sent)
              if (_codeSent) ...[
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: '🔢 Reset Code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) => value!.isEmpty ? 'Reset code is required' : null,
                  ),
                ),

                const SizedBox(height: 20),

                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: TextFormField(
                    controller: _newPasswordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: '🔐 New Password',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'New password is required';
                      if (value.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_confirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: '🔐 Confirm Password',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) => value!.isEmpty ? 'Please confirm your password' : null,
                  ),
                ),

                const SizedBox(height: 30),

                FadeInUp(
                  delay: const Duration(milliseconds: 700),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Reset Password',
                              style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
} 