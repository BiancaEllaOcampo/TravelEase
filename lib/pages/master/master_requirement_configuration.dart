import 'package:flutter/material.dart';
import '../../utils/master_app_drawer.dart';

class MasterReqConfigPage extends StatefulWidget {
	const MasterReqConfigPage({Key? key}) : super(key: key);

	@override
	State<MasterReqConfigPage> createState() => _MasterReqConfigPageState();
}

class _MasterReqConfigPageState extends State<MasterReqConfigPage> {
	String selectedCountry = 'Japan';
	
	// Placeholder data - will be replaced with Firebase in the future
	final List<Map<String, dynamic>> requirements = [
		{'id': '1', 'title': 'Valid Passport', 'status': true, 'mandatory': true},
		{'id': '2', 'title': 'Visa', 'status': false, 'mandatory': true},
		{'id': '3', 'title': 'Travel Insurance', 'status': true, 'mandatory': false},
		{'id': '4', 'title': 'Return Flight Ticket', 'status': false, 'mandatory': true},
		{'id': '5', 'title': 'Hotel Booking', 'status': true, 'mandatory': false},
	];

	// Helper method to get status color
	Color getStatusColor(bool isReady) {
		return isReady ? const Color(0xFF34C759) : const Color(0xFFA54547);
	}

