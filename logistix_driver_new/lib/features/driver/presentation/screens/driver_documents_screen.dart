/// driver_documents_screen.dart - Driver Document Management Screen
/// 
/// Purpose:
/// - Display all driver documents with their verification status
/// - Allow uploading new documents
/// - Allow viewing and updating existing documents
/// - Show clear status indicators (Pending, Verified, Rejected)
/// 
/// Key Logic:
/// - Fetches all documents on load
/// - Groups documents by type
/// - Shows upload options for missing documents
/// - Handles file uploads and document updates
library;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../../../core/models/driver_document_model.dart';
import '../../../../core/services/driver_document_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../features/driver/domain/repositories/driver_repository.dart';
import '../../../../core/network/api_client.dart';

class DriverDocumentsScreen extends StatefulWidget {
  const DriverDocumentsScreen({super.key});

  @override
  State<DriverDocumentsScreen> createState() => _DriverDocumentsScreenState();
}

class _DriverDocumentsScreenState extends State<DriverDocumentsScreen> {
  final DriverDocumentService _documentService = serviceLocator<DriverDocumentService>();
  final DriverRepository _driverRepository = serviceLocator<DriverRepository>();
  final ApiClient _apiClient = serviceLocator<ApiClient>();
  List<DriverDocument> _documents = [];
  bool _isLoading = true;
  bool _isAvailable = false;
  String? _errorMessage;
  final Map<DocumentTypeEnum, bool> _uploadingStatus = {};

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await Future.wait([
      _loadDocuments(),
      _fetchDriverProfile(),
    ]);
  }

  Future<void> _fetchDriverProfile() async {
    try {
      final driver = await _driverRepository.getDriverProfile();
      if (mounted) {
        setState(() {
          _isAvailable = driver.isAvailable;
        });
        
        // If driver is verified, redirect to home screen
        if (driver.isVerified) {
          await _checkAndRedirectIfVerified();
          return;
        }
      }
    } catch (e) {
      debugPrint('Error fetching driver profile: $e');
    }
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final documents = await _documentService.getDocuments();
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
      
      // Check if driver is verified after loading documents
      await _checkAndRedirectIfVerified();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load documents: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAndRedirectIfVerified() async {
    try {
      final driver = await _driverRepository.getDriverProfile();
      if (mounted && driver.isVerified) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        });
      }
    } catch (e) {
      debugPrint('Error checking verification status: $e');
    }
  }

  Future<void> _updateDocument(DriverDocument document) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _uploadingStatus[document.documentType] = true;
      });

      final fileBytes = await File(image.path).readAsBytes();
      final base64File = base64Encode(fileBytes);
      
      final fileUploadRequest = FileUploadRequest(
        file: base64File,
        subfolder: 'driver_documents',
      );
      
      final fileUpload = await _documentService.uploadFile(fileUploadRequest);
      
      final updateRequest = DocumentUpdateRequest(
        documentNumber: document.documentNumber,
        documentUrl: fileUpload.file,
        expiryDate: document.expiryDate,
        notes: document.notes,
      );

      await _documentService.updateDocument(document.id, updateRequest);
      await _loadDocuments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getDocumentTypeName(document.documentType)} updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update document: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _uploadingStatus[document.documentType] = false;
      });
    }
  }

  Future<void> _showDocumentView(DocumentTypeEnum documentType, DriverDocument document) async {
    await showModalBottomSheet(
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
        padding: EdgeInsets.only(
          top: 17,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: ShapeDecoration(
                color: const Color(0xFFE6E6E6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              alignment: Alignment.center,
            ),
            // Title with verified badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_getDocumentTypeName(documentType)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: ShapeDecoration(
                    color: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'This document has been verified and cannot be edited',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Document Type
                    _buildReadOnlyField('Document Type', _getDocumentTypeName(documentType)),
                    const SizedBox(height: 16),
                    // Document Number
                    if (document.documentNumber != null && document.documentNumber!.isNotEmpty)
                      _buildReadOnlyField('Document Number', document.documentNumber!),
                    if (document.documentNumber != null && document.documentNumber!.isNotEmpty)
                      const SizedBox(height: 16),
                    // File URL
                    _buildReadOnlyField('File URL', document.documentUrl, isUrl: true),
                    const SizedBox(height: 16),
                    // Expiry Date
                    if (document.expiryDate != null)
                      _buildReadOnlyField('Expiry Date', _formatDateShort(document.expiryDate)),
                    if (document.expiryDate != null)
                      const SizedBox(height: 16),
                    // Notes
                    if (document.notes != null && document.notes!.isNotEmpty)
                      _buildReadOnlyField('Notes', document.notes!),
                    if (document.notes != null && document.notes!.isNotEmpty)
                      const SizedBox(height: 16),
                    // Verified At
                    if (document.verifiedAt != null)
                      _buildReadOnlyField('Verified At', _formatDateShort(document.verifiedAt)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Close Button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
              ),
              child: Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, {bool isUrl = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            border: Border.all(color: const Color(0xFFE6E6E6)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: isUrl
              ? InkWell(
                  onTap: () {
                    // Could open URL in browser if needed
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF111111),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Icon(Icons.open_in_new, size: 16, color: Color(0xFF9CA3AF)),
                    ],
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111111),
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _showDocumentForm(DocumentTypeEnum documentType) async {
    final existingDoc = _getDocumentByType(documentType);
    
    // If document is verified, show read-only view
    if (existingDoc != null && existingDoc.isVerified) {
      await _showDocumentView(documentType, existingDoc);
      return;
    }
    
    final documentNumberController = TextEditingController(text: existingDoc?.documentNumber ?? '');
    final fileUrlController = TextEditingController(text: existingDoc?.documentUrl ?? '');
    DateTime? selectedExpiryDate = existingDoc?.expiryDate;
    final notesController = TextEditingController(text: existingDoc?.notes ?? '');
    bool isSubmitting = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
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
          padding: EdgeInsets.only(
            top: 17,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: ShapeDecoration(
                  color: const Color(0xFFE6E6E6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                alignment: Alignment.center,
              ),
              // Title
              Text(
                '${existingDoc != null ? 'Update' : 'Upload'} ${_getDocumentTypeName(documentType)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Document Type (read-only)
                      Text(
                        'Document Type: ${_getDocumentTypeName(documentType)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Document Number
                      TextField(
                        controller: documentNumberController,
                        decoration: InputDecoration(
                          labelText: 'Document Number',
                          hintText: 'Enter document number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // File URL
                      TextField(
                        controller: fileUrlController,
                        decoration: InputDecoration(
                          labelText: 'File URL',
                          hintText: 'Enter file URL (e.g., https://example.com/file.pdf)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                          errorText: fileUrlController.text.isNotEmpty && !_validateUrl(fileUrlController.text) 
                              ? 'Please enter a valid URL' 
                              : null,
                        ),
                        keyboardType: TextInputType.url,
                        onChanged: (value) {
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(height: 16),
                      // Expiry Date
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedExpiryDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 3650)),
                          );
                          if (picked != null) {
                            setSheetState(() {
                              selectedExpiryDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Expiry Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            selectedExpiryDate != null
                                ? _formatDateShort(selectedExpiryDate)
                                : 'Select expiry date',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Notes
                      TextField(
                        controller: notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes (optional)',
                          hintText: 'Additional notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : () async {
                        // Validate required fields
                        if (fileUrlController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter a file URL'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setSheetState(() {
                          isSubmitting = true;
                        });

                        try {
                          final fileUrl = fileUrlController.text.trim();
                          
                          // Validate URL
                          if (!_validateUrl(fileUrl)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter a valid URL (must start with http:// or https://)'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            setSheetState(() {
                              isSubmitting = false;
                            });
                            return;
                          }

                          if (existingDoc != null) {
                            // Update existing document - manually create JSON with correct date format
                            final updateData = <String, dynamic>{
                              'document_url': fileUrl,
                            };
                            
                            if (documentNumberController.text.trim().isNotEmpty) {
                              updateData['document_number'] = documentNumberController.text.trim();
                            }
                            
                            if (selectedExpiryDate != null) {
                              updateData['expiry_date'] = _formatDateForApi(selectedExpiryDate);
                            }
                            
                            if (notesController.text.trim().isNotEmpty) {
                              updateData['notes'] = notesController.text.trim();
                            }
                            
                            final response = await _apiClient.put(
                              '/api/users/driver/documents/${existingDoc.id}/',
                              data: updateData,
      );
                          } else {
                            // Create new document - manually create JSON with correct date format
                            final documentData = <String, dynamic>{
                              'document_type': _getDocumentTypeEnumString(documentType),
                              'document_url': fileUrl,
                            };
                            
                            if (documentNumberController.text.trim().isNotEmpty) {
                              documentData['document_number'] = documentNumberController.text.trim();
                            }
                            
                            if (selectedExpiryDate != null) {
                              documentData['expiry_date'] = _formatDateForApi(selectedExpiryDate);
                            }
                            
                            if (notesController.text.trim().isNotEmpty) {
                              documentData['notes'] = notesController.text.trim();
                            }
                            
                            final response = await _apiClient.post(
                              '/api/users/driver/documents/upload/',
                              data: documentData,
                            );
                          }
                          
      await _loadDocuments();

      if (mounted) {
                            Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Document ${existingDoc != null ? 'updated' : 'uploaded'} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
                                content: Text('Failed to ${existingDoc != null ? 'update' : 'upload'} document: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
                        } finally {
                          if (mounted) {
                            setSheetState(() {
                              isSubmitting = false;
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        foregroundColor: Colors.white,
                      ),
                      child: isSubmitting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(existingDoc != null ? 'Update' : 'Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadDocument(DocumentTypeEnum documentType) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _uploadingStatus[documentType] = true;
      });

      final fileBytes = await File(image.path).readAsBytes();
      final base64File = base64Encode(fileBytes);
      
      final fileUploadRequest = FileUploadRequest(
        file: base64File,
        subfolder: 'driver_documents',
      );
      
      final fileUpload = await _documentService.uploadFile(fileUploadRequest);
      
      // Check if document already exists
      final existingDoc = _getDocumentByType(documentType);
      
      if (existingDoc != null) {
        // Update existing document
        final updateRequest = DocumentUpdateRequest(
          documentNumber: existingDoc.documentNumber,
          documentUrl: fileUpload.file,
          expiryDate: existingDoc.expiryDate,
          notes: existingDoc.notes,
        );
        await _documentService.updateDocument(existingDoc.id, updateRequest);
      } else {
        // Upload new document
        final documentRequest = DriverDocumentRequest(
          documentType: documentType,
          documentUrl: fileUpload.file,
        );
        await _documentService.uploadDocument(documentRequest);
      }
      
      await _loadDocuments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getDocumentTypeName(documentType)} ${existingDoc != null ? 'updated' : 'uploaded'} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload document: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _uploadingStatus[documentType] = false;
      });
    }
  }

  Future<void> _submitDocuments() async {
    // Check if all required documents are uploaded
    final license = _getDocumentByType(DocumentTypeEnum.license);
    final rc = _getDocumentByType(DocumentTypeEnum.vehicleRc);
    final insurance = _getDocumentByType(DocumentTypeEnum.insurance);

    if (license == null || rc == null || insurance == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
          content: Text('Please upload all required documents'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
        content: Text('Documents submitted for verification'),
            backgroundColor: Colors.green,
          ),
        );
  }

  DriverDocument? _getDocumentByType(DocumentTypeEnum type) {
    try {
      return _documents.firstWhere((doc) => doc.documentType == type);
    } catch (e) {
      return null;
    }
  }

  String _getDocumentTypeName(DocumentTypeEnum type) {
    switch (type) {
      case DocumentTypeEnum.license:
        return 'Driving License';
      case DocumentTypeEnum.vehicleRc:
        return 'RC (Registration Certificate)';
      case DocumentTypeEnum.insurance:
        return 'Insurance';
      case DocumentTypeEnum.panCard:
        return 'PAN Card';
      case DocumentTypeEnum.aadharCard:
        return 'Aadhaar Card';
      case DocumentTypeEnum.vehiclePermit:
        return 'Vehicle Permit';
      case DocumentTypeEnum.pollutionCert:
        return 'Pollution Certificate';
      case DocumentTypeEnum.other:
        return 'Other Document';
    }
  }

  IconData _getDocumentIcon(DocumentTypeEnum type) {
    switch (type) {
      case DocumentTypeEnum.license:
        return Icons.credit_card;
      case DocumentTypeEnum.vehicleRc:
        return Icons.directions_car;
      case DocumentTypeEnum.insurance:
        return Icons.shield;
      case DocumentTypeEnum.aadharCard:
        return Icons.badge;
      case DocumentTypeEnum.panCard:
        return Icons.account_circle;
      case DocumentTypeEnum.pollutionCert:
        return Icons.eco;
      case DocumentTypeEnum.vehiclePermit:
        return Icons.verified_user;
      default:
        return Icons.description;
    }
  }

  bool _validateUrl(String url) {
    if (url.isEmpty) return true; // Empty is OK for validation display
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  String _formatDateForApi(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateShort(DateTime? date) {
    if (date == null) return '';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getDocumentTypeEnumString(DocumentTypeEnum type) {
    switch (type) {
      case DocumentTypeEnum.license:
        return 'LICENSE';
      case DocumentTypeEnum.vehicleRc:
        return 'VEHICLE_RC';
      case DocumentTypeEnum.insurance:
        return 'INSURANCE';
      case DocumentTypeEnum.panCard:
        return 'PAN_CARD';
      case DocumentTypeEnum.aadharCard:
        return 'AADHAR_CARD';
      case DocumentTypeEnum.vehiclePermit:
        return 'VEHICLE_PERMIT';
      case DocumentTypeEnum.pollutionCert:
        return 'POLLUTION_CERT';
      case DocumentTypeEnum.other:
        return 'OTHER';
    }
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(0.00, 0.00),
                  end: Alignment(1.00, 1.00),
                  colors: [Color(0xFFFF6B00), Color(0xFFFF7A1A)],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(
                Icons.help_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Support',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111111),
                ),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need help with your documents?',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                color: Color(0xFF111111),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Our support team is here to help you with:',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                color: Color(0xFF9CA3AF),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Document upload issues\n• Verification status questions\n• Technical support\n• General inquiries',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                color: Color(0xFF111111),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Contact us at:\nsupport@logistix.com\nor call: +91-XXXXX-XXXXX',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                color: Color(0xFF111111),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                color: Color(0xFFFF6B00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
                : Column(
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
                                'Documents',
                                style: TextStyle(
                                  color: const Color(0xFF111111),
        fontSize: 18,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
      ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                                // Refresh Button
                                GestureDetector(
                                  onTap: () {
                                    _loadDocuments();
                                  },
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    child: const Icon(
                                      Icons.refresh,
                                      size: 22,
                                      color: Color(0xFF111111),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Support Button
                                GestureDetector(
                                  onTap: () {
                                    _showSupportDialog();
                                  },
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    child: const Icon(
                                      Icons.help_outline,
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
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              // Description
                              Text(
                                'Upload and manage your License, RC, and Insurance\nfor verification.',
                                style: TextStyle(
                                  color: const Color(0xFF9CA3AF),
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                      ),
                              ),
                              const SizedBox(height: 12),
                              // Verification Status Card
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
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.verified_user_outlined,
                                            size: 18,
                                            color: Color(0xFF111111),
                ),
                                          const SizedBox(width: 8),
                Text(
                                            'Verification Status',
                                            style: TextStyle(
                                              color: const Color(0xFF111111),
                                              fontSize: 15,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
            ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 9,
                                              vertical: 5,
                                            ),
                                            decoration: ShapeDecoration(
                                              color: const Color(0xFFF3F4F6),
                  shape: RoundedRectangleBorder(
                                                side: const BorderSide(
                                                  width: 1,
                                                  color: Color(0xFFE6E6E6),
                                                ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                                            child: Text(
                                              'KYC in progress',
                                              style: TextStyle(
                                                color: const Color(0xFF9CA3AF),
                                                fontSize: 12,
                                                fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                                            ),
            ),
          ],
        ),
      ),
                                    // License
                                    _buildDocumentItem(
      DocumentTypeEnum.license,
                                      _getDocumentByType(DocumentTypeEnum.license) != null
                                          ? '${_getDocumentByType(DocumentTypeEnum.license)!.documentNumber ?? 'N/A'}${_getDocumentByType(DocumentTypeEnum.license)!.expiryDate != null ? ' • Expires ${_formatDateShort(_getDocumentByType(DocumentTypeEnum.license)!.expiryDate)}' : ''}'
                                          : 'Not uploaded',
                                    ),
                                    // RC
                                    _buildDocumentItem(
      DocumentTypeEnum.vehicleRc,
                                      _getDocumentByType(DocumentTypeEnum.vehicleRc) != null
                                          ? '${_getDocumentByType(DocumentTypeEnum.vehicleRc)!.documentNumber ?? 'N/A'}'
                                          : 'Not uploaded',
                                    ),
                                    // Insurance
                                    _buildDocumentItem(
      DocumentTypeEnum.insurance,
                                      _getDocumentByType(DocumentTypeEnum.insurance) != null
                                          ? '${_getDocumentByType(DocumentTypeEnum.insurance)!.documentNumber ?? 'N/A'}${_getDocumentByType(DocumentTypeEnum.insurance)!.expiryDate != null ? ' • Expires ${_formatDateShort(_getDocumentByType(DocumentTypeEnum.insurance)!.expiryDate)}' : ''}'
                                          : 'Not uploaded',
                                    ),
                                    // Aadhaar Card
                                    _buildDocumentItem(
      DocumentTypeEnum.aadharCard,
                                      _getDocumentByType(DocumentTypeEnum.aadharCard) != null
                                          ? '${_getDocumentByType(DocumentTypeEnum.aadharCard)!.documentNumber ?? 'N/A'}${_getDocumentByType(DocumentTypeEnum.aadharCard)!.expiryDate != null ? ' • Expires ${_formatDateShort(_getDocumentByType(DocumentTypeEnum.aadharCard)!.expiryDate)}' : ''}'
                                          : 'Not uploaded',
                                    ),
                                    // PAN Card
                                    _buildDocumentItem(
                                      DocumentTypeEnum.panCard,
                                      _getDocumentByType(DocumentTypeEnum.panCard) != null
                                          ? '${_getDocumentByType(DocumentTypeEnum.panCard)!.documentNumber ?? 'N/A'}${_getDocumentByType(DocumentTypeEnum.panCard)!.expiryDate != null ? ' • Expires ${_formatDateShort(_getDocumentByType(DocumentTypeEnum.panCard)!.expiryDate)}' : ''}'
                                          : 'Not uploaded',
                                    ),
                                    // Vehicle Permit
                                    _buildDocumentItem(
                                      DocumentTypeEnum.vehiclePermit,
                                      _getDocumentByType(DocumentTypeEnum.vehiclePermit) != null
                                          ? '${_getDocumentByType(DocumentTypeEnum.vehiclePermit)!.documentNumber ?? 'N/A'}${_getDocumentByType(DocumentTypeEnum.vehiclePermit)!.expiryDate != null ? ' • Expires ${_formatDateShort(_getDocumentByType(DocumentTypeEnum.vehiclePermit)!.expiryDate)}' : ''}'
                                          : 'Not uploaded',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(
    DocumentTypeEnum type,
    String subtitle,
  ) {
    final document = _getDocumentByType(type);
    final isVerified = document?.isVerified ?? false;
    final isUploading = _uploadingStatus[type] ?? false;

    return GestureDetector(
      onTap: isVerified 
          ? () => _showDocumentView(type, document!)
          : () => _showDocumentForm(type),
      child: Container(
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
          child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
              _getDocumentIcon(type),
              size: 22,
              color: const Color(0xFF111111),
              ),
              const SizedBox(width: 12),
            Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                    _getDocumentTypeName(type),
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
            if (isUploading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
                ),
              )
            else if (document == null)
              // Add button for documents not uploaded
              GestureDetector(
                onTap: () => _showDocumentForm(type),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFF6B00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: ShapeDecoration(
                  color: isVerified
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFF3F4F6),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: isVerified
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFE6E6E6),
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  isVerified
                      ? 'Verified'
                      : 'Pending',
                  style: TextStyle(
                    color: isVerified
                        ? Colors.white
                        : const Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
              ),
              const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
        ElevatedButton(
              onPressed: _loadDocuments,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
              ),
            ],
          ),
        ),
    );
  }
}
