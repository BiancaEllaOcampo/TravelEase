import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../utils/user_app_drawer.dart';
import '../splash_screen.dart';

class UserViewDocumentWithAIPage extends StatefulWidget {
  final String documentName;
  final String country;

  const UserViewDocumentWithAIPage({
    super.key,
    required this.documentName,
    required this.country,
  });

  @override
  State<UserViewDocumentWithAIPage> createState() =>
      _UserViewDocumentWithAIPageState();
}

class _UserViewDocumentWithAIPageState
    extends State<UserViewDocumentWithAIPage> {
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  String documentStatus = 'pending';
  String documentUrl = '';
  Map<String, dynamic> extractedData = {};
  String aiFeedback = '';
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _loadDocumentData();
  }

  Future<void> _loadDocumentData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        final checklists = data?['checklists'] ?? {};
        
        // Use sanitized keys (lowercase_with_underscores)
        final sanitizedCountry = widget.country.toLowerCase().replaceAll(' ', '_');
        final sanitizedDocName = widget.documentName.toLowerCase().replaceAll(' ', '_');
        
        final countryChecklist = checklists[sanitizedCountry] ?? {};
        final documentData = countryChecklist[sanitizedDocName] ?? {};

        setState(() {
          documentStatus = documentData['status'] ?? 'pending';
          documentUrl = documentData['url'] ?? '';
          extractedData = documentData['extractedData'] ?? {};
          aiFeedback = documentData['aiFeedback'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading document: $e')),
        );
      }
    }
  }

  void _handleReupload() async {
    try {
      // Show dialog to choose between camera or gallery
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Re-upload ${widget.documentName}',
              style: const TextStyle(fontFamily: 'Kumbh Sans'),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFF348AA7)),
                  title: const Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF348AA7)),
                  title: const Text('Take a Photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );

      if (source == null) return;

      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Show loading
      setState(() {
        _isUploading = true;
      });

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Create a reference to the storage location
      final String sanitizedDocName = widget.documentName.replaceAll(' ', '_').toLowerCase();
      final String sanitizedCountry = widget.country.replaceAll(' ', '_').toLowerCase();
      final String fileName = '${sanitizedDocName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final Reference storageRef = _storage
          .ref()
          .child('user_documents')
          .child(currentUser.uid)
          .child(sanitizedCountry)
          .child(sanitizedDocName)
          .child(fileName);

      // Upload file
      final File file = File(pickedFile.path);
      final UploadTask uploadTask = storageRef.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': currentUser.uid,
            'country': widget.country,
            'documentType': widget.documentName,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firestore with new document URL and status
      // Use sanitized key format (lowercase_with_underscores)
      await _firestore.collection('users').doc(currentUser.uid).update({
        'checklists.$sanitizedCountry.$sanitizedDocName.status': 'verifying',
        'checklists.$sanitizedCountry.$sanitizedDocName.url': downloadUrl,
        'checklists.$sanitizedCountry.$sanitizedDocName.updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state and reload data
      await _loadDocumentData();
      
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.documentName} uploaded successfully'),
            backgroundColor: const Color(0xFF34C759),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading document: ${e.toString()}'),
            backgroundColor: const Color(0xFFA54547),
          ),
        );
      }
    }
  }

  void _handleManualReview() {
    // TODO: Implement manual review request functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Manual review request submitted'),
        backgroundColor: Color(0xFF348AA7),
      ),
    );
  }

  Future<void> _handleViewOriginal() async {
    if (documentUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No document uploaded yet')),
      );
      return;
    }
    
    try {
      final Uri url = Uri.parse(documentUrl);
      
      // Check if URL can be launched
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Opens in browser
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open document'),
              backgroundColor: Color(0xFFA54547),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening document: ${e.toString()}'),
            backgroundColor: const Color(0xFFA54547),
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'verified':
        return const Color(0xFF34C759); // Green
      case 'needs_correction':
        return const Color(0xFFA54547); // Red
      case 'verifying':
        return const Color(0xFFFFA500); // Yellow/Orange
      case 'pending':
      default:
        return const Color(0xFF125E77); // Teal
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'verified':
        return 'Verified';
      case 'needs_correction':
        return 'Needs Correction';
      case 'verifying':
        return 'Verifying';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated
    if (_auth.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final statusColor = _getStatusColor(documentStatus);
    final statusLabel = _getStatusLabel(documentStatus);

    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      drawer: const UserAppDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF125E77),
                const Color(0xFF125E77).withOpacity(0.9),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 48, left: 22, right: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                // Title - Document Name
                Flexible(
                  child: Text(
                    widget.documentName,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kumbh Sans',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Menu Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 28,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFD9D9D9),
          ),

          // Main content - Full screen without card
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 90,
            child: RefreshIndicator(
              color: const Color(0xFF348AA7),
              onRefresh: _loadDocumentData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Check if document exists
                    if (documentUrl.isEmpty && extractedData.isEmpty)
                      // No document uploaded message - Full screen
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF348AA7).withOpacity(0.15),
                                    const Color(0xFF348AA7).withOpacity(0.05),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF348AA7).withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.cloud_upload_outlined,
                                size: 72,
                                color: Color(0xFF348AA7),
                              ),
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              'No Document Uploaded',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Kumbh Sans',
                                color: Color(0xFF125E77),
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Upload your ${widget.documentName} to get started with AI verification.',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Kumbh Sans',
                                color: Colors.grey.shade700,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF348AA7).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: ElevatedButton(
                                  onPressed: _handleReupload,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF348AA7),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.upload_file, size: 24, color: Colors.white),
                                      SizedBox(width: 12),
                                      Text(
                                        'Upload Document',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Kumbh Sans',
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Document details - Full screen layout
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status badge header with card background
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.info_outline,
                                      color: Color(0xFF348AA7),
                                      size: 22,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Document Status',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Kumbh Sans',
                                        color: Color(0xFF125E77),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: statusColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Kumbh Sans',
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Document image preview with enhanced card
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                height: 240,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  border: Border.all(
                                    color: const Color(0xFF348AA7).withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: documentUrl.isNotEmpty
                                    ? Image.network(
                                        documentUrl,
                                        fit: BoxFit.contain,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                          loadingProgress.expectedTotalBytes!
                                                      : null,
                                                  color: const Color(0xFF348AA7),
                                                  strokeWidth: 3,
                                                ),
                                                const SizedBox(height: 12),
                                                const Text(
                                                  'Loading...',
                                                  style: TextStyle(
                                                    fontFamily: 'Kumbh Sans',
                                                    color: Color(0xFF348AA7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: const [
                                                Icon(
                                                  Icons.broken_image_outlined,
                                                  size: 48,
                                                  color: Color(0xFFA54547),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Failed to load image',
                                                  style: TextStyle(
                                                    fontFamily: 'Kumbh Sans',
                                                    color: Color(0xFFA54547),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.image_outlined,
                                              size: 72,
                                              color: Color(0xFF348AA7),
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              'No preview available',
                                              style: TextStyle(
                                                fontFamily: 'Kumbh Sans',
                                                color: Color(0xFF348AA7),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Extracted Data section with enhanced card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.text_snippet_outlined,
                                      color: Color(0xFF348AA7),
                                      size: 22,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Extracted Data',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Kumbh Sans',
                                        color: Color(0xFF125E77),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Extracted data fields - customize based on document type
                                _buildExtractedDataFields(),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // AI Feedback section with enhanced styling
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: aiFeedback.isNotEmpty && documentStatus == 'needs_correction'
                                    ? const Color(0xFFFFD700).withOpacity(0.4)
                                    : const Color(0xFF34C759).withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  aiFeedback.isNotEmpty && documentStatus == 'needs_correction'
                                      ? Icons.info_outline
                                      : Icons.check_circle_outline,
                                  color: aiFeedback.isNotEmpty && documentStatus == 'needs_correction'
                                      ? const Color(0xFFB8860B)
                                      : const Color(0xFF34C759),
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: aiFeedback.isNotEmpty
                                      ? RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontFamily: 'Kumbh Sans',
                                              color: Colors.black87,
                                              height: 1.5,
                                            ),
                                            children: [
                                              const TextSpan(
                                                text: 'AI Feedback: ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF125E77),
                                                ),
                                              ),
                                              TextSpan(text: aiFeedback),
                                            ],
                                          ),
                                        )
                                      : const Text(
                                          'AI Feedback: No issues detected. Your document looks good!',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontFamily: 'Kumbh Sans',
                                            color: Colors.black87,
                                            height: 1.5,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),

                          // AI Limitation Notice (if document contains sensitive info)
                          if (documentStatus == 'needs_correction' && 
                              aiFeedback.toLowerCase().contains('sorry'))
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3CD),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFFD700), width: 1),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.security,
                                    color: Color(0xFFB8860B),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: const Text(
                                      'This document contains sensitive personal information. Our AI couldn\'t analyze it due to privacy policies, but don\'t worry - our admin team will manually review and verify it for you.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'Kumbh Sans',
                                        color: Color(0xFF333333),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 28),

                          // Action buttons with enhanced design
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF348AA7).withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: _handleReupload,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF348AA7),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    icon: const Icon(Icons.upload_file, size: 22, color: Colors.white),
                                    label: const Text(
                                      'Re-upload',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Kumbh Sans',
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: OutlinedButton.icon(
                                    onPressed: _handleViewOriginal,
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      side: const BorderSide(
                                        color: Color(0xFF348AA7),
                                        width: 2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.open_in_new,
                                      color: Color(0xFF348AA7),
                                      size: 22,
                                    ),
                                    label: const Text(
                                      'View Full',
                                      style: TextStyle(
                                        color: Color(0xFF348AA7),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Kumbh Sans',
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14), // Space between button rows
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF348AA7).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _handleManualReview, //no function for now shhhhhhhh,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF348AA7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.person_search, size: 22, color: Colors.white),
                              label: const Text(
                                'Request Manual Review',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Kumbh Sans',
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          ),

          // Bottom help links
          Positioned(
            bottom: 30,
            left: 28,
            right: 28,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    // Handle Need Help navigation
                  },
                  child: const Text(
                    'Need Help?',
                    style: TextStyle(
                      color: Color(0xFF348AA7),
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Kumbh Sans',
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Handle Send a Ticket navigation
                  },
                  child: const Text(
                    'Send a Ticket',
                    style: TextStyle(
                      color: Color(0xFF348AA7),
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Kumbh Sans',
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (_isUploading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF348AA7),
                      strokeWidth: 4,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Uploading document...',
                        style: TextStyle(
                          color: Color(0xFF125E77),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Kumbh Sans',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExtractedDataFields() {
    // If no extracted data exists, show placeholder text
    if (extractedData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.hourglass_empty,
              color: Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Waiting for AI analysis...\nData will appear here once processed.',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Kumbh Sans',
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Customize extracted data based on document type
    if (widget.documentName == 'Flight Ticket') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataField('Passenger', extractedData['passenger'] ?? 'Not available'),
          _buildDataField('Airline', extractedData['airline'] ?? 'Not available'),
          _buildDataField('Departure Airport',
              extractedData['departure'] ?? 'Not available'),
          _buildDataField('Arrival Airport',
              extractedData['arrival'] ?? 'Not available'),
          _buildDataField('Booking Code', extractedData['bookingCode'] ?? 'Not available'),
        ],
      );
    } else if (widget.documentName == 'Valid Passport') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataField('Passport Number', extractedData['passportNumber'] ?? 'Not available'),
          _buildDataField('Full Name', extractedData['fullName'] ?? 'Not available'),
          _buildDataField('Nationality', extractedData['nationality'] ?? 'Not available'),
          _buildDataField('Date of Birth', extractedData['dateOfBirth'] ?? 'Not available'),
          _buildDataField('Expiry Date', extractedData['expiryDate'] ?? 'Not available'),
        ],
      );
    } else if (widget.documentName == 'Visa') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataField('Visa Type', extractedData['visaType'] ?? 'Not available'),
          _buildDataField('Visa Number', extractedData['visaNumber'] ?? 'Not available'),
          _buildDataField('Full Name', extractedData['fullName'] ?? 'Not available'),
          _buildDataField('Valid From', extractedData['validFrom'] ?? 'Not available'),
          _buildDataField('Valid Until', extractedData['validUntil'] ?? 'Not available'),
        ],
      );
    } else if (widget.documentName == 'Proof of Accommodation') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataField('Hotel Name', extractedData['hotelName'] ?? 'Not available'),
          _buildDataField('Booking Reference', extractedData['bookingRef'] ?? 'Not available'),
          _buildDataField('Guest Name', extractedData['guestName'] ?? 'Not available'),
          _buildDataField('Check-in Date', extractedData['checkIn'] ?? 'Not available'),
          _buildDataField('Check-out Date', extractedData['checkOut'] ?? 'Not available'),
        ],
      );
    } else {
      // Generic extracted data for other document types
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDataField('Document Type', widget.documentName),
          _buildDataField('Status', documentStatus),
          if (extractedData.isNotEmpty)
            ...extractedData.entries.map((entry) =>
                _buildDataField(entry.key, entry.value.toString())),
        ],
      );
    }
  }

  Widget _buildDataField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF348AA7).withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Kumbh Sans',
                color: Color(0xFF125E77),
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Kumbh Sans',
                color: Colors.grey.shade800,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
