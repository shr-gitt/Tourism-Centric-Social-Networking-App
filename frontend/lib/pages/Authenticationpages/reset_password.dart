import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/password_apiservice.dart';
import 'package:frontend/pages/Authenticationpages/login.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? email;
  final String? code;

  const ResetPasswordPage({
    super.key,
    this.email,
    this.code,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordApiService = PasswordApiservice();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _passwordReset = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Pre-fill email and code if provided
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }
    if (widget.code != null) {
      _codeController.text = widget.code!;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || code.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Please fill in all fields", isError: true);
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage("Please enter a valid email address", isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Passwords do not match", isError: true);
      return;
    }

    if (password.length < 6) {
      _showMessage("Password must be at least 6 characters long", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'Email': email,
        'Code': code,
        'Password': password,
      };

      final success = await _passwordApiService.resetPassword(data);
      
      setState(() {
        _isLoading = false;
        _passwordReset = success;
      });

      if (success) {
        _showMessage("Password reset successfully", isError: false);
      } else {
        _showMessage("Failed to reset password. Please check your reset code.", isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage("An error occurred. Please try again.", isError: true);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    bool? isPasswordVisible,
    VoidCallback? toggleVisibility,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText && !(isPasswordVisible ?? false),
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: toggleVisibility != null
              ? IconButton(
                  icon: Icon(
                    (isPasswordVisible ?? false) ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: toggleVisibility,
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 24),
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      const Expanded(
                        child: Text(
                          'Reset Password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_passwordReset) ...[
                          // Key icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.vpn_key_outlined,
                              size: 40,
                              color: Colors.blue.shade600,
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Title
                          const Text(
                            'Create new password',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Subtitle
                          Text(
                            'Enter your email, reset code, and new password to complete the reset process.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Email input
                          _buildTextField(
                            controller: _emailController,
                            hintText: 'Email address',
                            icon: Icons.email_outlined,
                          ),
                          
                          // Reset code input
                          _buildTextField(
                            controller: _codeController,
                            hintText: 'Reset code',
                            icon: Icons.code_outlined,
                          ),
                          
                          // New password input
                          _buildTextField(
                            controller: _passwordController,
                            hintText: 'New password',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            isPasswordVisible: _isPasswordVisible,
                            toggleVisibility: () {
                              setState(() => _isPasswordVisible = !_isPasswordVisible);
                            },
                          ),
                          
                          // Confirm password input
                          _buildTextField(
                            controller: _confirmPasswordController,
                            hintText: 'Confirm new password',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            isPasswordVisible: _isConfirmPasswordVisible,
                            toggleVisibility: () {
                              setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                            },
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Reset password button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleResetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Reset Password',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ] else ...[
                          // Success state
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_outline,
                              size: 40,
                              color: Colors.green.shade600,
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          const Text(
                            'Password reset successful',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          Text(
                            'Your password has been successfully reset. You can now sign in with your new password.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Sign in button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Bottom section
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
                    child: Text(
                      'Back to Sign In',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
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