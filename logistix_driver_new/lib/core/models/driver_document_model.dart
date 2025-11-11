import 'package:json_annotation/json_annotation.dart';

part 'driver_document_model.g.dart';

enum DocumentTypeEnum {
  @JsonValue('LICENSE')
  license,
  @JsonValue('VEHICLE_RC')
  vehicleRc,
  @JsonValue('INSURANCE')
  insurance,
  @JsonValue('PAN_CARD')
  panCard,
  @JsonValue('AADHAR_CARD')
  aadharCard,
  @JsonValue('VEHICLE_PERMIT')
  vehiclePermit,
  @JsonValue('POLLUTION_CERT')
  pollutionCert,
  @JsonValue('OTHER')
  other,
}

@JsonSerializable()
class DriverDocument {
  final int id;
  @JsonKey(name: 'document_type')
  final DocumentTypeEnum documentType;
  @JsonKey(name: 'document_type_display')
  final String documentTypeDisplay;
  @JsonKey(name: 'document_number')
  final String? documentNumber;
  @JsonKey(name: 'document_url')
  final String documentUrl;
  @JsonKey(name: 'expiry_date')
  final DateTime? expiryDate;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'verified_at')
  final DateTime? verifiedAt;
  final String? notes;
  @JsonKey(name: 'is_expired')
  final String isExpired;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  DriverDocument({
    required this.id,
    required this.documentType,
    required this.documentTypeDisplay,
    this.documentNumber,
    required this.documentUrl,
    this.expiryDate,
    required this.isVerified,
    this.verifiedAt,
    this.notes,
    required this.isExpired,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverDocument.fromJson(Map<String, dynamic> json) =>
      _$DriverDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$DriverDocumentToJson(this);
}

@JsonSerializable()
class DriverDocumentRequest {
  @JsonKey(name: 'document_type')
  final DocumentTypeEnum documentType;
  @JsonKey(name: 'document_number')
  final String? documentNumber;
  @JsonKey(name: 'document_url')
  final String documentUrl;
  @JsonKey(name: 'expiry_date')
  final DateTime? expiryDate;
  final String? notes;

  DriverDocumentRequest({
    required this.documentType,
    this.documentNumber,
    required this.documentUrl,
    this.expiryDate,
    this.notes,
  });

  factory DriverDocumentRequest.fromJson(Map<String, dynamic> json) =>
      _$DriverDocumentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DriverDocumentRequestToJson(this);
}

@JsonSerializable()
class DocumentUpdateRequest {
  @JsonKey(name: 'document_number')
  final String? documentNumber;
  @JsonKey(name: 'document_url')
  final String documentUrl;
  @JsonKey(name: 'expiry_date')
  final DateTime? expiryDate;
  final String? notes;

  DocumentUpdateRequest({
    this.documentNumber,
    required this.documentUrl,
    this.expiryDate,
    this.notes,
  });

  factory DocumentUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$DocumentUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentUpdateRequestToJson(this);
}

@JsonSerializable()
class PatchedDocumentUpdateRequest {
  @JsonKey(name: 'document_number')
  final String? documentNumber;
  @JsonKey(name: 'document_url')
  final String? documentUrl;
  @JsonKey(name: 'expiry_date')
  final DateTime? expiryDate;
  final String? notes;

  PatchedDocumentUpdateRequest({
    this.documentNumber,
    this.documentUrl,
    this.expiryDate,
    this.notes,
  });

  factory PatchedDocumentUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$PatchedDocumentUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PatchedDocumentUpdateRequestToJson(this);
}

@JsonSerializable()
class BulkDocumentUploadRequest {
  final List<Map<String, dynamic>> documents;

  BulkDocumentUploadRequest({
    required this.documents,
  });

  factory BulkDocumentUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$BulkDocumentUploadRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BulkDocumentUploadRequestToJson(this);
}

@JsonSerializable()
class FileUploadRequest {
  final String file;
  final String? subfolder;

  FileUploadRequest({
    required this.file,
    this.subfolder,
  });

  factory FileUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$FileUploadRequestFromJson(json);
  Map<String, dynamic> toJson() => _$FileUploadRequestToJson(this);
}

@JsonSerializable()
class FileUpload {
  final String file;
  final String? subfolder;

  FileUpload({
    required this.file,
    this.subfolder,
  });

  factory FileUpload.fromJson(Map<String, dynamic> json) =>
      _$FileUploadFromJson(json);
  Map<String, dynamic> toJson() => _$FileUploadToJson(this);
}
