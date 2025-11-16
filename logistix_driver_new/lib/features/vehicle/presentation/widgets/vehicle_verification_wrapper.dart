import 'package:flutter/material.dart';
import '../../../../core/services/driver_verification_service.dart';
import '../../../home/presentation/screens/main_navigation_screen.dart';
import '../../../driver/presentation/screens/create_driver_profile_screen.dart';
import '../../../driver/presentation/screens/driver_documents_screen.dart';
import '../screens/my_vehicles_screen.dart';

class VehicleVerificationWrapper extends StatefulWidget {
  const VehicleVerificationWrapper({super.key});

  @override
  State<VehicleVerificationWrapper> createState() => _VehicleVerificationWrapperState();
}

class _VehicleVerificationWrapperState extends State<VehicleVerificationWrapper> {
  final _verificationService = DriverVerificationService();

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    try {
      print('🔍 VehicleVerificationWrapper: Checking verification status...');
      final result = await _verificationService.checkVerificationStatus();
      print('📊 VehicleVerificationWrapper: Status = ${result.status}, Driver = ${result.driver?.id}, isVerified = ${result.driver?.isVerified}');
      print('📊 VehicleVerificationWrapper: Driver details - ID: ${result.driver?.id}, isVerified: ${result.driver?.isVerified}, type: ${result.driver?.isVerified.runtimeType}');

      // Use a small delay to ensure the widget is mounted and ready
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!mounted) {
        print('⚠️ VehicleVerificationWrapper: Widget not mounted, skipping navigation');
        return;
      }

      switch (result.status) {
        case DriverVerificationStatus.noProfile:
          print('👤 VehicleVerificationWrapper: No profile, navigating to CreateDriverProfileScreen');
          // Navigate to create driver profile
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const CreateDriverProfileScreen(),
            ),
          );
          break;

        case DriverVerificationStatus.unverified:
          // Check if driver is_verified is false - show document screen
          // Otherwise show vehicle screen
          if (result.driver != null && !result.driver!.isVerified) {
            print('📄 VehicleVerificationWrapper: Driver not verified (is_verified=false), navigating to DriverDocumentsScreen');
            // Driver profile exists but not verified - show document upload screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const DriverDocumentsScreen(),
              ),
            );
          } else {
            print('🚗 VehicleVerificationWrapper: No driver or other case, navigating to MyVehiclesScreen');
            // No driver profile or other case - show vehicle management screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MyVehiclesScreen(),
              ),
            );
          }
          break;

        case DriverVerificationStatus.hasVerifiedVehicles:
        case DriverVerificationStatus.fullyVerified:
          print('✅ VehicleVerificationWrapper: Driver verified (status: ${result.status}), navigating to MainNavigationScreen');
          print('✅ VehicleVerificationWrapper: Driver isVerified = ${result.driver?.isVerified}');
          // Navigate to main app
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(),
            ),
          );
          break;
      }
    } catch (e) {
      print('❌ VehicleVerificationWrapper: Error checking status: $e');
      // On error, go to My Vehicles screen as fallback
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MyVehiclesScreen(),
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
