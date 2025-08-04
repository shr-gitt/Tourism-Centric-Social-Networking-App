import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:frontend/pages/Service/usersettings_apiservice.dart';
import 'package:getwidget/getwidget.dart';

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
      //await _loadSettings();
    } else {
      _showSnackBar('Action failed');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!));

    return Scaffold(
      appBar: AppBar(title: const Text('User Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GFListTile(
              titleText: 'Username',
              subTitleText: settings!['userName'] ?? '',
              icon: const Icon(Icons.person),
            ),
            GFListTile(
              titleText: 'Email',
              subTitleText: settings!['email'] ?? '',
              icon: const Icon(Icons.email),
            ),
            GFListTile(
              titleText: 'Phone Number',
              subTitleText: settings!['phoneNumber'] ?? 'Not added',
              icon: const Icon(Icons.phone),
            ),
            const SizedBox(height: 16),
            GFButton(
              text: 'Remove Phone Number',
              onPressed: () =>
                  _handleAction(_settings.removePhone, 'Phone removed'),
              icon: const Icon(Icons.delete),
              color: GFColors.DANGER,
            ),
            const SizedBox(height: 10),
            GFButton(
              text: 'Enable 2FA',
              onPressed: () =>
                  _handleAction(_settings.enableTwoFactor, '2FA enabled'),
              icon: const Icon(Icons.security),
              color: GFColors.SUCCESS,
            ),
            GFButton(
              text: 'Disable 2FA',
              onPressed: () =>
                  _handleAction(_settings.disableTwoFactor, '2FA disabled'),
              icon: const Icon(Icons.no_encryption),
              color: GFColors.WARNING,
            ),
            const SizedBox(height: 10),
            GFButton(
              text: 'Reset Authenticator Key',
              onPressed: () =>
                  _handleAction(_settings.resetAuthenticatorKey, 'Key reset'),
              icon: const Icon(Icons.vpn_key),
            ),
            const SizedBox(height: 10),
            GFButton(
              text: 'Generate Recovery Codes',
              onPressed: () async {
                final codes = await _settings.generateRecoveryCodes();
                if (codes != null && codes.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Recovery Codes'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: codes.map((code) => Text(code)).toList(),
                      ),
                      actions: [
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  );
                } else {
                  _showSnackBar('Failed to generate codes');
                }
              },
              icon: const Icon(Icons.lock_reset),
              color: GFColors.PRIMARY,
            ),
          ],
        ),
      ),
    );
  }
}
