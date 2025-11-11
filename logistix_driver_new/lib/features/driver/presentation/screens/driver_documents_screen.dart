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
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/models/driver_document_model.dart';
import '../../../../core/services/driver_document_service.dart';
import '../../../../core/di/service_locator.dart';
import 'dart:convert';

class DriverDocumentsScreen extends StatefulWidget {
  const DriverDocumentsScreen({super.key});

  @override
  State<DriverDocumentsScreen> createState() => _DriverDocumentsScreenState();
}

class _DriverDocumentsScreenState extends State<DriverDocumentsScreen> {
  final DriverDocumentService _documentService = serviceLocator<DriverDocumentService>();
  List<DriverDocument> _documents = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Map<DocumentTypeEnum, bool> _uploadingStatus = {};

  @override
  void initState() {
    super.initState();
    _loadDocuments();
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
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load documents: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadDocument(DocumentTypeEnum documentType) async {
    try {
      // Pick image
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _uploadingStatus[documentType] = true;
      });

      // Upload file first to get URL
      // For now, we'll use the file path directly
      // In production, this should upload to a file server first
      // The API expects document_url to be a URL, so we need to upload the file first
      
      // Read file as base64 for now (API might accept this or need multipart)
      final fileBytes = await File(image.path).readAsBytes();
      final base64File = base64Encode(fileBytes);
      
      // Upload file to get URL
      final fileUploadRequest = FileUploadRequest(
        file: base64File, // API expects base64 encoded file
        subfolder: 'driver_documents',
      );
      
      final fileUpload = await _documentService.uploadFile(fileUploadRequest);
      
      // Create document request
      final documentRequest = DriverDocumentRequest(
        documentType: documentType,
        documentUrl: fileUpload.file,
      );

      // Upload document
      await _documentService.uploadDocument(documentRequest);

      // Reload documents
      await _loadDocuments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getDocumentTypeName(documentType)} uploaded successfully'),
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


  Future<void> _updateDocument(DriverDocument document) async {
    // Show update dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _UpdateDocumentDialog(document: document),
    );

    if (result == null) return;

    try {
      final updateRequest = DocumentUpdateRequest(
        documentNumber: result['document_number'] as String?,
        documentUrl: result['document_url'] as String,
        expiryDate: result['expiry_date'] as DateTime?,
        notes: result['notes'] as String?,
      );

      await _documentService.updateDocument(document.id, updateRequest);
      await _loadDocuments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document updated successfully'),
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
    }
  }

  Future<void> _deleteDocument(DriverDocument document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete this ${document.documentTypeDisplay}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _documentService.deleteDocument(document.id);
      await _loadDocuments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete document: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        return 'Vehicle RC';
      case DocumentTypeEnum.insurance:
        return 'Insurance';
      case DocumentTypeEnum.panCard:
        return 'PAN Card';
      case DocumentTypeEnum.aadharCard:
        return 'Aadhar Card';
      case DocumentTypeEnum.vehiclePermit:
        return 'Vehicle Permit';
      case DocumentTypeEnum.pollutionCert:
        return 'Pollution Certificate';
      case DocumentTypeEnum.other:
        return 'Other Document';
    }
  }

  Color _getStatusColor(bool isVerified) {
    return isVerified ? Colors.green : Colors.orange;
  }

  String _getStatusText(bool isVerified) {
    return isVerified ? 'Verified' : 'Pending Verification';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'My Documents',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildDocumentsList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadDocuments,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    final requiredDocuments = [
      DocumentTypeEnum.license,
      DocumentTypeEnum.vehicleRc,
      DocumentTypeEnum.insurance,
    ];

    final optionalDocuments = [
      DocumentTypeEnum.panCard,
      DocumentTypeEnum.aadharCard,
      DocumentTypeEnum.vehiclePermit,
      DocumentTypeEnum.pollutionCert,
    ];

    return RefreshIndicator(
      onRefresh: _loadDocuments,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          _buildSectionHeader('Required Documents'),
          const SizedBox(height: 12),
          ...requiredDocuments.map((type) => _buildDocumentCard(type)),
          const SizedBox(height: 24),
          _buildSectionHeader('Additional Documents'),
          const SizedBox(height: 12),
          ...optionalDocuments.map((type) => _buildDocumentCard(type)),
          const SizedBox(height: 16),
          // Add Other Document option
          _buildAddOtherDocumentCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildDocumentCard(DocumentTypeEnum type) {
    final document = _getDocumentByType(type);
    final isUploading = _uploadingStatus[type] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDocumentTypeName(type),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (document != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(document.isVerified)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusText(document.isVerified),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(document.isVerified),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (document != null)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 8),
                            Text('View'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'update',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Update'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'view') {
                        _viewDocument(document);
                      } else if (value == 'update') {
                        _updateDocument(document);
                      } else if (value == 'delete') {
                        _deleteDocument(document);
                      }
                    },
                  ),
              ],
            ),
            if (document != null) ...[
              const SizedBox(height: 12),
              if (document.documentNumber != null)
                Text(
                  'Number: ${document.documentNumber}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              if (document.expiryDate != null)
                Text(
                  'Expires: ${_formatDate(document.expiryDate!)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isUploading
                    ? null
                    : document == null
                        ? () => _uploadDocument(type)
                        : () => _updateDocument(document),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        document == null ? 'Upload' : 'Update',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOtherDocumentCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _uploadDocument(DocumentTypeEnum.other),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Add Other Document',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewDocument(DriverDocument document) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(document.documentTypeDisplay),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: Image.network(
                document.documentUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text('Failed to load image'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _UpdateDocumentDialog extends StatefulWidget {
  final DriverDocument document;

  const _UpdateDocumentDialog({required this.document});

  @override
  State<_UpdateDocumentDialog> createState() => _UpdateDocumentDialogState();
}

class _UpdateDocumentDialogState extends State<_UpdateDocumentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _documentNumberController;
  late TextEditingController _notesController;
  DateTime? _expiryDate;
  String? _newDocumentUrl;

  @override
  void initState() {
    super.initState();
    _documentNumberController = TextEditingController(
      text: widget.document.documentNumber ?? '',
    );
    _notesController = TextEditingController(
      text: widget.document.notes ?? '',
    );
    _expiryDate = widget.document.expiryDate;
    _newDocumentUrl = widget.document.documentUrl;
  }

  @override
  void dispose() {
    _documentNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickNewDocument() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    // Upload new document
    // This would need to be implemented with actual file upload
    setState(() {
      _newDocumentUrl = image.path; // Temporary, should be uploaded URL
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update ${widget.document.documentTypeDisplay}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _documentNumberController,
                decoration: const InputDecoration(
                  labelText: 'Document Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _expiryDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) {
                    setState(() {
                      _expiryDate = date;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _expiryDate != null
                        ? _formatDate(_expiryDate!)
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickNewDocument,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload New Document'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'document_number': _documentNumberController.text.isEmpty
                    ? null
                    : _documentNumberController.text,
                'document_url': _newDocumentUrl,
                'expiry_date': _expiryDate,
                'notes': _notesController.text.isEmpty
                    ? null
                    : _notesController.text,
              });
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

