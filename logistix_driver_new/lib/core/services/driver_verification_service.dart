import '../models/driver_model.dart';
import '../models/driver_document_model.dart';
import 'driver_document_service.dart';
import '../../features/driver/domain/repositories/driver_repository.dart';
import '../di/service_locator.dart';

enum DriverVerificationStatus {
  /// Driver profile doesn't exist - needs to create profile
  noProfile,
  
  /// Driver profile exists but not verified, and no verified documents
  unverified,
  
  /// Driver has at least one verified vehicle document
  hasVerifiedVehicles,
  
  /// Driver profile is fully verified
  fullyVerified,
}

class DriverVerificationResult {
  final DriverVerificationStatus status;
  final Driver? driver;
  final List<DriverDocument> vehicleDocuments;
  final bool hasVerifiedDocuments;
  final String? message;

  DriverVerificationResult({
    required this.status,
    this.driver,
    this.vehicleDocuments = const [],
    this.hasVerifiedDocuments = false,
    this.message,
  });
}

/// Service to check driver verification status and determine navigation flow
class DriverVerificationService {
  final DriverRepository _driverRepository;
  final DriverDocumentService _documentService;

  DriverVerificationService()
      : _driverRepository = serviceLocator<DriverRepository>(),
        _documentService = serviceLocator<DriverDocumentService>();

  /// Check complete driver verification status
  /// Returns status and data needed for navigation decision
  Future<DriverVerificationResult> checkVerificationStatus() async {
    try {
      // Step 1: Check if driver profile exists
      Driver? driver;
      try {
        driver = await _driverRepository.getDriverProfile();
      } catch (e) {
        // Driver profile doesn't exist (404 or 500)
        return DriverVerificationResult(
          status: DriverVerificationStatus.noProfile,
          message: 'Driver profile not found. Please create your profile.',
        );
      }

      // Step 2: Check vehicle documents
      List<DriverDocument> vehicleDocuments = [];
      try {
        vehicleDocuments = await _documentService.getVehicleRcDocuments();
      } catch (e) {
        // If documents fetch fails, continue with empty list
        print('Error fetching vehicle documents: $e');
      }

      // Step 3: Check if any documents are verified
      final hasVerifiedDocuments = vehicleDocuments.any(
        (doc) => doc.isVerified,
      );

      // Step 4: Determine status
      if (driver.isVerified && hasVerifiedDocuments) {
        // Fully verified driver with verified vehicles
        return DriverVerificationResult(
          status: DriverVerificationStatus.fullyVerified,
          driver: driver,
          vehicleDocuments: vehicleDocuments,
          hasVerifiedDocuments: true,
          message: 'Driver fully verified and ready to start trips.',
        );
      } else if (hasVerifiedDocuments) {
        // Has verified vehicles but driver profile not fully verified
        return DriverVerificationResult(
          status: DriverVerificationStatus.hasVerifiedVehicles,
          driver: driver,
          vehicleDocuments: vehicleDocuments,
          hasVerifiedDocuments: true,
          message: 'You have verified vehicles. You can start accepting trips.',
        );
      } else if (vehicleDocuments.isNotEmpty) {
        // Has documents but none verified
        return DriverVerificationResult(
          status: DriverVerificationStatus.unverified,
          driver: driver,
          vehicleDocuments: vehicleDocuments,
          hasVerifiedDocuments: false,
          message: 'Your documents are under review. This may take up to 4 days.',
        );
      } else {
        // No documents at all
        return DriverVerificationResult(
          status: DriverVerificationStatus.unverified,
          driver: driver,
          vehicleDocuments: [],
          hasVerifiedDocuments: false,
          message: 'Please add your vehicle and upload documents to get started.',
        );
      }
    } catch (e) {
      print('Error checking verification status: $e');
      // On error, assume unverified to show vehicle screen
      return DriverVerificationResult(
        status: DriverVerificationStatus.unverified,
        message: 'Unable to verify status. Please try again.',
      );
    }
  }

  /// Quick check: Does driver have verified vehicles?
  Future<bool> hasVerifiedVehicles() async {
    try {
      final result = await checkVerificationStatus();
      return result.hasVerifiedDocuments;
    } catch (e) {
      return false;
    }
  }

  /// Quick check: Does driver profile exist?
  Future<bool> hasDriverProfile() async {
    try {
      await _driverRepository.getDriverProfile();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get verification status message for UI
  String getStatusMessage(DriverVerificationStatus status) {
    switch (status) {
      case DriverVerificationStatus.noProfile:
        return 'Complete your driver profile to get started';
      case DriverVerificationStatus.unverified:
        return 'Your documents are under review. This may take up to 4 days.';
      case DriverVerificationStatus.hasVerifiedVehicles:
        return 'You have verified vehicles. You can start accepting trips!';
      case DriverVerificationStatus.fullyVerified:
        return 'You\'re all set! Start accepting trips now.';
    }
  }
}
