// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverDocument _$DriverDocumentFromJson(Map<String, dynamic> json) =>
    DriverDocument(
      id: (json['id'] as num).toInt(),
      documentType:
          $enumDecode(_$DocumentTypeEnumEnumMap, json['document_type']),
      documentTypeDisplay: json['document_type_display'] as String,
      documentNumber: json['document_number'] as String?,
      documentUrl: json['document_url'] as String,
      expiryDate: json['expiry_date'] == null
          ? null
          : DateTime.parse(json['expiry_date'] as String),
      isVerified: json['is_verified'] as bool,
      verifiedAt: json['verified_at'] == null
          ? null
          : DateTime.parse(json['verified_at'] as String),
      notes: json['notes'] as String?,
      isExpired: json['is_expired'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$DriverDocumentToJson(DriverDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'document_type': _$DocumentTypeEnumEnumMap[instance.documentType]!,
      'document_type_display': instance.documentTypeDisplay,
      'document_number': instance.documentNumber,
      'document_url': instance.documentUrl,
      'expiry_date': instance.expiryDate?.toIso8601String(),
      'is_verified': instance.isVerified,
      'verified_at': instance.verifiedAt?.toIso8601String(),
      'notes': instance.notes,
      'is_expired': instance.isExpired,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$DocumentTypeEnumEnumMap = {
  DocumentTypeEnum.license: 'LICENSE',
  DocumentTypeEnum.vehicleRc: 'VEHICLE_RC',
  DocumentTypeEnum.insurance: 'INSURANCE',
  DocumentTypeEnum.panCard: 'PAN_CARD',
  DocumentTypeEnum.aadharCard: 'AADHAR_CARD',
  DocumentTypeEnum.vehiclePermit: 'VEHICLE_PERMIT',
  DocumentTypeEnum.pollutionCert: 'POLLUTION_CERT',
  DocumentTypeEnum.other: 'OTHER',
};

DriverDocumentRequest _$DriverDocumentRequestFromJson(
        Map<String, dynamic> json) =>
    DriverDocumentRequest(
      documentType:
          $enumDecode(_$DocumentTypeEnumEnumMap, json['document_type']),
      documentNumber: json['document_number'] as String?,
      documentUrl: json['document_url'] as String,
      expiryDate: json['expiry_date'] == null
          ? null
          : DateTime.parse(json['expiry_date'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$DriverDocumentRequestToJson(
        DriverDocumentRequest instance) =>
    <String, dynamic>{
      'document_type': _$DocumentTypeEnumEnumMap[instance.documentType]!,
      'document_number': instance.documentNumber,
      'document_url': instance.documentUrl,
      'expiry_date': instance.expiryDate?.toIso8601String(),
      'notes': instance.notes,
    };

DocumentUpdateRequest _$DocumentUpdateRequestFromJson(
        Map<String, dynamic> json) =>
    DocumentUpdateRequest(
      documentNumber: json['document_number'] as String?,
      documentUrl: json['document_url'] as String,
      expiryDate: json['expiry_date'] == null
          ? null
          : DateTime.parse(json['expiry_date'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$DocumentUpdateRequestToJson(
        DocumentUpdateRequest instance) =>
    <String, dynamic>{
      'document_number': instance.documentNumber,
      'document_url': instance.documentUrl,
      'expiry_date': instance.expiryDate?.toIso8601String(),
      'notes': instance.notes,
    };

PatchedDocumentUpdateRequest _$PatchedDocumentUpdateRequestFromJson(
        Map<String, dynamic> json) =>
    PatchedDocumentUpdateRequest(
      documentNumber: json['document_number'] as String?,
      documentUrl: json['document_url'] as String?,
      expiryDate: json['expiry_date'] == null
          ? null
          : DateTime.parse(json['expiry_date'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$PatchedDocumentUpdateRequestToJson(
        PatchedDocumentUpdateRequest instance) =>
    <String, dynamic>{
      'document_number': instance.documentNumber,
      'document_url': instance.documentUrl,
      'expiry_date': instance.expiryDate?.toIso8601String(),
      'notes': instance.notes,
    };

BulkDocumentUploadRequest _$BulkDocumentUploadRequestFromJson(
        Map<String, dynamic> json) =>
    BulkDocumentUploadRequest(
      documents: (json['documents'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$BulkDocumentUploadRequestToJson(
        BulkDocumentUploadRequest instance) =>
    <String, dynamic>{
      'documents': instance.documents,
    };

FileUploadRequest _$FileUploadRequestFromJson(Map<String, dynamic> json) =>
    FileUploadRequest(
      file: json['file'] as String,
      subfolder: json['subfolder'] as String?,
    );

Map<String, dynamic> _$FileUploadRequestToJson(FileUploadRequest instance) =>
    <String, dynamic>{
      'file': instance.file,
      'subfolder': instance.subfolder,
    };

FileUpload _$FileUploadFromJson(Map<String, dynamic> json) => FileUpload(
      file: json['file'] as String,
      subfolder: json['subfolder'] as String?,
    );

Map<String, dynamic> _$FileUploadToJson(FileUpload instance) =>
    <String, dynamic>{
      'file': instance.file,
      'subfolder': instance.subfolder,
    };
