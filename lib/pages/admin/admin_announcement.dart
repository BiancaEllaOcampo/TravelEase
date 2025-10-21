import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../utils/admin_app_drawer.dart';

class AdminAnnouncementPage extends StatefulWidget {
	const AdminAnnouncementPage({Key? key}) : super(key: key);

	@override
	State<AdminAnnouncementPage> createState() => _AdminAnnouncementPageState();
}

class _AdminAnnouncementPageState extends State<AdminAnnouncementPage> {
	final TextEditingController titleController = TextEditingController();
	final TextEditingController contentController = TextEditingController();

	// Post announcement to Firebase
	Future<void> _postAnnouncement() async {
		if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Please fill in all fields'),
					backgroundColor: Color(0xFFA54547),
					duration: Duration(seconds: 2),
				),
			);
			return;
		}

		try {
			// Create a new document with auto-generated ID
			final docRef = FirebaseFirestore.instance.collection('announcements').doc();
			
			// Save with id, title, content, and date fields (matching master)
			await docRef.set({
				'id': docRef.id,
				'title': titleController.text.trim(),
				'content': contentController.text.trim(),
				'date': FieldValue.serverTimestamp(),
			});

			titleController.clear();
			contentController.clear();

			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(
						content: Text('Announcement posted successfully'),
						backgroundColor: Color(0xFF34C759),
						duration: Duration(seconds: 2),
					),
				);
			}
		} catch (e) {
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text('Error posting announcement: $e'),
						backgroundColor: const Color(0xFFA54547),
						duration: const Duration(seconds: 2),
					),
				);
			}
		}
	}

	// Placeholder for backend integration: view an announcement
	void viewAnnouncement(String announcementId) {
		// Fetch the announcement data from Firestore
		FirebaseFirestore.instance
			.collection('announcements')
			.doc(announcementId)
			.get()
			.then((doc) {
				if (!doc.exists) {
					ScaffoldMessenger.of(context).showSnackBar(
						const SnackBar(
							content: Text('Announcement not found'),
							backgroundColor: Color(0xFFA54547),
						),
					);
					return;
				}

				final data = doc.data() as Map<String, dynamic>;
				final date = data['date'] as Timestamp?;
				final dateStr = date != null
					? DateFormat('MMM dd, yyyy - hh:mm a').format(date.toDate())
					: 'No date';

				showDialog(
					context: context,
					builder: (context) => Dialog(
						shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
						child: Container(
							constraints: const BoxConstraints(maxWidth: 500),
							padding: const EdgeInsets.all(24),
							child: Column(
								mainAxisSize: MainAxisSize.min,
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									// Header
									Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										children: [
											const Text(
												'Announcement Details',
												style: TextStyle(
													fontSize: 20,
													fontWeight: FontWeight.bold,
													fontFamily: 'Kumbh Sans',
													color: Color(0xFF125E77),
												),
											),
											IconButton(
												onPressed: () => Navigator.pop(context),
												icon: const Icon(Icons.close),
											),
										],
									),
									const Divider(height: 24),
									// ID
									Text(
										'ID: ${data['id'] ?? 'N/A'}',
										style: const TextStyle(
											fontSize: 12,
											fontFamily: 'Kumbh Sans',
											color: Colors.grey,
											fontWeight: FontWeight.w500,
										),
									),
									const SizedBox(height: 16),
									// Title
									Text(
										data['title'] ?? 'Untitled',
										style: const TextStyle(
											fontSize: 18,
											fontWeight: FontWeight.bold,
											fontFamily: 'Kumbh Sans',
											color: Color(0xFF125E77),
										),
									),
									const SizedBox(height: 8),
									// Date
									Text(
										dateStr,
										style: const TextStyle(
											fontSize: 13,
											fontFamily: 'Kumbh Sans',
											color: Colors.grey,
										),
									),
									const SizedBox(height: 16),
									// Content
									Text(
										data['content'] ?? '',
										style: const TextStyle(
											fontSize: 14,
											fontFamily: 'Kumbh Sans',
											color: Colors.black87,
											height: 1.5,
										),
									),
									const SizedBox(height: 24),
									// Close button
									Align(
										alignment: Alignment.centerRight,
										child: ElevatedButton(
											onPressed: () => Navigator.pop(context),
											style: ElevatedButton.styleFrom(
												backgroundColor: const Color(0xFF348AA7),
												foregroundColor: Colors.white,
												shape: RoundedRectangleBorder(
													borderRadius: BorderRadius.circular(8),
												),
												padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
											),
											child: const Text(
												'Close',
												style: TextStyle(
													fontFamily: 'Kumbh Sans',
													fontWeight: FontWeight.bold,
												),
											),
										),
									),
								],
							),
						),
					),
				);
			});
	}

	// Placeholder for backend integration: edit an announcement
	void editAnnouncement(String announcementId) {
		// TODO: Implement edit logic (e.g., show edit form)
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
										'Announcements',
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
								// Create New Announcement Card
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
															Icons.add_circle_outline,
															color: Color(0xFF125E77),
															size: 24,
														),
													),
													const SizedBox(width: 12),
													const Text(
														'Create New Announcement',
														style: TextStyle(
															color: Color(0xFF125E77),
															fontSize: 20,
															fontWeight: FontWeight.bold,
															fontFamily: 'Kumbh Sans',
														),
													),
												],
											),
											const SizedBox(height: 20),
											// Title field
											const Text(
												'Title',
												style: TextStyle(
													fontSize: 14,
													fontWeight: FontWeight.w600,
													fontFamily: 'Kumbh Sans',
													color: Color(0xFF125E77),
												),
											),
											const SizedBox(height: 8),
											Container(
												decoration: BoxDecoration(
													color: const Color(0xFFF8F9FA),
													borderRadius: BorderRadius.circular(8),
													border: Border.all(color: const Color(0xFF348AA7).withOpacity(0.3)),
												),
												child: TextField(
													controller: titleController,
													style: const TextStyle(
														fontSize: 14,
														fontFamily: 'Kumbh Sans',
													),
													decoration: const InputDecoration(
														border: InputBorder.none,
														contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
														hintText: 'Enter announcement title...',
														hintStyle: TextStyle(color: Colors.grey),
													),
												),
											),
											const SizedBox(height: 16),
											// Content field
											const Text(
												'Content',
												style: TextStyle(
													fontSize: 14,
													fontWeight: FontWeight.w600,
													fontFamily: 'Kumbh Sans',
													color: Color(0xFF125E77),
												),
											),
											const SizedBox(height: 8),
											Container(
												height: 110,
												decoration: BoxDecoration(
													color: const Color(0xFFF8F9FA),
													borderRadius: BorderRadius.circular(8),
													border: Border.all(color: const Color(0xFF348AA7).withOpacity(0.3)),
												),
												child: TextField(
													controller: contentController,
													maxLines: null,
													expands: true,
													style: const TextStyle(
														fontSize: 14,
														fontFamily: 'Kumbh Sans',
													),
													decoration: const InputDecoration(
														border: InputBorder.none,
														contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
														hintText: 'Enter announcement content...',
														hintStyle: TextStyle(color: Colors.grey),
													),
												),
											),
											const SizedBox(height: 16),
											Align(
												alignment: Alignment.centerRight,
												child: SizedBox(
													height: 44,
													child: ElevatedButton.icon(
														onPressed: _postAnnouncement,
														style: ElevatedButton.styleFrom(
															backgroundColor: const Color(0xFF348AA7),
															foregroundColor: Colors.white,
															shape: RoundedRectangleBorder(
																borderRadius: BorderRadius.circular(8),
															),
															elevation: 2,
															padding: const EdgeInsets.symmetric(horizontal: 24),
														),
														icon: const Icon(Icons.send, size: 18),
														label: const Text(
															'Post Announcement',
															style: TextStyle(
																fontSize: 16,
																fontWeight: FontWeight.bold,
																fontFamily: 'Kumbh Sans',
															),
														),
													),
												),
											),
										],
									),
								),
								
								const SizedBox(height: 32),
								
								// Announcements List Header
								StreamBuilder<QuerySnapshot>(
									stream: FirebaseFirestore.instance
										.collection('announcements')
										.snapshots(),
									builder: (context, snapshot) {
										final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
										
										return Row(
											children: [
												Container(
													padding: const EdgeInsets.all(8),
													decoration: BoxDecoration(
														color: const Color(0xFF125E77).withOpacity(0.1),
														borderRadius: BorderRadius.circular(8),
													),
													child: const Icon(
														Icons.campaign,
														color: Color(0xFF125E77),
														size: 24,
													),
												),
												const SizedBox(width: 12),
												const Text(
													'All Announcements',
													style: TextStyle(
														color: Color(0xFF125E77),
														fontSize: 20,
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
														'$count ${count == 1 ? 'item' : 'items'}',
														style: const TextStyle(
															color: Color(0xFF348AA7),
															fontSize: 14,
															fontWeight: FontWeight.w600,
															fontFamily: 'Kumbh Sans',
														),
													),
												),
											],
										);
									},
								),
								
								const SizedBox(height: 16),
								
								// Announcements List with StreamBuilder
								StreamBuilder<QuerySnapshot>(
									stream: FirebaseFirestore.instance
										.collection('announcements')
										.orderBy('date', descending: true)
										.snapshots(),
									builder: (context, snapshot) {
										if (snapshot.hasError) {
											return Center(
												child: Text('Error: ${snapshot.error}'),
											);
										}

										if (snapshot.connectionState == ConnectionState.waiting) {
											return const Center(
												child: Padding(
													padding: EdgeInsets.all(20),
													child: CircularProgressIndicator(
														color: Color(0xFF348AA7),
													),
												),
											);
										}

										if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
															Icons.campaign,
															size: 64,
															color: Colors.grey[400],
														),
														const SizedBox(height: 16),
														Text(
															'No announcements yet',
															style: TextStyle(
																fontSize: 18,
																fontWeight: FontWeight.w600,
																color: Colors.grey[600],
																fontFamily: 'Kumbh Sans',
															),
														),
														const SizedBox(height: 8),
														Text(
															'Create your first announcement above',
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
											children: snapshot.data!.docs.map((doc) {
												final data = doc.data() as Map<String, dynamic>;
												final title = data['title'] ?? 'Untitled';
												final content = data['content'] ?? '';
												final announcementId = data['id'] ?? doc.id;
												final date = data['date'] as Timestamp?;
												final dateStr = date != null
													? DateFormat('MMM dd, yyyy').format(date.toDate())
													: 'Just now';

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
																				child: const Icon(
																					Icons.campaign,
																					size: 32,
																					color: Colors.white,
																				),
																			),
																			const SizedBox(width: 16),
																			Expanded(
																				child: Column(
																					crossAxisAlignment: CrossAxisAlignment.start,
																					children: [
																						Text(
																							title,
																							style: const TextStyle(
																								fontSize: 18,
																								fontWeight: FontWeight.bold,
																								fontFamily: 'Kumbh Sans',
																								color: Color(0xFF125E77),
																							),
																						),
																						const SizedBox(height: 4),
																						Text(
																							'ID: $announcementId',
																							style: TextStyle(
																								fontSize: 12,
																								fontFamily: 'Kumbh Sans',
																								color: Colors.grey[500],
																								fontWeight: FontWeight.w500,
																							),
																						),
																						const SizedBox(height: 4),
																						Text(
																							dateStr,
																							style: TextStyle(
																								fontSize: 12,
																								fontFamily: 'Kumbh Sans',
																								color: Colors.grey[500],
																							),
																						),
																						const SizedBox(height: 8),
																						Text(
																							content,
																							maxLines: 3,
																							overflow: TextOverflow.ellipsis,
																							style: TextStyle(
																								fontSize: 14,
																								fontFamily: 'Kumbh Sans',
																								color: Colors.grey[700],
																								height: 1.4,
																							),
																						),
																					],
																				),
																			),
																		],
																	),
																	const SizedBox(height: 12),
																	Row(
																		children: [
																			Expanded(
																				child: OutlinedButton.icon(
																					onPressed: () => viewAnnouncement(doc.id),
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
																					onPressed: () => editAnnouncement(doc.id),
																					style: ElevatedButton.styleFrom(
																						backgroundColor: const Color(0xFF348AA7),
																						foregroundColor: Colors.white,
																						shape: RoundedRectangleBorder(
																							borderRadius: BorderRadius.circular(8),
																						),
																						padding: const EdgeInsets.symmetric(vertical: 12),
																						elevation: 0,
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
																		],
																	),
																],
															),
														),
													),
												);
											}).toList(),
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
