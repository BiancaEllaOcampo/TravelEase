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
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // UI state
  late Stream<QuerySnapshot> documentStream;
  String searchQuery = '';
  String selectedStatus = 'All Status';
  String selectedType = 'All Types';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize document stream for all documents in user checklists
    documentStream = _firestore
        .collectionGroup('checklists')
        .where('status', whereIn: ['pending', 'verifying', 'verified', 'needs_correction'])
        .snapshots();
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
    switch (type.toLowerCase()) {
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

  // Filter documents based on search and filters
  List<DocumentSnapshot> filterDocuments(List<DocumentSnapshot> docs) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Search filter
      final searchMatch = searchQuery.isEmpty ||
          (data['userName']?.toString().toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
          (data['documentId']?.toString().toLowerCase().contains(searchQuery.toLowerCase()) ?? false);

      // Status filter
      final statusMatch = selectedStatus == 'All Status' ||
          data['status']?.toString().toLowerCase() ==
              selectedStatus.toLowerCase().replaceAll(' ', '_');

      // Type filter  
      final typeMatch = selectedType == 'All Types' ||
          data['type']?.toString().toLowerCase() ==
              selectedType.toLowerCase().replaceAll(' ', '_');

      return searchMatch && statusMatch && typeMatch;
    }).toList();
  }

  // View document dialog
  Future<void> _viewDocument(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    
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
                    data['url'] ?? '',
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
  Future<void> _reviewDocument(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    String newStatus = data['status'] ?? 'pending';
    String feedback = '';

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
              DropdownButtonFormField<String>(
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
                onChanged: (value) {
                  setState(() {
                    newStatus = value!;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                maxLines: 3,
                onChanged: (value) => feedback = value,
                decoration: InputDecoration(
                  hintText: 'Add feedback or notes...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
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
                        await doc.reference.update({
                          'status': newStatus,
                          'feedback': feedback,
                          'reviewedAt': FieldValue.serverTimestamp(),
                          'reviewedBy': _auth.currentUser?.email,
                        });
                        if (mounted) Navigator.pop(context);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
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
      drawer: const AdminAppDrawer(),
      backgroundColor: const Color(0xFFD9D9D9),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedStatus,
                            items: ['All Status', 'Pending', 'Verifying', 'Verified', 'Needs Correction']
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
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
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedType,
                            items: ['All Types', 'Passport', 'Visa', 'Flight Ticket', 'Accommodation']
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ))
                                .toList(),
                            onChanged: (value) => setState(() => selectedType = value!),
                            decoration: InputDecoration(
                              labelText: 'Document Type',
                              filled: true,
                              fillColor: const Color(0xFFF8F9FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Documents Stream
              StreamBuilder<QuerySnapshot>(
                stream: documentStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: Color(0xFF348AA7),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Container(
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
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading documents',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                              fontFamily: 'Kumbh Sans',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please try again later',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              fontFamily: 'Kumbh Sans',
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final documents = filterDocuments(snapshot.data?.docs ?? []);

                  if (documents.isEmpty) {
                    return Container(
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
                    );
                  }

                  return Column(
                    children: [
                      // Stats header
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 16),
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
                            _buildStatItem(
                              'Total',
                              documents.length.toString(),
                              Icons.folder_open,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white30,
                            ),
                            _buildStatItem(
                              'Pending',
                              documents
                                  .where((doc) =>
                                      (doc.data() as Map<String, dynamic>)['status'] ==
                                      'pending')
                                  .length
                                  .toString(),
                              Icons.schedule,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white30,
                            ),
                            _buildStatItem(
                              'Verified',
                              documents
                                  .where((doc) =>
                                      (doc.data() as Map<String, dynamic>)['status'] ==
                                      'verified')
                                  .length
                                  .toString(),
                              Icons.check_circle,
                            ),
                          ],
                        ),
                      ),

                      // Document List
                      ...documents.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF348AA7).withOpacity(0.2),
                                width: 1.5,
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
                                      // Document type icon
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
                                          getDocTypeIcon(data['type'] ?? ''),
                                          size: 28,
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
                                                    data['userName'] ?? 'Unknown User',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Kumbh Sans',
                                                      color: Color(0xFF125E77),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: getStatusColor(data['status'] ?? ''),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    (data['status'] ?? 'pending')
                                                        .toUpperCase()
                                                        .replaceAll('_', ' '),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontFamily: 'Kumbh Sans',
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.badge,
                                                    size: 14, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Doc ID: ${data['documentId'] ?? 'Unknown'}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontFamily: 'Kumbh Sans',
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Icon(Icons.calendar_today,
                                                    size: 14, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  data['submittedAt']?.toString() ??
                                                      'Unknown Date',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontFamily: 'Kumbh Sans',
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.description,
                                                    size: 14, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  data['type']?.toString().toUpperCase() ??
                                                      'Unknown Type',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontFamily: 'Kumbh Sans',
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
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
                                        child: OutlinedButton.icon(
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
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                          ),
                                          icon: const Icon(Icons.visibility, size: 18),
                                          label: const Text(
                                            'View',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Kumbh Sans',
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _reviewDocument(doc),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF348AA7),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            elevation: 0,
                                          ),
                                          icon: const Icon(Icons.rate_review, size: 18),
                                          label: const Text(
                                            'Review',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Kumbh Sans',
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
                      }).toList(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}