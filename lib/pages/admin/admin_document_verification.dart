import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/admin_app_drawer.dart';

class AdminDocumentVerificationPage extends StatefulWidget {
  const AdminDocumentVerificationPage({Key? key}) : super(key: key);

  @override
  State<AdminDocumentVerificationPage> createState() => _AdminDocumentVerificationPageState();
}

class _AdminDocumentVerificationPageState extends State<AdminDocumentVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // UI state
  String selectedCountry = 'All Countries';
  String selectedStatus = 'All Status';
  String selectedDocType = 'All Types';
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  // Get document stream with proper data structure
  Stream<List<Map<String, dynamic>>> get documentStream {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> allDocuments = [];
      
      for (var userDoc in snapshot.docs) {
        final userData = userDoc.data();
        final checklists = userData['checklists'] as Map<String, dynamic>? ?? {};
        final userId = userDoc.id;
        final userName = userData['fullName'] ?? 'Unknown User';
        
        checklists.forEach((country, countryData) {
          if (countryData is Map<String, dynamic>) {
            countryData.forEach((docType, docData) {
              if (docData is Map<String, dynamic>) {
                String displayDocType = docType
                    .split('_')
                    .map((word) => word.isNotEmpty 
                        ? word[0].toUpperCase() + word.substring(1) 
                        : '')
                    .join(' ');
                
                String displayCountry = country
                    .split('_')
                    .map((word) => word.isNotEmpty 
                        ? word[0].toUpperCase() + word.substring(1) 
                        : '')
                    .join(' ');
                
                allDocuments.add({
                  'userId': userId,
                  'userName': userName,
                  'country': displayCountry,
                  'type': displayDocType,
                  'documentId': docType,
                  'status': docData['status'] ?? 'pending',
                  'url': docData['url'] ?? '',
                  'submittedAt': docData['submittedAt'] ?? DateTime.now(),
                  'feedback': docData['feedback'],
                  'reviewedAt': docData['reviewedAt'],
                  'reviewedBy': docData['reviewedBy'],
                });
              }
            });
          }
        });
      }
      
      // Sort by submission date descending
      allDocuments.sort((a, b) {
        final aDate = a['submittedAt'];
        final bDate = b['submittedAt'];
        return bDate.compareTo(aDate);
      });
      
      return allDocuments;
    });
  }

  // Filter documents based on search and filters
  List<Map<String, dynamic>> filterDocuments(List<Map<String, dynamic>> docs) {
    return docs.where((doc) {
      // Search filter
      final searchMatch = searchQuery.isEmpty ||
          doc['userName'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          doc['documentId'].toString().toLowerCase().contains(searchQuery.toLowerCase());

      // Status filter
      final statusMatch = selectedStatus == 'All Status' ||
          doc['status'].toString().toLowerCase() == selectedStatus.toLowerCase().replaceAll(' ', '_');

      // Country filter
      final countryMatch = selectedCountry == 'All Countries' ||
          doc['country'].toString() == selectedCountry;

      // Document type filter
      final typeMatch = selectedDocType == 'All Types' ||
          doc['type'].toString() == selectedDocType;

      return searchMatch && statusMatch && countryMatch && typeMatch;
    }).toList();
  }

  // Helper functions
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF348AA7);
      case 'verifying':
        return const Color(0xFFFFA500);
      case 'verified':
        return const Color(0xFF34C759);
      case 'needs_correction':
        return const Color(0xFFA54547);
      default:
        return Colors.grey;
    }
  }

  IconData getDocTypeIcon(String type) {
    switch (type.toLowerCase().replaceAll(' ', '_')) {
      case 'passport':
        return Icons.badge;
      case 'visa':
        return Icons.verified_user;
      case 'flight_ticket':
        return Icons.flight;
      case 'accommodation':
        return Icons.hotel;
      default:
        return Icons.description;
    }
  }

  // View document dialog
  Future<void> _viewDocument(Map<String, dynamic> document) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'View Document',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF125E77),
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    document['url'],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color(0xFF348AA7),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading image',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: 'Kumbh Sans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Review document dialog with status update
  Future<void> _reviewDocument(Map<String, dynamic> document) async {
    String newStatus = document['status'];
    String feedback = document['feedback'] ?? '';
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Review Document',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF125E77),
                  fontFamily: 'Kumbh Sans',
                ),
              ),
              const SizedBox(height: 24),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF348AA7).withOpacity(0.3),
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: newStatus,
                          items: ['pending', 'verifying', 'verified', 'needs_correction']
                              .map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(
                                      status.replaceAll('_', ' ').toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Kumbh Sans',
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => newStatus = value!),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: feedback,
                        maxLines: 3,
                        onChanged: (value) => feedback = value,
                        decoration: InputDecoration(
                          hintText: 'Add feedback or notes...',
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Update document status in Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(document['userId'])
                            .collection('checklists')
                            .doc(document['country'].toLowerCase().replaceAll(' ', '_'))
                            .update({
                              'status': newStatus,
                              'feedback': feedback,
                              'reviewedAt': FieldValue.serverTimestamp(),
                              'reviewedBy': _auth.currentUser?.email,
                            });
                            
                        if (mounted) Navigator.pop(context);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Document review updated successfully'),
                              backgroundColor: Color(0xFF348AA7),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Error updating document review: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF348AA7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save Review'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminAppDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          height: 130,
          color: const Color(0xFF125E77),
          child: Padding(
            padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
            child: Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu, color: Colors.white, size: 32),
                  ),
                ),
                const SizedBox(width: 24),
                const Expanded(
                  child: Text(
                    'Document Verification',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFD9D9D9),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: documentStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF348AA7)),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final documents = filterDocuments(snapshot.data ?? []);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Filters Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Search bar
                            TextField(
                              controller: searchController,
                              onChanged: (value) => setState(() => searchQuery = value),
                              decoration: InputDecoration(
                                hintText: 'Search documents...',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: const Color(0xFFF8F9FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Filter dropdowns
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: DropdownButtonFormField<String>(
                                    value: selectedStatus,
                                    items: ['All Status', 'Pending', 'Verifying', 'Verified', 'Needs Correction']
                                        .map((status) => DropdownMenuItem(
                                              value: status,
                                              child: Text(
                                                status,
                                                style: const TextStyle(fontSize: 14),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) => setState(() => selectedStatus = value!),
                                    decoration: InputDecoration(
                                      labelText: 'Status',
                                      filled: true,
                                      fillColor: const Color(0xFFF8F9FA),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 200,
                                  child: DropdownButtonFormField<String>(
                                    value: selectedDocType,
                                    items: ['All Types', 'Passport', 'Visa', 'Flight Ticket', 'Accommodation']
                                        .map((type) => DropdownMenuItem(
                                              value: type,
                                              child: Text(
                                                type,
                                                style: const TextStyle(fontSize: 14),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) => setState(() => selectedDocType = value!),
                                    decoration: InputDecoration(
                                      labelText: 'Document Type',
                                      filled: true,
                                      fillColor: const Color(0xFFF8F9FA),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Documents List
                      if (documents.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF348AA7).withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No documents found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                  fontFamily: 'Kumbh Sans',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your filters',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                  fontFamily: 'Kumbh Sans',
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final doc = documents[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Document type icon
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF348AA7),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              getDocTypeIcon(doc['type']),
                                              size: 24,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          // Document info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        doc['userName'] ?? 'Unknown User',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color(0xFF125E77),
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: getStatusColor(doc['status']),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        (doc['status'] ?? 'pending')
                                                            .toUpperCase()
                                                            .replaceAll('_', ' '),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Doc ID: ${doc['documentId']}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[600],
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  doc['country'],
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[600],
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Action buttons
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _viewDocument(doc),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: const Color(0xFF348AA7),
                                                side: const BorderSide(
                                                  color: Color(0xFF348AA7),
                                                  width: 1.5,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                'View',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () => _reviewDocument(doc),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF348AA7),
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                'Review',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
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
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}