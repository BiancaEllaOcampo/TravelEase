import 'package:flutter/material.dart';
import '../../utils/admin_app_drawer.dart';

class AdminDocumentVerificationPage extends StatefulWidget {
	const AdminDocumentVerificationPage({Key? key}) : super(key: key);

	@override
	State<AdminDocumentVerificationPage> createState() => _AdminDocumentVerificationPageState();
}

class _AdminDocumentVerificationPageState extends State<AdminDocumentVerificationPage> {
	String selectedCountry = 'All Countries';
	String selectedStatus = 'All Status';
	String selectedDocType = 'All Types';
	String searchQuery = '';
	final TextEditingController searchController = TextEditingController();

	// This would be replaced by backend data in the future
	List<Map<String, dynamic>> entries = [
		{
			'name': 'Ellen Joe',
			'id': '2348',
			'type': 'Visa',
			'country': 'Japan',
			'date': 'May 10, 2025',
			'file': 'visa_ellen_joe.pdf',
			'status': 'Pending',
		},
		{
			'name': 'Vergil',
			'id': '7653',
			'type': 'Passport',
			'country': 'USA',
			'date': 'May 09, 2025',
			'file': 'passport_vergil.pdf',
			'status': 'Verified',
		},
		{
			'name': 'Momonga',
			'id': '3750',
			'type': 'Visa',
			'country': 'Japan',
			'date': 'May 08, 2025',
			'file': 'visa_momonga.pdf',
			'status': 'Needs Correction',
		},
		{
			'name': 'Ocelot',
			'id': '4138',
			'type': 'Flight Ticket',
			'country': 'France',
			'date': 'May 07, 2025',
			'file': 'ticket_ocelot.pdf',
			'status': 'Verified',
		},
		{
			'name': 'Malenia',
			'id': '1000',
			'type': 'Accommodation',
			'country': 'Poland',
			'date': 'May 06, 2025',
			'file': 'hotel_malenia.pdf',
			'status': 'Pending',
		},
	];

	// Placeholder for backend integration: call this to add a new entry
	void addEntry(Map<String, dynamic> entry) {
		setState(() {
			entries.insert(0, entry);
		});
		// TODO: Integrate with backend API
	}

	// Placeholder for backend integration: call this to update the list from backend
	void updateEntriesFromBackend(List<Map<String, dynamic>> newEntries) {
		setState(() {
			entries = newEntries;
		});
		// TODO: Integrate with backend API
	}

	List<Map<String, dynamic>> get filteredEntries {
		return entries.where((entry) {
			// Search filter
			if (searchQuery.isNotEmpty) {
				final matchesSearch = entry['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
					entry['id'].toLowerCase().contains(searchQuery.toLowerCase());
				if (!matchesSearch) return false;
			}
			
			// Country filter
			if (selectedCountry != 'All Countries' && entry['country'] != selectedCountry) {
				return false;
			}
			
			// Status filter
			if (selectedStatus != 'All Status' && entry['status'] != selectedStatus) {
				return false;
			}
			
			// Document type filter
			if (selectedDocType != 'All Types' && entry['type'] != selectedDocType) {
				return false;
			}
			
			return true;
		}).toList();
	}
	
	Color getStatusColor(String status) {
		switch (status) {
			case 'Verified':
				return const Color(0xFF34C759);
			case 'Pending':
				return const Color(0xFFFFA500);
			case 'Needs Correction':
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
				return Icons.book;
			case 'Flight Ticket':
				return Icons.flight;
			case 'Accommodation':
				return Icons.hotel;
			default:
				return Icons.description;
		}
	}

	// Helper method to build stat items
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
								// Stats Summary Card
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
											_buildStatItem('Total', entries.length.toString(), Icons.folder_open),
											Container(width: 1, height: 40, color: Colors.white30),
											_buildStatItem('Pending', entries.where((e) => e['status'] == 'Pending').length.toString(), Icons.schedule),
											Container(width: 1, height: 40, color: Colors.white30),
											_buildStatItem('Verified', entries.where((e) => e['status'] == 'Verified').length.toString(), Icons.check_circle),
										],
									),
								),
								
								const SizedBox(height: 24),
								
								// Filters Section
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
											
											// Filter dropdowns
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
											
											// Document type filter
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
																DropdownMenuItem(value: 'Passport', child: Text('Passport')),
																DropdownMenuItem(value: 'Flight Ticket', child: Text('Flight Ticket')),
																DropdownMenuItem(value: 'Accommodation', child: Text('Accommodation')),
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
								
								// Results Header
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
								
								// Documents List
								if (filteredEntries.isEmpty)
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
									...filteredEntries.map((entry) => Padding(
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
																		getDocTypeIcon(entry['type']),
																		size: 28,
																		color: Colors.white,
																	),
																),
																const SizedBox(width: 16),
																// Info
																Expanded(
																	child: Column(
																		crossAxisAlignment: CrossAxisAlignment.start,
																		children: [
																			Row(
																				children: [
																					Expanded(
																						child: Text(
																							entry['name'],
																							style: const TextStyle(
																								fontSize: 18,
																								fontWeight: FontWeight.bold,
																								fontFamily: 'Kumbh Sans',
																								color: Color(0xFF125E77),
																							),
																						),
																					),
																					Container(
																						padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
																						decoration: BoxDecoration(
																							color: getStatusColor(entry['status']),
																							borderRadius: BorderRadius.circular(6),
																						),
																						child: Text(
																							entry['status'],
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
																					Icon(Icons.badge, size: 14, color: Colors.grey[600]),
																					const SizedBox(width: 4),
																					Text(
																						'ID: ${entry['id']}',
																						style: TextStyle(
																							fontSize: 13,
																							fontFamily: 'Kumbh Sans',
																							color: Colors.grey[700],
																						),
																					),
																					const SizedBox(width: 16),
																					Icon(Icons.category, size: 14, color: Colors.grey[600]),
																					const SizedBox(width: 4),
																					Text(
																						entry['type'],
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
																					Icon(Icons.public, size: 14, color: Colors.grey[600]),
																					const SizedBox(width: 4),
																					Text(
																						entry['country'],
																						style: TextStyle(
																							fontSize: 13,
																							fontFamily: 'Kumbh Sans',
																							color: Colors.grey[700],
																						),
																					),
																					const SizedBox(width: 16),
																					Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
																					const SizedBox(width: 4),
																					Text(
																						entry['date'],
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
																					Icon(Icons.attach_file, size: 14, color: Colors.grey[600]),
																					const SizedBox(width: 4),
																					Expanded(
																						child: Text(
																							entry['file'],
																							style: TextStyle(
																								fontSize: 13,
																								fontFamily: 'Kumbh Sans',
																								color: Colors.grey[700],
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
														const SizedBox(height: 12),
														// Action buttons
														Row(
															children: [
																Expanded(
																	child: OutlinedButton.icon(
																		onPressed: () {
																			// TODO: View document
																		},
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
																		onPressed: () {
																			// TODO: Review/Edit document
																		},
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
									)),
								
								const SizedBox(height: 30),
							],
						),
					),
				),
			),
		);
	}
}
