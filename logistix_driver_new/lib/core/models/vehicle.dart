class Vehicle {
  final String id;
  final String vehicleNumber;
  final String? rcDocumentUrl;
  final String cityOfOperation;
  final String vehicleType;
  final String bodyType;
  final String fuelType;
  final String? driverName;
  final String? driverPhone;
  final String? driverLicenseUrl;
  final VehicleStatus status;
  final DateTime createdAt;
  final DateTime? verifiedAt;

  const Vehicle({
    required this.id,
    required this.vehicleNumber,
    this.rcDocumentUrl,
    required this.cityOfOperation,
    required this.vehicleType,
    required this.bodyType,
    required this.fuelType,
    this.driverName,
    this.driverPhone,
    this.driverLicenseUrl,
    required this.status,
    required this.createdAt,
    this.verifiedAt,
  });

  Vehicle copyWith({
    String? id,
    String? vehicleNumber,
    String? rcDocumentUrl,
    String? cityOfOperation,
    String? vehicleType,
    String? bodyType,
    String? fuelType,
    String? driverName,
    String? driverPhone,
    String? driverLicenseUrl,
    VehicleStatus? status,
    DateTime? createdAt,
    DateTime? verifiedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      rcDocumentUrl: rcDocumentUrl ?? this.rcDocumentUrl,
      cityOfOperation: cityOfOperation ?? this.cityOfOperation,
      vehicleType: vehicleType ?? this.vehicleType,
      bodyType: bodyType ?? this.bodyType,
      fuelType: fuelType ?? this.fuelType,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverLicenseUrl: driverLicenseUrl ?? this.driverLicenseUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleNumber': vehicleNumber,
      'rcDocumentUrl': rcDocumentUrl,
      'cityOfOperation': cityOfOperation,
      'vehicleType': vehicleType,
      'bodyType': bodyType,
      'fuelType': fuelType,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'driverLicenseUrl': driverLicenseUrl,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      rcDocumentUrl: json['rcDocumentUrl'] as String?,
      cityOfOperation: json['cityOfOperation'] as String,
      vehicleType: json['vehicleType'] as String,
      bodyType: json['bodyType'] as String,
      fuelType: json['fuelType'] as String,
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      driverLicenseUrl: json['driverLicenseUrl'] as String?,
      status: VehicleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VehicleStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      verifiedAt: json['verifiedAt'] != null 
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
    );
  }
}

enum VehicleStatus {
  pending,
  underReview,
  verified,
  rejected,
}

class VehicleFormData {
  String vehicleNumber;
  String? rcDocumentUrl;
  String cityOfOperation;
  String vehicleType;
  String bodyType;
  String fuelType;
  String? driverName;
  String? driverPhone;
  String? driverLicenseUrl;

  VehicleFormData({
    this.vehicleNumber = '',
    this.rcDocumentUrl,
    this.cityOfOperation = '',
    this.vehicleType = '',
    this.bodyType = '',
    this.fuelType = '',
    this.driverName,
    this.driverPhone,
    this.driverLicenseUrl,
  });

  bool get isComplete {
    return vehicleNumber.isNotEmpty &&
        rcDocumentUrl != null &&
        cityOfOperation.isNotEmpty &&
        vehicleType.isNotEmpty &&
        bodyType.isNotEmpty &&
        fuelType.isNotEmpty &&
        driverName != null &&
        driverPhone != null &&
        driverLicenseUrl != null;
  }

  Vehicle toVehicle() {
    return Vehicle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      vehicleNumber: vehicleNumber,
      rcDocumentUrl: rcDocumentUrl,
      cityOfOperation: cityOfOperation,
      vehicleType: vehicleType,
      bodyType: bodyType,
      fuelType: fuelType,
      driverName: driverName,
      driverPhone: driverPhone,
      driverLicenseUrl: driverLicenseUrl,
      status: VehicleStatus.pending,
      createdAt: DateTime.now(),
    );
  }
}