	// Helper method to get status text
	String getStatusText(bool isReady) {
		return isReady ? 'Ready' : 'Not Ready';
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
										'Travel Requirements\nConfiguration',
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
										Icons.settings,
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
								// Country Selection Card
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
															Icons.public,
															color: Color(0xFF125E77),
															size: 20,
														),
													),
													const SizedBox(width: 12),
													const Text(
														'Select Country',
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
													borderRadius: BorderRadius.circular(8),
													border: Border.all(
														color: const Color(0xFF348AA7).withOpacity(0.3),
													),
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
														contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
													),
													style: const TextStyle(
														fontSize: 16,
														fontFamily: 'Kumbh Sans',
														color: Colors.black,
													),
												),
											),
										],
									),
								),
								
								const SizedBox(height: 24),
								
								// Requirements Header
								Row(
									children: [
										Container(
											padding: const EdgeInsets.all(8),
											decoration: BoxDecoration(
												color: const Color(0xFF125E77).withOpacity(0.1),
												borderRadius: BorderRadius.circular(8),
											),
											child: const Icon(
												Icons.checklist,
												color: Color(0xFF125E77),
												size: 20,
											),
										),
										const SizedBox(width: 12),
										const Text(
											'Requirements List',
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
												'${requirements.length} ${requirements.length == 1 ? 'item' : 'items'}',
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
								
								// Requirements List
								if (requirements.isEmpty)
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
													Icons.checklist_rtl,
													size: 64,
													color: Colors.grey[400],
												),
												const SizedBox(height: 16),
												Text(
													'No requirements configured',
													style: TextStyle(
														fontSize: 18,
														fontWeight: FontWeight.w600,
														color: Colors.grey[600],
														fontFamily: 'Kumbh Sans',
													),
												),
												const SizedBox(height: 8),
												Text(
													'Add a requirement to get started',
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
									...requirements.map((req) => Padding(
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
															children: [
																// Icon
																Container(
																	width: 48,
																	height: 48,
																	decoration: BoxDecoration(
																		gradient: const LinearGradient(
																			colors: [Color(0xFF348AA7), Color(0xFF125E77)],
																			begin: Alignment.topLeft,
																			end: Alignment.bottomRight,
																		),
																		borderRadius: BorderRadius.circular(10),
																	),
																	child: const Icon(
																		Icons.description,
																		size: 24,
																		color: Colors.white,
																	),
																),
																const SizedBox(width: 16),
																// Title and badges
																Expanded(
																	child: Column(
																		crossAxisAlignment: CrossAxisAlignment.start,
																		children: [
																			Text(
																				req['title'],
																				style: const TextStyle(
																					fontSize: 18,
																					fontWeight: FontWeight.bold,
																					fontFamily: 'Kumbh Sans',
																					color: Color(0xFF125E77),
																				),
																			),
																			const SizedBox(height: 8),
																			Row(
																				children: [
																					// ID badge
																					Container(
																						padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
																						decoration: BoxDecoration(
																							color: const Color(0xFF348AA7).withOpacity(0.1),
																							borderRadius: BorderRadius.circular(6),
																						),
																						child: Row(
																							mainAxisSize: MainAxisSize.min,
																							children: [
																								const Icon(
																									Icons.tag,
																									size: 12,
																									color: Color(0xFF348AA7),
																								),
																								const SizedBox(width: 4),
																								Text(
																									'ID: ${req['id']}',
																									style: const TextStyle(
																										fontSize: 12,
																										fontFamily: 'Kumbh Sans',
																										color: Color(0xFF348AA7),
																										fontWeight: FontWeight.w600,
																									),
																								),
																							],
																						),
																					),
																					const SizedBox(width: 8),
																					// Mandatory badge
																					if (req['mandatory'] == true)
																						Container(
																							padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
																							decoration: BoxDecoration(
																								color: const Color(0xFFFFA500).withOpacity(0.1),
																								borderRadius: BorderRadius.circular(6),
																							),
																							child: Row(
																								mainAxisSize: MainAxisSize.min,
																								children: const [
																									Icon(
																										Icons.priority_high,
																										size: 12,
																										color: Color(0xFFFFA500),
																									),
																									SizedBox(width: 4),
																									Text(
																										'Mandatory',
																										style: TextStyle(
																											fontSize: 12,
																											fontFamily: 'Kumbh Sans',
																											color: Color(0xFFFFA500),
																											fontWeight: FontWeight.w600,
																										),
																									),
																								],
																							),
																						),
																				],
																			),
																		],
																	),
																),
																// Status badge
																Container(
																	padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
																	decoration: BoxDecoration(
																		color: getStatusColor(req['status']),
																		borderRadius: BorderRadius.circular(8),
																	),
																	child: Text(
																		getStatusText(req['status']),
																		style: const TextStyle(
																			color: Colors.white,
																			fontSize: 14,
																			fontFamily: 'Kumbh Sans',
																			fontWeight: FontWeight.bold,
																		),
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
																			// TODO: Edit requirement
																		},
																		style: OutlinedButton.styleFrom(
																			foregroundColor: const Color(0xFF348AA7),
																			side: const BorderSide(color: Color(0xFF348AA7), width: 1.5),
																			shape: RoundedRectangleBorder(
																				borderRadius: BorderRadius.circular(8),
																			),
																			padding: const EdgeInsets.symmetric(vertical: 12),
																		),
																		icon: const Icon(Icons.edit, size: 18),
																		label: const Text(
																			'Edit',
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
																	child: OutlinedButton.icon(
																		onPressed: () {
																			// TODO: Toggle status
																		},
																		style: OutlinedButton.styleFrom(
																			foregroundColor: req['status'] ? const Color(0xFFA54547) : const Color(0xFF34C759),
																			side: BorderSide(
																				color: req['status'] ? const Color(0xFFA54547) : const Color(0xFF34C759),
																				width: 1.5,
																			),
																			shape: RoundedRectangleBorder(
																				borderRadius: BorderRadius.circular(8),
																			),
																			padding: const EdgeInsets.symmetric(vertical: 12),
																		),
																		icon: Icon(
																			req['status'] ? Icons.close : Icons.check,
																			size: 18,
																		),
																		label: Text(
																			req['status'] ? 'Disable' : 'Enable',
																			style: const TextStyle(
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
								
								const SizedBox(height: 24),
								
								// Action Buttons Section
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
															Icons.settings,
															color: Color(0xFF125E77),
															size: 20,
														),
													),
													const SizedBox(width: 12),
													const Text(
														'Actions',
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
											// Add Requirement Button
											SizedBox(
												width: double.infinity,
												height: 56,
												child: ElevatedButton.icon(
													onPressed: () {
														// TODO: Add requirement dialog
													},
													style: ElevatedButton.styleFrom(
														backgroundColor: const Color(0xFF34C759),
														foregroundColor: Colors.white,
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(10),
														),
														elevation: 0,
													),
													icon: const Icon(Icons.add_circle, size: 24),
													label: const Text(
														'Add Requirement',
														style: TextStyle(
															fontSize: 18,
															fontWeight: FontWeight.bold,
															fontFamily: 'Kumbh Sans',
														),
													),
												),
											),
											const SizedBox(height: 12),
											// Remove Requirement Button
											SizedBox(
												width: double.infinity,
												height: 56,
												child: ElevatedButton.icon(
													onPressed: () {
														// TODO: Remove requirement dialog
													},
													style: ElevatedButton.styleFrom(
														backgroundColor: const Color(0xFFA54547),
														foregroundColor: Colors.white,
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(10),
														),
														elevation: 0,
													),
													icon: const Icon(Icons.remove_circle, size: 24),
													label: const Text(
														'Remove Requirement',
														style: TextStyle(
															fontSize: 18,
															fontWeight: FontWeight.bold,
															fontFamily: 'Kumbh Sans',
														),
													),
												),
											),
											const SizedBox(height: 12),
											// Save Configuration Button
											SizedBox(
												width: double.infinity,
												height: 56,
												child: ElevatedButton.icon(
													onPressed: () {
														// TODO: Save configuration
													},
													style: ElevatedButton.styleFrom(
														backgroundColor: const Color(0xFF125E77),
														foregroundColor: Colors.white,
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(10),
														),
														elevation: 0,
													),
													icon: const Icon(Icons.save, size: 24),
													label: const Text(
														'Save Configuration',
														style: TextStyle(
															fontSize: 18,
															fontWeight: FontWeight.bold,
															fontFamily: 'Kumbh Sans',
														),
													),
												),
											),
										],
									),
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
