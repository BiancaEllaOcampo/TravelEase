import 'package:flutter/material.dart';
import '../../utils/admin_app_drawer.dart';

class AdminDocumentVerificationPage extends StatefulWidget {
	const AdminDocumentVerificationPage({Key? key}) : super(key: key);

	@override
	State<AdminDocumentVerificationPage> createState() => _AdminDocumentVerificationPageState();
}

class _AdminDocumentVerificationPageState extends State<AdminDocumentVerificationPage> {
	String selectedCountry = 'Japan';
	String searchQuery = '';
	final TextEditingController searchController = TextEditingController();

	// This would be replaced by backend data in the future
	List<Map<String, dynamic>> entries = [
		{
			'name': 'Ellen Joe',
			'id': '2348',
			'type': 'Visa',
			'date': 'May 10',
			'file': 'visa.pdf',
			'status': 'Verified',
		},
		{
			'name': 'Vergil',
			'id': '7653',
			'type': 'Visa',
			'date': 'May 10',
			'file': 'visa.pdf',
			'status': 'Verified',
		},
		{
			'name': 'Momonga',
			'id': '3750',
			'type': 'Visa',
			'date': 'May 10',
			'file': 'visa.pdf',
			'status': 'Invalid',
		},
		{
			'name': 'Ocelot',
			'id': '4138',
			'type': 'Visa',
			'date': 'May 10',
			'file': 'visa.pdf',
			'status': 'Verified',
		},
		{
			'name': 'Malenia',
			'id': '1000',
			'type': 'Visa',
			'date': 'May 10',
			'file': 'visa.pdf',
			'status': 'Verified',
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
		if (searchQuery.isEmpty) return entries;
		return entries.where((entry) =>
			entry['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
			entry['id'].toLowerCase().contains(searchQuery.toLowerCase())
		).toList();
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
			body: Stack(
				children: [
					// Main content
					Positioned(
						top: 20,
						left: 20,
						right: 20,
						bottom: 0,
						child: SingleChildScrollView(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									// Country dropdown
									const Text(
										'Country',
										style: TextStyle(
											fontSize: 16,
											fontWeight: FontWeight.w500,
											fontFamily: 'Kumbh Sans',
										),
									),
									const SizedBox(height: 6),
									Container(
										height: 44,
										decoration: BoxDecoration(
											color: Colors.white,
											borderRadius: BorderRadius.circular(8),
											border: Border.all(color: Colors.grey),
										),
										child: DropdownButtonFormField<String>(
											value: selectedCountry,
											items: const [
												DropdownMenuItem(value: 'Japan', child: Text('Japan')),
												DropdownMenuItem(value: 'USA', child: Text('USA')),
												DropdownMenuItem(value: 'France', child: Text('France')),
												DropdownMenuItem(value: 'Poland', child: Text('Poland')),
												DropdownMenuItem(value: 'Germany', child: Text('Germany')),
											],
											onChanged: (value) {
												setState(() {
													selectedCountry = value!;
												});
											},
											decoration: const InputDecoration(
												border: InputBorder.none,
												contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
											),
										),
									),
									const SizedBox(height: 12),
									// Search bar
									Container(
										height: 40,
										decoration: BoxDecoration(
											color: Colors.white,
											borderRadius: BorderRadius.circular(8),
											border: Border.all(color: Colors.grey.shade300),
										),
										child: Row(
											children: [
												Expanded(
													child: TextField(
														controller: searchController,
														onChanged: (value) {
															setState(() {
																searchQuery = value;
															});
														},
														decoration: const InputDecoration(
															hintText: '',
															border: InputBorder.none,
															contentPadding: EdgeInsets.symmetric(horizontal: 12),
														),
													),
												),
												Padding(
													padding: const EdgeInsets.only(right: 8),
													child: Icon(Icons.search, color: Colors.grey.shade600),
												),
											],
										),
									),
									const SizedBox(height: 12),
									// Entries list
									...filteredEntries.map((entry) => Padding(
										padding: const EdgeInsets.only(bottom: 16),
										child: Container(
											decoration: BoxDecoration(
												color: Colors.white,
												borderRadius: BorderRadius.circular(10),
												border: Border.all(color: Colors.grey.shade300),
											),
											child: Padding(
												padding: const EdgeInsets.all(12),
												child: Row(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														// Icon
														Container(
															width: 48,
															height: 48,
															decoration: BoxDecoration(
																color: const Color(0xFFD9D9D9),
																borderRadius: BorderRadius.circular(8),
																border: Border.all(color: Colors.grey.shade400),
															),
															child: const Icon(Icons.image, size: 32, color: Colors.grey),
														),
														const SizedBox(width: 12),
														// Info
														Expanded(
															child: Column(
																crossAxisAlignment: CrossAxisAlignment.start,
																children: [
																	Row(
																		children: [
																			Text(
																				entry['name'],
																				style: const TextStyle(
																					fontSize: 16,
																					fontWeight: FontWeight.bold,
																					fontFamily: 'Kumbh Sans',
																				),
																			),
																			const SizedBox(width: 8),
																			Container(
																				padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
																				decoration: BoxDecoration(
																					color: entry['status'] == 'Verified'
																							? Color(0xFF43B049)
																							: Color(0xFFA54547),
																					borderRadius: BorderRadius.circular(6),
																				),
																				child: Text(
																					entry['status'] == 'Verified' ? 'Verified' : 'Invalid',
																					style: const TextStyle(
																						color: Colors.white,
																						fontSize: 12,
																						fontFamily: 'Kumbh Sans',
																						fontWeight: FontWeight.w600,
																					),
																				),
																			),
																		],
																	),
																	const SizedBox(height: 2),
																	Text('ID: ${entry['id']}', style: const TextStyle(fontSize: 12, fontFamily: 'Kumbh Sans')),
																	Text('Type: ${entry['type']}', style: const TextStyle(fontSize: 12, fontFamily: 'Kumbh Sans')),
																	Text('Last update: ${entry['date']}', style: const TextStyle(fontSize: 12, fontFamily: 'Kumbh Sans')),
																	Text('File name: ${entry['file']}', style: const TextStyle(fontSize: 12, fontFamily: 'Kumbh Sans')),
																],
															),
														),
														const SizedBox(width: 12),
														// Edit button
														SizedBox(
															width: 60,
															height: 36,
															child: ElevatedButton(
																onPressed: () {
																	// TODO: Implement edit action
																},
																style: ElevatedButton.styleFrom(
																	backgroundColor: const Color(0xFF348AA7),
																	shape: RoundedRectangleBorder(
																		borderRadius: BorderRadius.circular(8),
																	),
																	padding: EdgeInsets.zero,
																),
																child: const Text(
																	'Edit',
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
										),
									)),
									const SizedBox(height: 30),
								],
							),
						),
					),
				],
			),
		);
	}
}
