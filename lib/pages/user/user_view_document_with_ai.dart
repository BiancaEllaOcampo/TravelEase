import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../dev/template_with_menu.dart';
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

  String documentStatus = 'pending';
  String documentUrl = '';
  Map<String, dynamic> extractedData = {};
  String aiFeedback = '';

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
        final countryChecklist = checklists[widget.country] ?? {};
        final documentData = countryChecklist[widget.documentName] ?? {};

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

  void _handleReupload() {
    // TODO: Implement file upload to Firebase Storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Re-upload functionality for ${widget.documentName} coming soon!')),
    );
  }

  void _handleViewOriginal() {
    // TODO: Implement viewing original document
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('View original document coming soon!')),
    );
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
      drawer: const TravelEaseDrawer(),
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
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                ),
                // Logo
                Container(
                  width: 67,
                  height: 58,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF348AA7),
                  ),
                  child: const Icon(
                    Icons.airplanemode_active,
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
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFD9D9D9),
          ),

          // Main content
          Positioned(
            top: 35,
            left: 28,
            right: 28,
            bottom: 100,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Check if document exists
                  if (documentUrl.isEmpty && extractedData.isEmpty)
                    // No document uploaded message
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'No Document Uploaded',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Kumbh Sans',
                                color: Color(0xFF125E77),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'You haven\'t uploaded a ${widget.documentName} yet.',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Kumbh Sans',
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _handleReupload,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF125E77),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Upload Document',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Kumbh Sans',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // Main white card with document details
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          // Image placeholder and status badge row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Document image placeholder
                              Container(
                                width: 140,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 60,
                                    color: Color(0xFF125E77),
                                  ),
                                ),
                              ),
                              // Status badge
                              Container(
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Text(
                                  statusLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Kumbh Sans',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Extracted Data section
                          const Text(
                            'Extracted Data',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Kumbh Sans',
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Extracted data fields - customize based on document type
                          _buildExtractedDataFields(),

                          // Divider line
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            height: 1,
                            color: Colors.grey.shade400,
                          ),

                          // AI Feedback
                          if (aiFeedback.isNotEmpty)
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Kumbh Sans',
                                  color: Colors.black,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'AI Feedback: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: aiFeedback),
                                ],
                              ),
                            )
                          else
                            const Text(
                              'AI Feedback: No issues detected',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Kumbh Sans',
                                color: Colors.black,
                              ),
                            ),

                          const SizedBox(height: 20),

                          // Re-upload button
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: _handleReupload,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF125E77),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Re-upload Ticket',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Kumbh Sans',
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // View original document button
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: OutlinedButton(
                              onPressed: _handleViewOriginal,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFF125E77),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: const Text(
                                'View Original Document',
                                style: TextStyle(
                                  color: Color(0xFF125E77),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Kumbh Sans',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
        ],
      ),
    );
  }

  Widget _buildExtractedDataFields() {
    // If no extracted data exists, show placeholder text
    if (extractedData.isEmpty) {
      return const Text(
        'No data extracted yet. Upload your document to see extracted information.',
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'Kumbh Sans',
          color: Colors.grey,
          fontStyle: FontStyle.italic,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 11,
          fontFamily: 'Kumbh Sans',
          color: Colors.black,
        ),
      ),
    );
  }
}
