import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationTrackingEnabled = true;
  bool _emergencyContactsEnabled = true;
  String _mapStyle = 'Standard';
  final List<String> _mapStyles = ['Standard', 'Satellite', 'Terrain'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ SETTINGS', style: TextStyle(letterSpacing: 1.2)),
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade900, Colors.redAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('ACCOUNT SETTINGS'),
            _buildSettingTile(
              icon: Icons.account_circle_outlined,
              title: 'Edit Profile',
              onTap: () => _navigateToProfileEdit(context),
            ),
            _buildSectionHeader('APP PREFERENCES'),
            _buildSwitchTile(
              icon: Icons.notifications_active_outlined,
              title: 'Push Notifications',
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              value: _darkModeEnabled,
              onChanged: (val) => setState(() => _darkModeEnabled = val),
            ),
            _buildSwitchTile(
              icon: Icons.location_on_outlined,
              title: 'Location Tracking',
              value: _locationTrackingEnabled,
              onChanged: (val) =>
                  setState(() => _locationTrackingEnabled = val),
            ),
            _buildDropdownTile(
              icon: Icons.map_outlined,
              title: 'Map Style',
              value: _mapStyle,
              items: _mapStyles,
              onChanged: (val) => setState(() => _mapStyle = val!),
            ),
            _buildSectionHeader('SAFETY FEATURES'),
            _buildSwitchTile(
              icon: Icons.emergency_outlined,
              title: 'Emergency Contacts',
              value: _emergencyContactsEnabled,
              onChanged: (val) =>
                  setState(() => _emergencyContactsEnabled = val),
            ),
            _buildSettingTile(
              icon: Icons.contact_emergency_outlined,
              title: 'Manage Emergency Contacts',
              onTap: () => _navigateToEmergencyContacts(context),
            ),
            _buildSectionHeader('SUPPORT'),
            _buildSettingTile(
              icon: Icons.email_outlined,
              title: 'Contact Support',
              subtitle: 'accidentsupport@example.com',
              onTap: () => _launchEmail(),
            ),
            _buildSettingTile(
              icon: Icons.help_outline_outlined,
              title: 'Help Center',
              onTap: () => _navigateToHelpCenter(context),
            ),
            _buildSettingTile(
              icon: Icons.info_outline,
              title: 'About App',
              subtitle: 'Accident Alert v1.0.0\nNamibian Safety Innovation',
              onTap: () {}, // No action needed for About App
            ),
            _buildSectionHeader('DATA'),
            _buildSettingTile(
              icon: Icons.security_outlined,
              title: 'Privacy Policy',
              onTap: () => _navigateToPrivacyPolicy(context),
            ),
            _buildSettingTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () => _navigateToTerms(context),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: TextButton(
                  onPressed: () => _showLogoutDialog(context),
                  child: const Text(
                    'LOG OUT',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.red.shade400),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.red.shade400),
      title: Text(title),
      trailing: Switch(
        value: value,
        activeColor: Colors.red,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.red.shade400),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'accidentsupport@example.com',
      queryParameters: {'subject': 'Accident Alert App Support'},
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email client')),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add your logout logic here
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Navigation placeholder methods
  void _navigateToProfileEdit(BuildContext context) {
    // Implement profile edit navigation
  }

  void _navigateToEmergencyContacts(BuildContext context) {
    // Implement emergency contacts navigation
  }

  void _navigateToHelpCenter(BuildContext context) {
    // Implement help center navigation
  }

  void _navigateToPrivacyPolicy(BuildContext context) {
    // Implement privacy policy navigation
  }

  void _navigateToTerms(BuildContext context) {
    // Implement terms navigation
  }
}
