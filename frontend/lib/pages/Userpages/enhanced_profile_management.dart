import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/enhanced_user_apiservice.dart';
import 'package:frontend/pages/Service/usersettings_apiservice.dart';
import 'package:frontend/pages/Userpages/password_management.dart';
import 'package:frontend/pages/Userpages/phone_verification_flow.dart';
import 'package:frontend/pages/Userpages/two_factor_auth_setup.dart';
import 'package:frontend/pages/Userpages/external_login_management.dart';
import 'package:frontend/pages/mainscreen.dart';

class EnhancedProfileManagementPage extends StatefulWidget {
  const EnhancedProfileManagementPage({super.key});

  @override
  State<EnhancedProfileManagementPage> createState() => _EnhancedProfileManagementPageState();
}

class _EnhancedProfileManagementPageState extends State<EnhancedProfileManagementPage> 
    with TickerProviderStateMixin {
  final EnhancedUserApiService _userService = EnhancedUserApiService();
  final UsersettingsApiservice _settingsService = UsersettingsApiservice();
  
  Map<String, dynamic>? _userSettings;
  bool _isLoading = true;
  String? _error;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _loadUserSettings();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final settings = await _userService.getCurrentUserProfile();
      setState(() {
        _userSettings = settings;
        _isLoading = false;
        _error = settings == null ? 'Failed to load user settings' : null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'An error occurred while loading settings';
      });
      log('Error loading user settings: $e');
    }
  }

  Future<void> _handleQuickAction(
    Future<bool> Function() action,
    String successMessage,
    String errorMessage,
  ) async {
    try {
      final result = await action();
      if (result) {
        _showSuccessSnackBar(successMessage);
        await _loadUserSettings(); // Refresh settings
      } else {
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred. Please try again.');
      log('Quick action error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile Settings'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserSettings,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => MainScreen(currentIndex: 4)),
                          ),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const Spacer(),
                        const Text(
                          'Profile Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: _loadUserSettings,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // Profile Header
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Settings',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage your account security and preferences',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Settings Content
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Account Information Section
                            _buildSectionHeader('Account Information'),
                            const SizedBox(height: 16),
                            
                            if (_userSettings != null) ...[
                              _buildInfoCard(
                                icon: Icons.person_outline,
                                title: 'Username',
                                subtitle: _userSettings!['userName'] ?? 'Not set',
                                color: const Color(0xFF667eea),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoCard(
                                icon: Icons.email_outlined,
                                title: 'Email',
                                subtitle: _userSettings!['email'] ?? 'Not set',
                                color: const Color(0xFF764ba2),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoCard(
                                icon: Icons.phone_outlined,
                                title: 'Phone Number',
                                subtitle: _userSettings!['phoneNumber'] ?? 'Not added',
                                color: const Color(0xFFf093fb),
                                trailing: _userSettings!['phoneNumber'] != null
                                    ? _buildQuickActionButton(
                                        icon: Icons.delete_outline,
                                        color: Colors.red,
                                        onPressed: () => _handleQuickAction(
                                          _settingsService.removePhone,
                                          'Phone number removed successfully',
                                          'Failed to remove phone number',
                                        ),
                                      )
                                    : _buildQuickActionButton(
                                        icon: Icons.add,
                                        color: Colors.green,
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const PhoneVerificationFlowPage(),
                                          ),
                                        ).then((_) => _loadUserSettings()),
                                      ),
                              ),
                            ],

                            const SizedBox(height: 32),

                            // Security Section
                            _buildSectionHeader('Security & Privacy'),
                            const SizedBox(height: 16),

                            _buildActionCard(
                              icon: Icons.lock_outline,
                              title: 'Password Management',
                              subtitle: 'Change or set your password',
                              color: const Color(0xFF667eea),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PasswordManagementPage(),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            _buildActionCard(
                              icon: Icons.security,
                              title: 'Two-Factor Authentication',
                              subtitle: _userSettings?['twoFactorEnabled'] == true
                                  ? 'Enabled - Manage settings'
                                  : 'Add an extra layer of security',
                              color: const Color(0xFF764ba2),
                              trailing: _userSettings?['twoFactorEnabled'] == true
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                                      ),
                                      child: const Text(
                                        'Enabled',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  : null,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TwoFactorAuthSetupPage(),
                                ),
                              ).then((_) => _loadUserSettings()),
                            ),

                            const SizedBox(height: 12),

                            _buildActionCard(
                              icon: Icons.link,
                              title: 'External Accounts',
                              subtitle: 'Link social media accounts',
                              color: const Color(0xFFf093fb),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ExternalLoginManagementPage(),
                                ),
                              ).then((_) => _loadUserSettings()),
                            ),

                            const SizedBox(height: 32),

                            // Quick Actions Section
                            _buildSectionHeader('Quick Actions'),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickActionCard(
                                    icon: Icons.vpn_key,
                                    title: 'Reset Auth Key',
                                    color: Colors.orange,
                                    onTap: () => _showConfirmationDialog(
                                      'Reset Authenticator Key',
                                      'This will reset your authenticator key. You\'ll need to set up your authenticator app again.',
                                      () => _handleQuickAction(
                                        _settingsService.resetAuthenticatorKey,
                                        'Authenticator key reset successfully',
                                        'Failed to reset authenticator key',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildQuickActionCard(
                                    icon: Icons.lock_reset,
                                    title: 'Recovery Codes',
                                    color: Colors.blue,
                                    onTap: _generateRecoveryCodes,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Two-Factor Toggle Section
                            if (_userSettings?['twoFactorEnabled'] != null) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _userSettings!['twoFactorEnabled'] == true
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _userSettings!['twoFactorEnabled'] == true
                                            ? Icons.security
                                            : Icons.security_outlined,
                                        color: _userSettings!['twoFactorEnabled'] == true
                                            ? Colors.green
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Two-Factor Authentication',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            _userSettings!['twoFactorEnabled'] == true
                                                ? 'Your account is protected'
                                                : 'Enhance your account security',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: _userSettings!['twoFactorEnabled'] == true,
                                      onChanged: (value) {
                                        if (value) {
                                          _handleQuickAction(
                                            _settingsService.enableTwoFactor,
                                            'Two-factor authentication enabled',
                                            'Failed to enable two-factor authentication',
                                          );
                                        } else {
                                          _showConfirmationDialog(
                                            'Disable Two-Factor Authentication',
                                            'This will make your account less secure. Are you sure?',
                                            () => _handleQuickAction(
                                              _settingsService.disableTwoFactor,
                                              'Two-factor authentication disabled',
                                              'Failed to disable two-factor authentication',
                                            ),
                                          );
                                        }
                                      },
                                      activeColor: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: color),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Future<void> _generateRecoveryCodes() async {
    try {
      final codes = await _settingsService.generateRecoveryCodes();
      if (codes != null && codes.isNotEmpty) {
        _showRecoveryCodesDialog(codes);
      } else {
        _showErrorSnackBar('Failed to generate recovery codes');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred while generating recovery codes');
      log('Generate recovery codes error: $e');
    }
  }

  void _showRecoveryCodesDialog(List<String> codes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lock_reset, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            const Text('Recovery Codes'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Save these recovery codes in a safe place. You can use them to access your account if you lose your authenticator device.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
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
                        const Icon(Icons.key, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          code,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('I\'ve Saved These Codes'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}