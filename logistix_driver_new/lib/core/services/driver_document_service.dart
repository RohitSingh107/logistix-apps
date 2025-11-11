import '../network/api_client.dart';
import '../models/driver_document_model.dart';

class DriverDocumentService {
  final ApiClient _apiClient;

  DriverDocumentService(this._apiClient);

  /// Get all documents for the authenticated driver
  Future<List<DriverDocument>> getDocuments({String? documentType}) async {
    try {
      final queryParams = documentType != null ? {'document_type': documentType} : null;
      final response = await _apiClient.get(
        '/api/users/driver/documents/',
        queryParameters: queryParams,
      );
      
      final List<dynamic> documentsJson = response.data;
      return documentsJson
          .map((json) => DriverDocument.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching documents: $e');
      rethrow;
    }
  }

  /// Get a specific document by ID
  Future<DriverDocument> getDocument(int id) async {
    try {
      final response = await _apiClient.get('/api/users/driver/documents/$id/');
      return DriverDocument.fromJson(response.data);
    } catch (e) {
      print('Error fetching document: $e');
      rethrow;
    }
  }

  /// Upload a single document
  Future<DriverDocument> uploadDocument(DriverDocumentRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/users/driver/documents/upload/',
        data: request.toJson(),
      );
      return DriverDocument.fromJson(response.data);
    } catch (e) {
      print('Error uploading document: $e');
      rethrow;
    }
  }

  /// Update a document
  Future<DriverDocument> updateDocument(
    int id,
    DocumentUpdateRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        '/api/users/driver/documents/$id/',
        data: request.toJson(),
      );
      return DriverDocument.fromJson(response.data);
    } catch (e) {
      print('Error updating document: $e');
      rethrow;
    }
  }

  /// Delete a document
  Future<void> deleteDocument(int id) async {
    try {
      await _apiClient.delete('/api/users/driver/documents/$id/');
    } catch (e) {
      print('Error deleting document: $e');
      rethrow;
    }
  }

  /// Bulk upload documents
  Future<BulkDocumentUploadRequest> bulkUploadDocuments(
    BulkDocumentUploadRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/api/users/driver/documents/bulk-upload/',
        data: request.toJson(),
      );
      return BulkDocumentUploadRequest.fromJson(response.data);
    } catch (e) {
      print('Error bulk uploading documents: $e');
      rethrow;
    }
  }

  /// Get document statistics
  Future<Map<String, dynamic>> getDocumentStats() async {
    try {
      final response = await _apiClient.get('/api/users/driver/documents/stats/');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching document stats: $e');
      rethrow;
    }
  }

  /// Upload file and get URL
  Future<FileUpload> uploadFile(FileUploadRequest request) async {
    try {
      final response = await _apiClient.post(
        '/api/users/upload/',
        data: request.toJson(),
      );
      return FileUpload.fromJson(response.data);
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  /// Get vehicle RC documents (used for vehicle list)
  Future<List<DriverDocument>> getVehicleRcDocuments() async {
    return getDocuments(documentType: 'VEHICLE_RC');
  }

  /// Get license documents
  Future<List<DriverDocument>> getLicenseDocuments() async {
    return getDocuments(documentType: 'LICENSE');
  }

  /// Check if driver has verified vehicle RC documents
  Future<bool> hasVerifiedVehicles() async {
    try {
      final vehicleRcs = await getVehicleRcDocuments();
      return vehicleRcs.any((doc) => doc.isVerified);
    } catch (e) {
      print('Error checking verified vehicles: $e');
      return false;
    }
  }
}
