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
            ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('Remove Phone Number'),
              onPressed: () => _handleAction(_settings.removePhone, 'Phone number removed.'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.security),
              label: const Text('Enable 2FA'),
              onPressed: () => _handleAction(_settings.enableTwoFactor, '2FA enabled.'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.no_encryption),
              label: const Text('Disable 2FA'),
              onPressed: () => _handleAction(_settings.disableTwoFactor, '2FA disabled.'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.vpn_key),
              label: const Text('Reset Authenticator Key'),
              onPressed: () => _handleAction(_settings.resetAuthenticatorKey, 'Authenticator key reset.'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.lock_reset),
              label: const Text('Generate Recovery Codes'),
              onPressed: () async {
                final codes = await _settings.generateRecoveryCodes();
                if (codes != null && codes.isNotEmpty) {
                  _showRecoveryDialog(codes);
                } else {
                  _showSnackBar('Failed to generate recovery codes.');
                }
              },
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

  void _showRecoveryDialog(List<String> codes) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Recovery Codes'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: codes.map((code) => Text(code)).toList(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}
