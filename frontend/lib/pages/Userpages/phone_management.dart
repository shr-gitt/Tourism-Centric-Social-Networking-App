import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/usersettings_apiservice.dart';
import 'package:frontend/pages/Userpages/user_settings_page.dart';

class PhoneManagementPage extends StatefulWidget {
  const PhoneManagementPage({super.key});

  @override
  State<PhoneManagementPage> createState() => _PhoneManagementPageState();
}

class _PhoneManagementPageState extends State<PhoneManagementPage>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _settings = UsersettingsApiservice();

  bool _isLoading = false;
  bool _codeSent = false;
  bool _phoneVerified = false;
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleAddPhone() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showMessage("Please enter your phone number", isError: true);
      return;
    }

    if (!_isValidPhone(phone)) {
      _showMessage("Please enter a valid phone number", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _settings.addPhone(phone);

      setState(() {
        _isLoading = false;
        _codeSent = success;
      });

      if (success) {
        _showMessage("Verification code sent to $phone", isError: false);
      } else {
        _showMessage("Failed to send verification code. Please try again.", isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage("An error occurred. Please try again.", isError: true);
    }
  }

  Future<void> _handleVerifyPhone() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      _showMessage("Please enter the verification code", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _settings.verifyPhone(phone, code);

      setState(() {
        _isLoading = false;
        _phoneVerified = success;
      });

      if (success) {
        _showMessage("Phone number verified successfully", isError: false);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserSettingsPage()),
            );
          }
        });
      } else {
        _showMessage("Invalid verification code. Please try again.", isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage("An error occurred. Please try again.", isError: true);
    }
  }

  bool _isValidPhone(String phone) {
    // Basic phone validation - you can make this more sophisticated
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
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
    TextInputType? keyboardType,
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
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(icon, color: Colors.grey),
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
                          MaterialPageRoute(builder: (_) => const UserSettingsPage()),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      const Expanded(
                        child: Text(
                          'Phone Number',
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
                        if (!_codeSent && !_phoneVerified) ...[
                          // Phone icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.phone_outlined,
                              size: 40,
                              color: Colors.green.shade600,
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Title
                          const Text(
                            'Add phone number',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Subtitle
                          Text(
                            'Enter your phone number to enhance your account security and enable two-factor authentication.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Phone input
                          _buildTextField(
                            controller: _phoneController,
                            hintText: 'Phone number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Add phone button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleAddPhone,
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
                                      'Send Verification Code',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ] else if (_codeSent && !_phoneVerified) ...[
                          // SMS icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.sms_outlined,
                              size: 40,
                              color: Colors.blue.shade600,
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Title
                          const Text(
                            'Verify your number',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Subtitle
                          Text(
                            'We\'ve sent a verification code to\n${_phoneController.text}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Code input
                          _buildTextField(
                            controller: _codeController,
                            hintText: 'Verification code',
                            icon: Icons.security_outlined,
                            keyboardType: TextInputType.number,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Verify button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleVerifyPhone,
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
                                      'Verify Phone Number',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Resend code
                          TextButton(
                            onPressed: _handleAddPhone,
                            child: Text(
                              'Didn\'t receive the code? Resend',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ] else if (_phoneVerified) ...[
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
                            'Phone verified!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          Text(
                            'Your phone number has been successfully verified and added to your account.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              height: 1.4,
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
                      MaterialPageRoute(builder: (_) => const UserSettingsPage()),
                    ),
                    child: Text(
                      _phoneVerified ? 'Continue' : 'Cancel',
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