import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/user_app_drawer.dart';
import '../splash_screen.dart';
import 'user_view_document_with_ai.dart';

class UserDocumentsChecklistPage extends StatefulWidget {
  final String country;

  const UserDocumentsChecklistPage({
    super.key,
    required this.country,
  });

  @override
  State<UserDocumentsChecklistPage> createState() =>
      _UserDocumentsChecklistPageState();
}

class _UserDocumentsChecklistPageState extends State<UserDocumentsChecklistPage> {
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  final Map<String, List<String>> requirementsByCountry = {
    'japan': [
      'Flight Ticket',
      'Valid Passport',
      'Proof of Accommodation',
      'eTravel Registration (App)',
      'Visa',
    ],
    'hong_kong': [
      'Flight Ticket',
      'Valid Passport',
      'Proof of Accommodation',
      'eTravel Registration (App)',
    ],
    'south_korea': [
      'Flight Ticket',
      'Valid Passport',
      'Proof of Accommodation',
      'eTravel Registration (App)',
      'Visa',
    ],
    'singapore': [
      'Flight Ticket',
      'Valid Passport',
      'Proof of Accommodation',
      'eTravel Registration (App)',
      'Singapore Arrival Card (SGAC)',
    ],
    'china': [
      'Flight Ticket',
      'Valid Passport',
      'Proof of Accommodation',
      'eTravel Registration (App)',
      'Visa',
    ],
  };

  late Map<String, String> documentStatus; // 'pending', 'verifying', 'verified', 'needs_correction'
  late Map<String, String> documentUrls; // Storage URLs for uploaded documents
  
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _initializeDocumentStatus();
    _loadChecklistData();
  }

  /// Convert Firestore country key to display name
  /// Example: "hong_kong" -> "Hong Kong"
  String _getCountryDisplayName() {
    return widget.country
        .split('_')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _initializeDocumentStatus() {
    documentStatus = {};
    documentUrls = {};
    final requirements = requirementsByCountry[widget.country] ?? [];
    for (final req in requirements) {
      documentStatus[req] = 'pending';
      documentUrls[req] = '';
    }
  }

  Future<void> _loadChecklistData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        final checklists = data?['checklists'] ?? {};
        final countryChecklist = checklists[widget.country] ?? {};

        setState(() {
          documentStatus.clear();
          documentUrls.clear();
          final requirements = requirementsByCountry[widget.country] ?? [];
          for (final req in requirements) {
            final docKey = req.toLowerCase().replaceAll(' ', '_');
            documentStatus[req] = countryChecklist[docKey]?['status'] ?? 'pending';
            documentUrls[req] = countryChecklist[docKey]?['url'] ?? '';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading checklist: $e')),
        );
      }
    }
  }

  void _handleUpload(String documentName) async {
    try {
      // Show dialog to choose between camera or gallery
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Upload $documentName',
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
      // Path: user_documents/{userId}/{country}/{documentName}/{fileName}
      final String sanitizedDocName = documentName.replaceAll(' ', '_').toLowerCase();
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
            'documentType': documentName,
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
        'checklists.${sanitizedCountry}.$sanitizedDocName.status': 'verifying',
        'checklists.${sanitizedCountry}.$sanitizedDocName.url': downloadUrl,
        'checklists.${sanitizedCountry}.$sanitizedDocName.updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      setState(() {
        documentUrls[documentName] = downloadUrl;
        documentStatus[documentName] = 'verifying';
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$documentName uploaded successfully'),
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

    final requirements = requirementsByCountry[widget.country] ?? [];

    // Reserve vertical space for the bottom bar + system navigation inset so
    // the scrollable content isn't clipped underneath the bottom controls.
    final double bottomBarHeight = 60.0; // height of help links area (approx)
    final double bottomInset = MediaQuery.of(context).padding.bottom + bottomBarHeight;

    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      drawer: const UserAppDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          height: 130,
          color: const Color(0xFF125E77),
          child: Padding(
            padding: const EdgeInsets.only(top: 48, left: 22, right: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Menu Button (opens drawer)
                Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: const Icon(
                        Icons.menu,
                        color: Color(0xFFF3F3F3),
                        size: 50,
                      ),
                    );
                  },
                ),
                // Title
                const Flexible(
                  child: Text(
                    'Document Checklist',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                ),
                Container(
                  width: 67,
                  height: 58,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF348AA7),
                  ),
                  child: const Icon(
                    Icons.checklist,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background fill
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFD9D9D9),
          ),
          // Main content
          Positioned(
            top: 0,
            left: 28,
            right: 28,
            bottom: bottomInset.toDouble(),
            child: RefreshIndicator(
              color: const Color(0xFF348AA7),
              onRefresh: _loadChecklistData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Destination header
                    Row(
                      children: [
                        const Text(
                          'Destination: ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Kumbh Sans',
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          _getCountryDisplayName(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kumbh Sans',
                            color: Color(0xFF125E77),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Documents list
                    for (int i = 0; i < requirements.length; i++)
                      _buildDocumentCard(requirements[i]),
                  ],
                ),
              ),
            ),
          ),

          // Bottom help links section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color(0xFFD9D9D9),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Kumbh Sans',
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
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

  Widget _buildDocumentCard(String documentName) {
    final status = documentStatus[documentName] ?? 'pending';
    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(status);

    return GestureDetector(
      onTap: () {
        // Navigate to document details page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserViewDocumentWithAIPage(
              documentName: documentName,
              country: widget.country,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Document name
                  Expanded(
                    child: Text(
                      documentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Kumbh Sans',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Upload button and Status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Upload button
                  ElevatedButton(
                    onPressed: () => _handleUpload(documentName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF125E77),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Upload',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Kumbh Sans',
                      ),
                    ),
                  ),

                  // Status badge
                  Container(
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Text(
                      statusLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kumbh Sans',
                      ),
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
}
