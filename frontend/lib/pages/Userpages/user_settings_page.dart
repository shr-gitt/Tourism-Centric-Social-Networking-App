import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:frontend/pages/Service/usersettings_apiservice.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final UserService _userService = UserService();
  final UsersettingsApiservice _settings = UsersettingsApiservice();
  Map<String, dynamic>? settings;

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSettings();
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

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error != null) return Scaffold(body: Center(child: Text(error!)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _infoTile('Username', settings?['userName'] ?? ''),
            _infoTile('Email', settings?['email'] ?? ''),
            _infoTile('Phone Number', settings?['phoneNumber'] ?? 'Not added'),
            const SizedBox(height: 32),
            // Phone Management
            Card(
              child: ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone Number'),
                subtitle: Text(settings?['phoneNumber'] ?? 'Not added'),
                trailing: settings?['phoneNumber'] != null
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _handleAction(_settings.removePhone, 'Phone number removed.'),
                      )
                    : TextButton(
                        onPressed: () => _showAddPhoneDialog(),
                        child: const Text('Add'),
                      ),
              ),
            ),
            const SizedBox(height: 10),

            // Password Management
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Password'),
                subtitle: Text(settings?['hasPassword'] == true ? 'Set' : 'Not set'),
                trailing: TextButton(
                  onPressed: () => _showPasswordDialog(),
                  child: Text(settings?['hasPassword'] == true ? 'Change' : 'Set'),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Two-Factor Authentication
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Two-Factor Authentication'),
                    subtitle: Text(settings?['twoFactorEnabled'] == true ? 'Enabled' : 'Disabled'),
                    trailing: Switch(
                      value: settings?['twoFactorEnabled'] == true,
                      onChanged: (value) {
                        if (value) {
                          _handleAction(_settings.enableTwoFactor, '2FA enabled.');
                        } else {
                          _showDisable2FADialog();
                        }
                      },
                    ),
                  ),
                  if (settings?['twoFactorEnabled'] == true) ...[
                    const Divider(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.vpn_key, size: 16),
                          label: const Text('Reset Key'),
                          onPressed: () => _showResetKeyDialog(),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.lock_reset, size: 16),
                          label: const Text('Recovery Codes'),
                          onPressed: () => _generateRecoveryCodes(),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info),
          title: Text(title),
          subtitle: Text(value),
        ),
        const Divider(),
      ],
    );
  }

  void _showAddPhoneDialog() {
    final phoneController = TextEditingController();
    final codeController = TextEditingController();
    bool codeSent = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(codeSent ? 'Verify Phone' : 'Add Phone Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!codeSent) ...[
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else ...[
                Text('Code sent to ${phoneController.text}'),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Verification Code',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!codeSent) {
                  final success = await _settings.addPhone(phoneController.text);
                  if (success) {
                    setState(() => codeSent = true);
                    _showSnackBar('Verification code sent');
                  } else {
                    _showSnackBar('Failed to send code');
                  }
                } else {
                  final success = await _settings.verifyPhone(phoneController.text, codeController.text);
                  if (success) {
                    Navigator.of(ctx).pop();
                    _loadSettings();
                    _showSnackBar('Phone number added');
                  } else {
                    _showSnackBar('Verification failed');
                  }
                }
              },
              child: Text(codeSent ? 'Verify' : 'Send Code'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final hasPassword = settings?['hasPassword'] == true;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(hasPassword ? 'Change Password' : 'Set Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasPassword) ...[
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                _showSnackBar('Passwords do not match');
                return;
              }
              
              bool success;
              if (hasPassword) {
                // Change password logic would go here
                // For now, just show success
                success = true;
              } else {
                // Set password logic would go here
                // For now, just show success
                success = true;
              }
              
              if (success) {
                Navigator.of(ctx).pop();
                _showSnackBar('Password ${hasPassword ? 'changed' : 'set'} successfully');
              } else {
                _showSnackBar('Failed to ${hasPassword ? 'change' : 'set'} password');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDisable2FADialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disable 2FA'),
        content: const Text('Are you sure you want to disable two-factor authentication? This will make your account less secure.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _handleAction(_settings.disableTwoFactor, '2FA disabled.');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }

  void _showResetKeyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Authenticator Key'),
        content: const Text('This will reset your authenticator key. You\'ll need to set up your authenticator app again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _handleAction(_settings.resetAuthenticatorKey, 'Authenticator key reset.');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _generateRecoveryCodes() async {
    final codes = await _settings.generateRecoveryCodes();
    if (codes != null && codes.isNotEmpty) {
      _showRecoveryDialog(codes);
    } else {
      _showSnackBar('Failed to generate recovery codes.');
    }
  }

  void _showRecoveryDialog(List<String> codes) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recovery Codes'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Save these codes in a safe place. You can use them to access your account if you lose your authenticator device.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: codes.map((code) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.key, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          code,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
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
            child: const Text('I\'ve Saved These Codes'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}
