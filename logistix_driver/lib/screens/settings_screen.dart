import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      'https://www.cnss.gov.lb/dino-imagem/Dinosaurs-Wallpapers-Wallpaper-Cave-14640281/',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rohit Singh',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '+91 9876543210',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Verified Driver',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Edit profile
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Account Section
          Text(
            'Account',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildSettingsCard([
            _buildSettingsTile(
              'Personal Information',
              'Update your profile details',
              Icons.person,
              () {
                // TODO: Navigate to profile edit
              },
            ),
            _buildSettingsTile(
              'Vehicle Information',
              'Manage your vehicle details',
              Icons.directions_car,
              () {
                // TODO: Navigate to vehicle info
              },
            ),
            _buildSettingsTile(
              'Bank Details',
              'Update payment information',
              Icons.account_balance,
              () {
                // TODO: Navigate to bank details
              },
            ),
            _buildSettingsTile(
              'Documents',
              'Upload and verify documents',
              Icons.folder,
              () {
                // TODO: Navigate to documents
              },
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Preferences Section
          Text(
            'Preferences',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildSettingsCard([
            _buildSwitchTile(
              'Push Notifications',
              'Receive booking alerts and updates',
              Icons.notifications,
              _notificationsEnabled,
              (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildSwitchTile(
              'Location Services',
              'Allow location tracking for trips',
              Icons.location_on,
              _locationEnabled,
              (value) {
                setState(() {
                  _locationEnabled = value;
                });
              },
            ),
            _buildSwitchTile(
              'Dark Mode',
              'Switch to dark theme',
              Icons.dark_mode,
              _darkMode,
              (value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Support Section
          Text(
            'Support',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildSettingsCard([
            _buildSettingsTile(
              'Help Center',
              'Get help and support',
              Icons.help,
              () {
                // TODO: Navigate to help center
              },
            ),
            _buildSettingsTile(
              'Contact Support',
              'Reach out to our support team',
              Icons.support_agent,
              () {
                // TODO: Navigate to contact support
              },
            ),
            _buildSettingsTile(
              'Report Issue',
              'Report bugs or problems',
              Icons.bug_report,
              () {
                // TODO: Navigate to report issue
              },
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Legal Section
          Text(
            'Legal',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildSettingsCard([
            _buildSettingsTile(
              'Terms of Service',
              'Read our terms and conditions',
              Icons.description,
              () {
                // TODO: Navigate to terms
              },
            ),
            _buildSettingsTile(
              'Privacy Policy',
              'View our privacy policy',
              Icons.privacy_tip,
              () {
                // TODO: Navigate to privacy policy
              },
            ),
            _buildSettingsTile(
              'About',
              'App version and information',
              Icons.info,
              () {
                // TODO: Show about dialog
              },
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showLogoutDialog();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // App Version
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement logout functionality
                Navigator.of(context).pop();
                // Navigate to login screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
} 