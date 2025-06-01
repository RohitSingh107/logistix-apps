import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/user_model.dart';
import '../../presentation/bloc/user_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load user profile when screen is initialized
    print('DEBUG: ProfileScreen initialized, loading user profile');
    
    // Add a slight delay to ensure all tokens are properly loaded
    Future.delayed(const Duration(milliseconds: 500), () {
      context.read<UserBloc>().add(LoadUserProfile());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded) {
            return _buildUserProfile(context, state.user);
          } else if (state is UserError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserBloc>().add(LoadUserProfile());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          // Show loading for initial state
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, User user) {
    final memberSince = 'Jan 2023'; // This would come from the user model ideally
    
    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserBloc>().add(LoadUserProfile());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '',
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.firstName} ${user.lastName}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+${user.phone}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Member since $memberSince',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditProfileDialog(context, user);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // User Details Section
            _buildSection(
              context,
              'Personal Information',
              [
                _buildDetailItem(Icons.phone, 'Phone', '+${user.phone}'),
                _buildDetailItem(Icons.location_on, 'Address', 'Not provided'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Account Settings Section
            _buildSection(
              context,
              'Account Settings',
              [
                _buildLinkItem(
                  context,
                  Icons.payment,
                  'Payment Methods',
                  () {
                    Navigator.pushNamed(context, '/payment-methods');
                  },
                ),
                _buildLinkItem(
                  context,
                  Icons.notifications,
                  'Notification Settings',
                  () {
                    Navigator.pushNamed(context, '/notification-settings');
                  },
                ),
                _buildLinkItem(
                  context,
                  Icons.language,
                  'Language',
                  () {
                    _showLanguageSelectionDialog(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Support Section
            _buildSection(
              context,
              'Support',
              [
                _buildLinkItem(
                  context,
                  Icons.help,
                  'Help Center',
                  () {
                    _launchURL('https://logistix.example.com/help');
                  },
                ),
                _buildLinkItem(
                  context,
                  Icons.privacy_tip,
                  'Privacy Policy',
                  () {
                    _launchURL('https://logistix.example.com/privacy-policy');
                  },
                ),
                _buildLinkItem(
                  context,
                  Icons.description,
                  'Terms of Service',
                  () {
                    _launchURL('https://logistix.example.com/terms-of-service');
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    // Show confirmation dialog
                    _showLogoutConfirmationDialog(context);
                  },
                  child: const Text('Logout'),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Helper method to handle URLs
  void _launchURL(String url) {
    // Show a dialog instead of opening the URL directly
    // This is a fallback if url_launcher is not available
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('External Link'),
          content: Text('Would open: $url'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Show logout confirmation dialog
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                // Logout user
                context.read<AuthBloc>().add(Logout());
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Show edit profile dialog
  void _showEditProfileDialog(BuildContext context, User user) {
    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update profile with current phone number
                context.read<UserBloc>().add(UpdateUserProfile(
                  phone: user.phone.toString(),
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                ));
                Navigator.of(dialogContext).pop(); // Close dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Show language selection dialog
  void _showLanguageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return SimpleDialog(
          title: const Text('Select Language'),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext, 'en');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language set to English')),
                );
              },
              child: const Text('English'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext, 'es');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language set to Spanish')),
                );
              },
              child: const Text('Spanish'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(dialogContext, 'fr');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language set to French')),
                );
              },
              child: const Text('French'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(value),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
} 