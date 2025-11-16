/// settings_screen.dart - Profile & Settings Screen
/// 
/// Purpose:
/// - Displays driver profile information and settings
/// - Shows earnings and trip statistics
/// - Provides access to account settings, documents, and support
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/user_model.dart';
import '../../../../features/driver/domain/repositories/driver_repository.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final DriverRepository _driverRepository;
  Map<String, dynamic>? _driverProfile;
  bool _isAvailable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _driverRepository = serviceLocator<DriverRepository>();
    _fetchDriverProfile();
  }

  Future<void> _fetchDriverProfile() async {
    try {
      final driver = await _driverRepository.getDriverProfile().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout fetching driver profile');
        },
      );
      
      final profile = driver.toJson();
      
      if (mounted) {
        setState(() {
          _driverProfile = profile;
          _isAvailable = profile['is_available'] ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching driver profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
          });
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFFFF6B00),
        ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 12,
                          left: 16,
                          right: 16,
                          bottom: 9,
                        ),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0xFFE6E6E6),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Image.asset(
                                'assets/images/logo without text/logo color.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to gradient if image not found
                                  return Container(
                                    decoration: ShapeDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment(0.00, 0.00),
                                        end: Alignment(1.00, 1.00),
                                        colors: [Color(0xFFFF6B00), Color(0xFFFF7A1A)],
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
      child: Text(
                                'Profile & Settings',
                                style: TextStyle(
                                  color: const Color(0xFF111111),
                                  fontSize: 18,
                                  fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
      children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 3,
                                  ),
                                  decoration: ShapeDecoration(
                                    color: _isAvailable
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFF3F4F6),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: _isAvailable
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFFE6E6E6),
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
            ),
                                  child: Text(
                                    'Online',
                                    style: TextStyle(
                                      color: _isAvailable
                                          ? Colors.white
                                          : const Color(0xFF9CA3AF),
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
          ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
          onTap: () {
                                    Navigator.of(context).pushNamed('/alerts');
                                  },
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    child: const Icon(
                                      Icons.notifications_outlined,
                                      size: 22,
                                      color: Color(0xFF111111),
                                    ),
            ),
          ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Main Content
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
          ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(13),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFE6E6E6),
                                  ),
              borderRadius: BorderRadius.circular(8),
            ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      image: _driverProfile != null &&
                                              _driverProfile!['user'] != null &&
                                              (_driverProfile!['user'] as User).profilePicture != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                (_driverProfile!['user'] as User).profilePicture!,
          ),
                                              fit: BoxFit.fill,
                                            )
                                          : null,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      color: _driverProfile == null ||
                                              _driverProfile!['user'] == null ||
                                              (_driverProfile!['user'] as User).profilePicture == null
                                          ? const Color(0xFFE6E6E6)
                                          : null,
                                    ),
                                    child: _driverProfile == null ||
                                            _driverProfile!['user'] == null ||
                                            (_driverProfile!['user'] as User).profilePicture == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 28,
                                            color: Color(0xFF9CA3AF),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                                        Text(
                                          _driverProfile != null &&
                                                  _driverProfile!['user'] != null
                                              ? '${(_driverProfile!['user'] as User).firstName ?? ''} ${(_driverProfile!['user'] as User).lastName ?? ''}'
                                              : 'Driver',
                                          style: TextStyle(
                                            color: const Color(0xFF111111),
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                          ),
            ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Delhi NCR • 2 yrs driving',
                                          style: TextStyle(
                                            color: const Color(0xFF9CA3AF),
                                            fontSize: 13,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 9,
                                                vertical: 3,
                                              ),
                                              decoration: ShapeDecoration(
                                                shape: RoundedRectangleBorder(
                                                  side: const BorderSide(
                                                    width: 1,
                                                    color: Color(0xFFE6E6E6),
                                                  ),
                                                  borderRadius: BorderRadius.circular(999),
                                                ),
                                              ),
                                              child: Text(
                                                'ID: ${_driverProfile?['id'] ?? 'LX-0000'}',
                                                style: TextStyle(
                                                  color: const Color(0xFF9CA3AF),
                                                  fontSize: 12,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                top: 3,
                                                left: 9,
                                                right: 9,
                                                bottom: 5,
                                              ),
                                              decoration: ShapeDecoration(
                                                color: const Color(0xFFF3F4F6),
                                                shape: RoundedRectangleBorder(
                                                  side: const BorderSide(
                                                    width: 1,
                                                    color: Color(0xFFE6E6E6),
                                                  ),
                                                  borderRadius: BorderRadius.circular(999),
                                                ),
                                              ),
                                              child: Text(
                                                _getRatingDisplay(),
                                                style: TextStyle(
                                                  color: const Color(0xFF9CA3AF),
                                                  fontSize: 12,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
              ],
            ),
          ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // TODO: Navigate to edit profile
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      child: const Icon(
                                        Icons.edit_outlined,
                                        size: 20,
                                        color: Color(0xFF111111),
                                      ),
        ),
      ),
                                ],
                              ),
        ),
                            const SizedBox(height: 12),
                            // Earnings Summary
                            Row(
          mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(11),
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 1,
                                          color: Color(0xFFE6E6E6),
              ),
                                        borderRadius: BorderRadius.circular(8),
        ),
      ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                                        Text(
                                          'This week',
                                          style: TextStyle(
                                            color: const Color(0xFF9CA3AF),
                                            fontSize: 12,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
            ),
          ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₹${_driverProfile?['week_earnings'] ?? _driverProfile?['total_earnings'] ?? '0'}',
                                          style: TextStyle(
                                            color: const Color(0xFF111111),
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                          ),
          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(11),
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 1,
                                          color: Color(0xFFE6E6E6),
                                        ),
              borderRadius: BorderRadius.circular(8),
            ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Trips',
                                          style: TextStyle(
                                            color: const Color(0xFF9CA3AF),
                                            fontSize: 12,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_driverProfile?['total_trips'] ?? '0'}',
                                          style: TextStyle(
                                            color: const Color(0xFF111111),
                                            fontSize: 16,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                          ),
          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Account Section
                            Container(
                              width: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFE6E6E6),
                                  ),
              borderRadius: BorderRadius.circular(8),
            ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(
                                      top: 12,
                                      left: 12,
                                      right: 12,
                                      bottom: 13,
                                    ),
                                    child: Text(
                                      'Account',
                                      style: TextStyle(
                                        color: const Color(0xFF111111),
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
          ),
                                    ),
                                  ),
                                  _buildAccountItem(
                                    icon: Icons.description_outlined,
                                    title: 'Documents',
                                    subtitle: 'License, RC, Insurance',
                                    onTap: () {
                                      Navigator.of(context).pushNamed('/driver/documents');
                                    },
          ),
                                  _buildAccountItem(
                                    icon: Icons.account_balance_outlined,
                                    title: 'Bank & Payouts',
                                    subtitle: 'HDFC • **** 4931',
                                    onTap: () {
                                      // TODO: Navigate to bank & payouts
            },
          ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 1,
                                          color: Color(0xFFE6E6E6),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
                                        Container(
                                          width: 22,
                                          height: 22,
                                          child: const Icon(
                                            Icons.security_outlined,
                                            size: 22,
                                            color: Color(0xFF111111),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Security',
                                                style: TextStyle(
                                                  color: const Color(0xFF111111),
                                                  fontSize: 15,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Password, 2-step verification',
                                                style: TextStyle(
                                                  color: const Color(0xFF9CA3AF),
                                                  fontSize: 13,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w400,
          ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 18,
                                          height: 18,
                                          child: const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 18,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ],
        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Support Section
                            Container(
                              width: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFE6E6E6),
                                  ),
              borderRadius: BorderRadius.circular(8),
            ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(
                                      top: 12,
                                      left: 12,
                                      right: 12,
                                      bottom: 13,
          ),
                                    child: Text(
                                      'Support',
                                      style: TextStyle(
                                        color: const Color(0xFF111111),
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  _buildAccountItem(
                                    icon: Icons.help_outline,
                                    title: 'Help Center',
                                    subtitle: 'FAQs and issue resolution',
          onTap: () {
                                      // TODO: Navigate to help center
          },
        ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 1,
                                          color: Color(0xFFE6E6E6),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 22,
                                          height: 22,
                                          child: const Icon(
                                            Icons.chat_bubble_outline,
                                            size: 22,
                                            color: Color(0xFF111111),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Chat with support',
                                                style: TextStyle(
                                                  color: const Color(0xFF111111),
                                                  fontSize: 15,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
          ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Average reply in 5 min',
                                                style: TextStyle(
                                                  color: const Color(0xFF9CA3AF),
                                                  fontSize: 13,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w400,
          ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 18,
                                          height: 18,
                                          child: const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 18,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Logout Button
                            Container(
                              width: double.infinity,
                              height: 51,
                              decoration: ShapeDecoration(
                                color: const Color(0xFF333333),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFE6E6E6),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
          onTap: () {
                                    _showLogoutBottomSheet(context);
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        child: const Icon(
                                          Icons.arrow_forward,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        ' Logout',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                        ),
        ),
      ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _showLogoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFFE6E6E6),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
        ),
        padding: const EdgeInsets.only(
          top: 17,
          left: 16,
          right: 16,
          bottom: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: ShapeDecoration(
                  color: const Color(0xFFE6E6E6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.logout,
                    size: 22,
                    color: Color(0xFF111111),
          ),
                  const SizedBox(width: 10),
                  Text(
                    'Log out of Logistix?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF111111),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Description
            Center(
              child: Text(
                'You will stop receiving trip requests until you sign in\nagain.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
          ),
        ),
            ),
            const SizedBox(height: 12),
            // Info Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(9),
              decoration: ShapeDecoration(
                color: const Color(0xFF333333),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFE6E6E6),
                  ),
              borderRadius: BorderRadius.circular(8),
            ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Saved progress and uploaded documents\nremain secure.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
          onTap: () {
                      Navigator.of(context).pop();
          },
                    child: Container(
                      height: 51,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF333333),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFFE6E6E6),
                          ),
              borderRadius: BorderRadius.circular(8),
            ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
          ),
                          const SizedBox(width: 8),
                          Text(
                            ' Cancel',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
          ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
          onTap: () {
                      Navigator.of(context).pop();
                      context.read<AuthBloc>().add(Logout());
                    },
                    child: Container(
                      height: 51,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFDC2626),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFFDC2626),
                          ),
              borderRadius: BorderRadius.circular(8),
            ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout,
                            size: 18,
                            color: Colors.white,
          ),
                          const SizedBox(width: 8),
                          Text(
                            ' Log out',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
          ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingDisplay() {
    final rating = _driverProfile?['average_rating'];
    if (rating == null) {
      return '4.9★';
    }
    
    // Handle both String and numeric values
    if (rating is num) {
      return '${rating.toStringAsFixed(1)}★';
    } else if (rating is String) {
      // Try to parse as double, fallback to original string
      final parsed = double.tryParse(rating);
      if (parsed != null) {
        return '${parsed.toStringAsFixed(1)}★';
      }
      return '$rating★';
    }
    
    return '4.9★';
  }

  Widget _buildAccountItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
            width: double.infinity,
      padding: const EdgeInsets.only(
        top: 12,
        left: 12,
        right: 12,
        bottom: 13,
      ),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFE6E6E6),
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                child: Icon(
                  icon,
                  size: 22,
                  color: const Color(0xFF111111),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: const Color(0xFF111111),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 18,
                height: 18,
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Color(0xFF9CA3AF),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
} 
