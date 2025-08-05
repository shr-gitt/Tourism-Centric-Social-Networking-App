import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:frontend/pages/Service/usersettings_apiservice.dart';
import 'package:frontend/pages/Userpages/change_password.dart';
import 'package:frontend/pages/Userpages/profile.dart';
import 'package:frontend/pages/Userpages/phone_management.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> with SingleTickerProviderStateMixin {
  final UserService _userService = UserService();
  final UsersettingsApiservice _settings = UsersettingsApiservice();
  Map<String, dynamic>? settings;

  bool isLoading = true;
  String? error;
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
    _loadSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => isLoading = true);
    final token = await AuthStorage.getToken();
    log('Token used for settings request: $token');

    final result = await _userService.getUserSettings();
    setState(() {
      settings = result;
      isLoading = false;
      error = result == null ? 'Failed to load settings' : null;
    });
  }

  Future<void> _handleAction(
    Future<bool> Function() action,
    String successMsg,
  ) async {
    final result = await action();
    if (result) {
      _showSnackBar(successMsg);
      await _loadSettings(); // Refresh settings
    } else {
      _showSnackBar('Action failed');
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    bool showArrow = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.blue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? Colors.blue.shade600,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: showArrow
            ? Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              )
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.blue.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not set' : value,
                  style: TextStyle(
                    fontSize: 16,
                    color: value.isEmpty ? Colors.grey.shade400 : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                error!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadSettings,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 24),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const Profile()),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    const Expanded(
                      child: Text(
                        'Account Settings',
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
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account Information Section
                      Text(
                        'Account Information',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildInfoCard(
                        title: 'Username',
                        value: settings?['userName'] ?? '',
                        icon: Icons.person_outline,
                      ),
                      
                      _buildInfoCard(
                        title: 'Email Address',
                        value: settings?['email'] ?? '',
                        icon: Icons.email_outlined,
                      ),
                      
                      _buildInfoCard(
                        title: 'Phone Number',
                        value: settings?['phoneNumber'] ?? '',
                        icon: Icons.phone_outlined,
                      ),

                      const SizedBox(height: 32),

                      // Security Section
                      Text(
                        'Security',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildSettingCard(
                        title: 'Change Password',
                        subtitle: 'Update your account password',
                        icon: Icons.lock_outline,
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                        ),
                        iconColor: Colors.blue.shade600,
                      ),

                      _buildSettingCard(
                        title: 'Two-Factor Authentication',
                        subtitle: settings?['twoFactorEnabled'] == true 
                            ? 'Enabled - Your account is protected'
                            : 'Disabled - Enhance your security',
                        icon: Icons.security_outlined,
                        onTap: () {
                          if (settings?['twoFactorEnabled'] == true) {
                            _handleAction(_settings.disableTwoFactor, '2FA disabled.');
                          } else {
                            _handleAction(_settings.enableTwoFactor, '2FA enabled.');
                          }
                        },
                        iconColor: settings?['twoFactorEnabled'] == true 
                            ? Colors.green.shade600 
                            : Colors.orange.shade600,
                      ),

                      _buildSettingCard(
                        title: 'Reset Authenticator Key',
                        subtitle: 'Generate a new authenticator key',
                        icon: Icons.vpn_key_outlined,
                        onTap: () => _handleAction(_settings.resetAuthenticatorKey, 'Authenticator key reset.'),
                        iconColor: Colors.purple.shade600,
                      ),

                      _buildSettingCard(
                        title: 'Recovery Codes',
                        subtitle: 'Generate backup codes for 2FA',
                        icon: Icons.backup_outlined,
                        onTap: () async {
                          final codes = await _settings.generateRecoveryCodes();
                          if (codes != null && codes.isNotEmpty) {
                            _showRecoveryDialog(codes);
                          } else {
                            _showSnackBar('Failed to generate recovery codes.', isError: true);
                          }
                        },
                        iconColor: Colors.indigo.shade600,
                      ),

                      const SizedBox(height: 32),

                      // Phone Management Section
                      Text(
                        'Phone Management',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (settings?['phoneNumber'] == null || settings!['phoneNumber'].isEmpty) ...[
                        _buildSettingCard(
                          title: 'Add Phone Number',
                          subtitle: 'Add a phone number for enhanced security',
                          icon: Icons.phone_outlined,
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const PhoneManagementPage()),
                          ),
                          iconColor: Colors.green.shade600,
                        ),
                      ] else ...[
                        _buildSettingCard(
                          title: 'Remove Phone Number',
                          subtitle: 'Remove ${settings!['phoneNumber']} from your account',
                          icon: Icons.phone_disabled_outlined,
                          onTap: () => _handleAction(_settings.removePhone, 'Phone number removed.'),
                          iconColor: Colors.red.shade600,
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _showRecoveryDialog(List<String> codes) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.backup_outlined,
                color: Colors.green.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Recovery Codes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Save these codes in a safe place. You can use them to access your account if you lose your authenticator device.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: codes.map((code) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          code,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Got it',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
