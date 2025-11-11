import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/vehicle.dart';
import '../models/driver_document_model.dart';
import 'driver_document_service.dart';
import '../di/service_locator.dart';

class VehicleService {
  static const String _vehiclesKey = 'user_vehicles';
  DriverDocumentService? get _documentService {
    try {
      return serviceLocator<DriverDocumentService>();
    } catch (e) {
      return null;
    }
  }
  
  // Mock data for demonstration
  static final List<Vehicle> _mockVehicles = [
    Vehicle(
      id: '1',
      vehicleNumber: 'DL-09-HDR-3857',
      rcDocumentUrl: 'uploaded',
      cityOfOperation: 'Delhi NCR',
      vehicleType: '2W',
      bodyType: 'Scooter',
      fuelType: 'Petrol',
      driverName: 'Yash',
      driverPhone: '8956231478',
      driverLicenseUrl: 'uploaded',
      status: VehicleStatus.verified,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      verifiedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Vehicle(
      id: '2',
      vehicleNumber: 'DL-09-HDR-3857',
      rcDocumentUrl: 'uploaded',
      cityOfOperation: 'Delhi NCR',
      vehicleType: '2W',
      bodyType: 'Scooter',
      fuelType: 'Petrol',
      status: VehicleStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<List<Vehicle>> getUserVehicles() async {
    try {
      // Try to fetch from API first
      if (_documentService != null) {
        try {
          final vehicleRcs = await _documentService!.getVehicleRcDocuments();
          return _convertDocumentsToVehicles(vehicleRcs);
        } catch (e) {
          print('Error fetching vehicles from API: $e');
          // Fall through to local storage
        }
      }
      
      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final vehiclesJson = prefs.getString(_vehiclesKey);
      
      if (vehiclesJson != null) {
        final List<dynamic> vehiclesList = json.decode(vehiclesJson);
        return vehiclesList.map((json) => Vehicle.fromJson(json)).toList();
      }
      
      // Return mock data if no saved vehicles
      return _mockVehicles;
    } catch (e) {
      // Return mock data on error
      return _mockVehicles;
    }
  }

  /// Convert API documents to Vehicle objects
  List<Vehicle> _convertDocumentsToVehicles(List<DriverDocument> documents) {
    return documents.map((doc) {
      // Parse vehicle metadata from notes field (JSON format)
      Map<String, dynamic> metadata = {};
      if (doc.notes != null && doc.notes!.isNotEmpty) {
        try {
          metadata = json.decode(doc.notes!);
        } catch (e) {
          // If notes is not JSON, use as-is
        }
      }
      
      return Vehicle(
        id: doc.id.toString(),
        vehicleNumber: doc.documentNumber ?? 'N/A',
        rcDocumentUrl: doc.documentUrl,
        cityOfOperation: metadata['cityOfOperation'] ?? '',
        vehicleType: metadata['vehicleType'] ?? '',
        bodyType: metadata['bodyType'] ?? '',
        fuelType: metadata['fuelType'] ?? '',
        driverName: metadata['driverName'],
        driverPhone: metadata['driverPhone'],
        driverLicenseUrl: metadata['driverLicenseUrl'],
        status: doc.isVerified 
            ? VehicleStatus.verified 
            : VehicleStatus.pending,
        createdAt: doc.createdAt,
        verifiedAt: doc.verifiedAt,
      );
    }).toList();
  }

  Future<void> saveVehicle(Vehicle vehicle) async {
    try {
      // Try to save to API first
      if (_documentService != null) {
        try {
          // First upload the RC document file if it exists
          String documentUrl = vehicle.rcDocumentUrl ?? '';
          
          // If document URL is not a full URL, upload it first
          if (documentUrl.isNotEmpty && !documentUrl.startsWith('http')) {
            // Assume it's a local file path - upload it
            // For now, we'll use the document URL as-is
            // In production, upload the file first and get the URL
          }
          
          // Store vehicle metadata in notes field
          final metadata = {
            'cityOfOperation': vehicle.cityOfOperation,
            'vehicleType': vehicle.vehicleType,
            'bodyType': vehicle.bodyType,
            'fuelType': vehicle.fuelType,
            if (vehicle.driverName != null) 'driverName': vehicle.driverName!,
            if (vehicle.driverPhone != null) 'driverPhone': vehicle.driverPhone!,
            if (vehicle.driverLicenseUrl != null) 'driverLicenseUrl': vehicle.driverLicenseUrl!,
          };
          
          final documentRequest = DriverDocumentRequest(
            documentType: DocumentTypeEnum.vehicleRc,
            documentNumber: vehicle.vehicleNumber,
            documentUrl: documentUrl,
            notes: json.encode(metadata),
          );
          
          await _documentService!.uploadDocument(documentRequest);
          
          // Also save locally as backup
          final vehicles = await getUserVehicles();
          vehicles.add(vehicle);
          final prefs = await SharedPreferences.getInstance();
          final vehiclesJson = json.encode(vehicles.map((v) => v.toJson()).toList());
          await prefs.setString(_vehiclesKey, vehiclesJson);
          return;
        } catch (e) {
          print('Error saving vehicle to API: $e');
          // Fall through to local storage
        }
      }
      
      // Fallback to local storage only
      final vehicles = await getUserVehicles();
      vehicles.add(vehicle);
      final prefs = await SharedPreferences.getInstance();
      final vehiclesJson = json.encode(vehicles.map((v) => v.toJson()).toList());
      await prefs.setString(_vehiclesKey, vehiclesJson);
    } catch (e) {
      // Handle error silently for demo
    }
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      final vehicles = await getUserVehicles();
      final index = vehicles.indexWhere((v) => v.id == vehicle.id);
      
      if (index != -1) {
        vehicles[index] = vehicle;
        
        final prefs = await SharedPreferences.getInstance();
        final vehiclesJson = json.encode(vehicles.map((v) => v.toJson()).toList());
        await prefs.setString(_vehiclesKey, vehiclesJson);
      }
    } catch (e) {
      // Handle error silently for demo
    }
  }

  Future<bool> hasVerifiedVehicles() async {
    try {
      // Try to check API first
      if (_documentService != null) {
        try {
          return await _documentService!.hasVerifiedVehicles();
        } catch (e) {
          print('Error checking verified vehicles from API: $e');
          // Fall through to local check
        }
      }
      
      // Fallback to local check
      final vehicles = await getUserVehicles();
      return vehicles.any((vehicle) => vehicle.status == VehicleStatus.verified);
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasAnyVehicles() async {
    final vehicles = await getUserVehicles();
    return vehicles.isNotEmpty;
  }

  Future<void> clearVehicles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_vehiclesKey);
    } catch (e) {
      // Handle error silently
    }
  }
}
