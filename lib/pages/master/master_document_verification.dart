import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/master_app_drawer.dart';

class MasterDocumentVerificationPage extends StatefulWidget {
	const MasterDocumentVerificationPage({Key? key}) : super(key: key);

	@override
	State<MasterDocumentVerificationPage> createState() => _MasterDocumentVerificationPageState();
}

class _MasterDocumentVerificationPageState extends State<MasterDocumentVerificationPage> {
  String selectedCountry = 'All Countries';
  String selectedStatus = 'All Status';
  String selectedDocType = 'All Types';
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

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
                  Text(
                    'View Document',
                    style: const TextStyle(
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
                child: document['file'].toString().isNotEmpty
                    ? InteractiveViewer(
                        maxScale: 5.0,
                        child: Image.network(
                          document['file'],
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                    : null,
                                color: const Color(0xFF348AA7),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text(
                                'Error loading document',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontFamily: 'Kumbh Sans',
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Text(
                          'No document available',
                          style: TextStyle(
                            fontFamily: 'Kumbh Sans',
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

  Future<void> _showStatusUpdateDialog(Map<String, dynamic> document) async {
    String newStatus = document['status'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Update Document Status',
          style: TextStyle(
            color: Color(0xFF125E77),
            fontFamily: 'Kumbh Sans',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document: ${document['type']}',
              style: const TextStyle(
                fontFamily: 'Kumbh Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'User: ${document['name']}',
              style: const TextStyle(
                fontFamily: 'Kumbh Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
            if (document['manualReviewRequested'] == true)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA500).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFFA500)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.flag, size: 14, color: Color(0xFFFFA500)),
                    SizedBox(width: 4),
                    Text(
                      'Manual Review Requested',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Kumbh Sans',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFA500),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Select new status:',
              style: TextStyle(
                fontFamily: 'Kumbh Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF348AA7)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String>(
                value: newStatus,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'Verified', child: Text('Verified')),
                  DropdownMenuItem(value: 'Needs Correction', child: Text('Needs Correction')),
                ],
                onChanged: (value) {
                  newStatus = value!;
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF348AA7),
                fontFamily: 'Kumbh Sans',
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF348AA7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              try {
                String dbStatus = newStatus.toLowerCase().replaceAll(' ', '_');
                
                await FirebaseFirestore.instance
                    .doc(document['docPath'])
                    .update({
                      'checklists.${document['countryKey']}.${document['docTypeKey']}.status': dbStatus,
                      'checklists.${document['countryKey']}.${document['docTypeKey']}.updatedAt': FieldValue.serverTimestamp(),
                      'checklists.${document['countryKey']}.${document['docTypeKey']}.manualReviewRequested': false,
                      'checklists.${document['countryKey']}.${document['docTypeKey']}.reviewedBy': 'admin',
                    });
                
                if (mounted) {
                  Navigator.pop(context);
                  _showSnackBar('Document status updated successfully');
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  _showSnackBar('Error updating status: $e');
                }
              }
            },
            child: const Text(
              'Update',
              style: TextStyle(
                fontFamily: 'Kumbh Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Kumbh Sans'),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF348AA7),
      ),
    );
  }

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

  List<Map<String, dynamic>> entries = [];

	void addEntry(Map<String, dynamic> entry) {
		setState(() {
			entries.insert(0, entry);
		});
	}

	void updateEntriesFromBackend(List<Map<String, dynamic>> newEntries) {
		setState(() {
			entries = newEntries;
		});
	}

	List<Map<String, dynamic>> get filteredEntries {
		return entries.where((entry) {
			if (searchQuery.isNotEmpty) {
				final matchesSearch = entry['userName'].toLowerCase().contains(searchQuery.toLowerCase()) ||
					entry['userId'].toLowerCase().contains(searchQuery.toLowerCase());
				if (!matchesSearch) return false;
			}
			
			if (selectedCountry != 'All Countries' && entry['country'] != selectedCountry) {
				return false;
			}
			
			if (selectedStatus != 'All Status' && entry['status'] != selectedStatus) {
				return false;
			}
			
			if (selectedDocType != 'All Types' && entry['type'] != selectedDocType) {
				return false;
			}
			
			return true;
		}).toList();
	}

	Color getStatusColor(String status) {
		switch (status.toLowerCase()) {
			case 'verified':
				return const Color(0xFF34C759);
			case 'pending':
				return const Color(0xFF348AA7);
			case 'verifying':
				return const Color(0xFFFFA500);
			case 'needs_correction':
				return const Color(0xFFA54547);
			default:
				return Colors.grey;
		}
	}

	IconData getDocTypeIcon(String type) {
		switch (type) {
			case 'Visa':
				return Icons.credit_card;
			case 'Passport':
			case 'Valid Passport':
				return Icons.book;
			case 'Flight Ticket':
				return Icons.flight;
			case 'Accommodation':
			case 'Proof Of Accommodation':
				return Icons.hotel;
			default:
				return Icons.description;
		}
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
			backgroundColor: const Color(0xFFD9D9D9),
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
				child: SingleChildScrollView(
					child: Padding(
						padding: const EdgeInsets.all(24),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								StreamBuilder<List<Map<String, dynamic>>>(
									stream: documentStream,
									builder: (context, snapshot) {
										if (snapshot.connectionState == ConnectionState.waiting) {
											return Container(
												width: double.infinity,
												padding: const EdgeInsets.all(20),
												decoration: BoxDecoration(
													gradient: const LinearGradient(
														colors: [Color(0xFF348AA7), Color(0xFF125E77)],
														begin: Alignment.topLeft,
														end: Alignment.bottomRight,
													),
													borderRadius: BorderRadius.circular(12),
												),
												child: const Center(
													child: CircularProgressIndicator(color: Colors.white),
												),
											);
										}
										
										entries = snapshot.data ?? [];
										
										final totalDocs = entries.length;
										final pendingDocs = entries.where((e) => 
											e['status'] == 'pending' || e['status'] == 'verifying'
										).length;
										final verifiedDocs = entries.where((e) => 
											e['status'] == 'verified'
										).length;
										
										return Container(
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
													_buildStatItem('Total', totalDocs.toString(), Icons.folder_open),
													Container(width: 1, height: 40, color: Colors.white30),
													_buildStatItem('Pending', pendingDocs.toString(), Icons.schedule),
													Container(width: 1, height: 40, color: Colors.white30),
													_buildStatItem('Verified', verifiedDocs.toString(), Icons.check_circle),
												],
											),
										);
									},
								),
								
								const SizedBox(height: 24),
								
								Container(
									width: double.infinity,
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
													onChanged: (value) {
														setState(() {
															searchQuery = value;
														});
													},
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
																		items: const [
																			DropdownMenuItem(value: 'All Countries', child: Text('All Countries')),
																			DropdownMenuItem(value: 'Japan', child: Text('Japan')),
																			DropdownMenuItem(value: 'USA', child: Text('USA')),
																			DropdownMenuItem(value: 'France', child: Text('France')),
																			DropdownMenuItem(value: 'Poland', child: Text('Poland')),
																			DropdownMenuItem(value: 'Hong Kong', child: Text('Hong Kong')),
																		],
																		onChanged: (value) {
																			setState(() {
																				selectedCountry = value!;
																			});
																		},
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
																		items: const [
																			DropdownMenuItem(value: 'All Status', child: Text('All Status')),
																			DropdownMenuItem(value: 'Pending', child: Text('Pending')),
																			DropdownMenuItem(value: 'Verified', child: Text('Verified')),
																			DropdownMenuItem(value: 'Needs Correction', child: Text('Needs Correction')),
																		],
																		onChanged: (value) {
																			setState(() {
																				selectedStatus = value!;
																			});
																		},
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
															items: const [
																DropdownMenuItem(value: 'All Types', child: Text('All Types')),
																DropdownMenuItem(value: 'Visa', child: Text('Visa')),
																DropdownMenuItem(value: 'Valid Passport', child: Text('Valid Passport')),
																DropdownMenuItem(value: 'Flight Ticket', child: Text('Flight Ticket')),
																DropdownMenuItem(value: 'Proof Of Accommodation', child: Text('Proof Of Accommodation')),
															],
															onChanged: (value) {
																setState(() {
																	selectedDocType = value!;
																});
															},
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
												'${filteredEntries.length} ${filteredEntries.length == 1 ? 'document' : 'documents'}',
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
								
								StreamBuilder<List<Map<String, dynamic>>>(
									stream: documentStream,
									builder: (context, snapshot) {
										if (snapshot.connectionState == ConnectionState.waiting) {
											return Container(
												padding: const EdgeInsets.all(40),
												decoration: BoxDecoration(
													color: Colors.white,
													borderRadius: BorderRadius.circular(12),
												),
												child: const Center(
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
												),
												child: Center(
													child: Text(
														'Error loading documents: ${snapshot.error}',
														style: const TextStyle(
															color: Colors.red,
															fontFamily: 'Kumbh Sans',
														),
													),
												),
											);
										}
										
										entries = snapshot.data ?? [];
										
										if (filteredEntries.isEmpty) {
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
											children: filteredEntries.map((entry) => Padding(
												padding: const EdgeInsets.only(bottom: 12),
												child: Container(
													decoration: BoxDecoration(
														color: Colors.white,
														borderRadius: BorderRadius.circular(12),
														border: Border.all(
															color: entry['manualReviewRequested'] == true 
																? const Color(0xFFFFA500).withOpacity(0.5)
																: const Color(0xFF348AA7).withOpacity(0.2),
															width: entry['manualReviewRequested'] == true ? 2.5 : 1.5,
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
																				getDocTypeIcon(entry['type']),
																				size: 28,
																				color: Colors.white,
																			),
																		),
																		const SizedBox(width: 12),
																		Expanded(
																			child: Column(
																				crossAxisAlignment: CrossAxisAlignment.start,
																				children: [
																					Text(
																						entry['userName'],
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
																									'ID: ${entry['userId'].toString().substring(0, entry['userId'].toString().length > 15 ? 15 : entry['userId'].toString().length)}...',
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
																		Container(
																			padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
																			decoration: BoxDecoration(
																				color: getStatusColor(entry['status']),
																				borderRadius: BorderRadius.circular(6),
																			),
																			child: Text(
																				entry['status'].toString().replaceAll('_', ' ').toUpperCase(),
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
																// Document details - Updated to match admin page layout
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
																									entry['type'],
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
																									entry['submittedAt'] != null 
																										? (entry['submittedAt'] is Timestamp 
																												? (entry['submittedAt'] as Timestamp).toDate().toString().split(' ')[0]
																												: entry['submittedAt'].toString().split(' ')[0])
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
																									entry['country'],
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
																								entry['url'] != null && entry['url'].toString().isNotEmpty 
																									? Icons.check_circle 
																									: Icons.cancel,
																								size: 14,
																								color: entry['url'] != null && entry['url'].toString().isNotEmpty 
																									? Colors.green 
																									: Colors.grey[600],
																							),
																							const SizedBox(width: 6),
																							Expanded(
																								child: Text(
																									entry['url'] != null && entry['url'].toString().isNotEmpty 
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
																
																if (entry['manualReviewRequested'] == true)
																	Container(
																		margin: const EdgeInsets.only(top: 10),
																		padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
																				Icon(Icons.flag, size: 13, color: Color(0xFFFFA500)),
																				SizedBox(width: 6),
																				Text(
																					'Manual Review Requested',
																					style: TextStyle(
																						fontSize: 11,
																						fontFamily: 'Kumbh Sans',
																						fontWeight: FontWeight.bold,
																						color: Color(0xFFFFA500),
																					),
																				),
																			],
																		),
																	),
																
																const SizedBox(height: 12),
																Row(
																	children: [
																		Expanded(
																			child: OutlinedButton.icon(
																				onPressed: () => _viewDocument(entry),
																				style: OutlinedButton.styleFrom(
																					foregroundColor: const Color(0xFF348AA7),
																					side: const BorderSide(color: Color(0xFF348AA7), width: 1.5),
																					shape: RoundedRectangleBorder(
																						borderRadius: BorderRadius.circular(8),
																					),
																					padding: const EdgeInsets.symmetric(vertical: 12),
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
																				onPressed: () => _showStatusUpdateDialog(entry),
																				style: ElevatedButton.styleFrom(
																					backgroundColor: const Color(0xFF348AA7),
																					foregroundColor: Colors.white,
																					shape: RoundedRectangleBorder(
																						borderRadius: BorderRadius.circular(8),
																					),
																					padding: const EdgeInsets.symmetric(vertical: 12),
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
											)).toList(),
										);
									},
								),
								
								const SizedBox(height: 30),
							],
						),
					),
				),
			),
		);
	}
}