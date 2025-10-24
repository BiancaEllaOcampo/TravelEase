import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/master_app_drawer.dart';

class MasterDocumentVerificationPage extends StatefulWidget {
  const MasterDocumentVerificationPage({Key? key}) : super(key: key);

  @override
  State<MasterDocumentVerificationPage> createState() => _MasterDocumentVerificationPageState();
}

class _MasterDocumentVerificationPageState extends State<MasterDocumentVerificationPage> {
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
                  'countryKey': country,
                  'docTypeKey': docType,
                  'status': docData['status'] ?? 'pending',
                  'url': docData['url'] ?? '',
                  'submittedAt': docData['submittedAt'] ?? DateTime.now(),
                  'feedback': docData['feedback'],
                  'reviewedAt': docData['reviewedAt'],
                  'reviewedBy': docData['reviewedBy'],
                  'manualReviewRequested': docData['manualReviewRequested'] ?? false,
                  'manualReviewRequestedAt': docData['manualReviewRequestedAt'],
                });
              }
            });
          }
        });
      }
      
      // Sort by submission date descending (newest first), then by userId for stability
      allDocuments.sort((a, b) {
        final aDate = a['submittedAt'];
        final bDate = b['submittedAt'];
        if (aDate == null && bDate == null) return a['userId'].toString().compareTo(b['userId'].toString());
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        
        final dateComparison = bDate.compareTo(aDate);
        if (dateComparison != 0) return dateComparison;
        
        // If dates are equal, sort by userId for consistent ordering
        return a['userId'].toString().compareTo(b['userId'].toString());
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

      // Country filter - normalize both sides for comparison
      final countryMatch = selectedCountry == 'All Countries' ||
          doc['country'].toString().toLowerCase().replaceAll('_', ' ') == 
              selectedCountry.toLowerCase();

      // Document type filter - normalize both sides for comparison
      final typeMatch = selectedDocType == 'All Types' ||
          doc['type'].toString().toLowerCase().replaceAll('_', ' ').replaceAll('  ', ' ') == 
              selectedDocType.toLowerCase();

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
                        // Update document status in Firestore using dot notation
                        // Checklists are stored as nested maps, not subcollections
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(document['userId'])
                            .update({
                              'checklists.${document['countryKey']}.${document['docTypeKey']}.status': newStatus,
                              'checklists.${document['countryKey']}.${document['docTypeKey']}.feedback': feedback,
                              'checklists.${document['countryKey']}.${document['docTypeKey']}.reviewedAt': FieldValue.serverTimestamp(),
                              'checklists.${document['countryKey']}.${document['docTypeKey']}.reviewedBy': _auth.currentUser?.email,
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kumbh Sans',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontFamily: 'Kumbh Sans',
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MasterAppDrawer(),
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
                const Flexible(
                  child: Text(
                    'Documents Verification\nQueue',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
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

            final allDocuments = snapshot.data ?? [];
            final documents = filterDocuments(allDocuments);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF348AA7), Color(0xFF125E77)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Total', allDocuments.length.toString(), Icons.folder_open),
                        Container(width: 1, height: 40, color: Colors.white30),
                        _buildStatItem(
                          'Pending',
                          allDocuments.where((e) => 
                            e['status'] == 'pending' || e['status'] == 'verifying'
                          ).length.toString(),
                          Icons.schedule,
                        ),
                        Container(width: 1, height: 40, color: Colors.white30),
                        _buildStatItem(
                          'Verified',
                          allDocuments.where((e) => e['status'] == 'verified').length.toString(),
                          Icons.check_circle,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF125E77).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.filter_list,
                                color: Color(0xFF125E77),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Filters',
                              style: TextStyle(
                                color: Color(0xFF125E77),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Kumbh Sans',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF348AA7).withOpacity(0.3),
                            ),
                          ),
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) => setState(() => searchQuery = value),
                            decoration: const InputDecoration(
                              hintText: 'Search by name or ID...',
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(Icons.search, color: Color(0xFF348AA7)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Filter dropdowns in row layout
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Country',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Kumbh Sans',
                                      color: Color(0xFF125E77),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F9FA),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF348AA7).withOpacity(0.3),
                                      ),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: selectedCountry,
                                      items: ['All Countries', 'Japan', 'Hong Kong', 'South Korea', 'Singapore', 'China']
                                          .map((country) => DropdownMenuItem(
                                                value: country,
                                                child: Text(
                                                  country,
                                                  style: const TextStyle(fontSize: 14, fontFamily: 'Kumbh Sans'),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (value) => setState(() => selectedCountry = value!),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      style: const TextStyle(fontSize: 14, fontFamily: 'Kumbh Sans', color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Status',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Kumbh Sans',
                                      color: Color(0xFF125E77),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F9FA),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF348AA7).withOpacity(0.3),
                                      ),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: selectedStatus,
                                      items: ['All Status', 'Pending', 'Verifying', 'Verified', 'Needs Correction']
                                          .map((status) => DropdownMenuItem(
                                                value: status,
                                                child: Text(
                                                  status,
                                                  style: const TextStyle(fontSize: 14, fontFamily: 'Kumbh Sans'),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ))
                                          .toList(),
                                      onChanged: (value) => setState(() => selectedStatus = value!),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      style: const TextStyle(fontSize: 14, fontFamily: 'Kumbh Sans', color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Document Type',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Kumbh Sans',
                                color: Color(0xFF125E77),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF348AA7).withOpacity(0.3),
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: selectedDocType,
                                items: ['All Types', 'Flight Ticket', 'Valid Passport', 'Visa', 'Proof Of Accommodation', 'Etravel Registration (App)']
                                    .map((type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(
                                            type,
                                            style: const TextStyle(fontSize: 14, fontFamily: 'Kumbh Sans'),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) => setState(() => selectedDocType = value!),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                style: const TextStyle(fontSize: 14, fontFamily: 'Kumbh Sans', color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Documents Queue Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF125E77).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.description,
                          color: Color(0xFF125E77),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Documents Queue',
                        style: TextStyle(
                          color: Color(0xFF125E77),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kumbh Sans',
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF348AA7).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${documents.length} ${documents.length == 1 ? 'document' : 'documents'}',
                          style: const TextStyle(
                            color: Color(0xFF348AA7),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Kumbh Sans',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

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
                              border: Border.all(
                                color: doc['manualReviewRequested'] == true 
                                  ? const Color(0xFFFFA500)
                                  : const Color(0xFF348AA7).withOpacity(0.2),
                                width: doc['manualReviewRequested'] == true ? 2.5 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
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
                                      // Document type icon with gradient
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF348AA7), Color(0xFF125E77)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          getDocTypeIcon(doc['type']),
                                          size: 28,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Document info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              doc['userName'] ?? 'Unknown User',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Kumbh Sans',
                                                color: Color(0xFF125E77),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.badge, size: 12, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'ID: ${doc['userId'].toString().substring(0, doc['userId'].toString().length > 15 ? 15 : doc['userId'].toString().length)}...',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontFamily: 'Kumbh Sans',
                                                      color: Colors.grey[600],
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Status badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: getStatusColor(doc['status']),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          doc['status'].toString().replaceAll('_', ' ').toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontFamily: 'Kumbh Sans',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Document details - Updated to show more information
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.event_note, size: 14, color: Colors.grey[600]),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    doc['type'],
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey[800],
                                                      fontFamily: 'Kumbh Sans',
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    doc['submittedAt'] != null 
                                                      ? (doc['submittedAt'] is Timestamp 
                                                          ? (doc['submittedAt'] as Timestamp).toDate().toString().split(' ')[0]
                                                          : doc['submittedAt'].toString().split(' ')[0])
                                                      : 'Unknown date',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[700],
                                                      fontFamily: 'Kumbh Sans',
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    doc['country'],
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey[800],
                                                      fontFamily: 'Kumbh Sans',
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  doc['url'] != null && doc['url'].toString().isNotEmpty 
                                                    ? Icons.check_circle 
                                                    : Icons.cancel,
                                                  size: 14,
                                                  color: doc['url'] != null && doc['url'].toString().isNotEmpty 
                                                    ? Colors.green 
                                                    : Colors.grey[600],
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    doc['url'] != null && doc['url'].toString().isNotEmpty 
                                                      ? 'Has document' 
                                                      : 'No doc',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[700],
                                                      fontFamily: 'Kumbh Sans',
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Manual Review Requested badge
                                  if (doc['manualReviewRequested'] == true)
                                    Container(
                                      margin: const EdgeInsets.only(top: 12),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFA500).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: const Color(0xFFFFA500),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.flag, size: 14, color: Color(0xFFFFA500)),
                                          SizedBox(width: 8),
                                          Text(
                                            'Manual Review Requested',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'Kumbh Sans',
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFFA500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  
                                  const SizedBox(height: 12),
                                  // Action buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _viewDocument(doc),
                                          icon: const Icon(Icons.remove_red_eye, size: 18),
                                          label: const Text(
                                            'View',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Kumbh Sans',
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: const Color(0xFF348AA7),
                                            elevation: 0,
                                            side: const BorderSide(color: Color(0xFF348AA7), width: 1.5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _reviewDocument(doc),
                                          icon: const Icon(Icons.edit, size: 18),
                                          label: const Text(
                                            'Review',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Kumbh Sans',
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF348AA7),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}