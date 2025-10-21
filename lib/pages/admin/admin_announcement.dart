import 'package:flutter/material.dart';
import '../../utils/admin_app_drawer.dart';

class AdminAnnouncementPage extends StatefulWidget {
	const AdminAnnouncementPage({Key? key}) : super(key: key);

	@override
	State<AdminAnnouncementPage> createState() => _AdminAnnouncementPageState();
}

class _AdminAnnouncementPageState extends State<AdminAnnouncementPage> {
	final TextEditingController titleController = TextEditingController();
	final TextEditingController contentController = TextEditingController();

	List<Map<String, String>> announcements = [
		{
			'title': 'New Policies for Nepal',
			'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim',
		},
		{
			'title': 'Emergence of new Requirments',
			'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim',
		},
	];

	// Placeholder for backend integration: post a new announcement
	void postAnnouncement(String title, String content) {
		setState(() {
			announcements.insert(0, {'title': title, 'content': content});
		});
		// TODO: Integrate with backend API
	}

	// Placeholder for backend integration: view an announcement
	void viewAnnouncement(int index) {
		// TODO: Implement view logic (e.g., show dialog or navigate)
	}

	// Placeholder for backend integration: edit an announcement
	void editAnnouncement(int index) {
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
									// Title field
									const Text(
										'Title',
										style: TextStyle(
											fontSize: 16,
											fontWeight: FontWeight.w500,
											fontFamily: 'Kumbh Sans',
										),
									),
									const SizedBox(height: 6),
									Container(
										height: 40,
										decoration: BoxDecoration(
											color: Colors.white,
											borderRadius: BorderRadius.circular(8),
											border: Border.all(color: Colors.grey),
										),
										child: TextField(
											controller: titleController,
											decoration: const InputDecoration(
												border: InputBorder.none,
												contentPadding: EdgeInsets.symmetric(horizontal: 12),
											),
										),
									),
									const SizedBox(height: 12),
									// Content field
									const Text(
										'Content',
										style: TextStyle(
											fontSize: 16,
											fontWeight: FontWeight.w500,
											fontFamily: 'Kumbh Sans',
										),
									),
									const SizedBox(height: 6),
									Container(
										height: 90,
										decoration: BoxDecoration(
											color: Colors.white,
											borderRadius: BorderRadius.circular(8),
											border: Border.all(color: Colors.grey),
										),
										child: TextField(
											controller: contentController,
											maxLines: null,
											expands: true,
											decoration: const InputDecoration(
												border: InputBorder.none,
												contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
											),
										),
									),
									const SizedBox(height: 10),
									Align(
										alignment: Alignment.centerRight,
										child: SizedBox(
											width: 85,
											height: 38,
											child: ElevatedButton(
												onPressed: () {
													if (titleController.text.trim().isNotEmpty && contentController.text.trim().isNotEmpty) {
														postAnnouncement(titleController.text.trim(), contentController.text.trim());
														titleController.clear();
														contentController.clear();
													}
												},
												style: ElevatedButton.styleFrom(
													backgroundColor: const Color(0xFF348AA7),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(6),
													),
												),
												child: const Text(
													'Post',
													style: TextStyle(
														color: Colors.white,
														fontSize: 16,
														fontWeight: FontWeight.bold,
														fontFamily: 'Kumbh Sans',
													),
												),
											),
										),
									),
									const SizedBox(height: 18),
									const Text(
										'Announcements',
										style: TextStyle(
											fontSize: 16,
											fontWeight: FontWeight.w600,
											fontFamily: 'Kumbh Sans',
										),
									),
									const SizedBox(height: 8),
									...announcements.map((announcement) {
										int idx = announcements.indexOf(announcement);
										return Padding(
											padding: const EdgeInsets.only(bottom: 14),
											child: Container(
												decoration: BoxDecoration(
													color: Colors.white,
													borderRadius: BorderRadius.circular(10),
													border: Border.all(color: Colors.grey.shade300),
													boxShadow: [
														BoxShadow(
															color: Colors.black.withOpacity(0.05),
															blurRadius: 4,
															offset: const Offset(0, 2),
														),
													],
												),
												child: Padding(
													padding: const EdgeInsets.all(12),
													child: Row(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
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
															Expanded(
																child: Column(
																	crossAxisAlignment: CrossAxisAlignment.start,
																	children: [
																		Text(
																			announcement['title'] ?? '',
																			style: const TextStyle(
																				fontSize: 16,
																				fontWeight: FontWeight.bold,
																				fontFamily: 'Kumbh Sans',
																				color: Color(0xFF125E77),
																			),
																		),
																		const SizedBox(height: 2),
																		Text(
																			announcement['content'] ?? '',
																			maxLines: 2,
																			overflow: TextOverflow.ellipsis,
																			style: const TextStyle(
																				fontSize: 13,
																				fontFamily: 'Kumbh Sans',
																				color: Colors.black87,
																			),
																		),
																	],
																),
															),
															const SizedBox(width: 8),
															Column(
																children: [
																	SizedBox(
																		width: 60,
																		height: 32,
																		child: ElevatedButton(
																			onPressed: () => viewAnnouncement(idx),
																			style: ElevatedButton.styleFrom(
																				backgroundColor: const Color(0xFF348AA7),
																				shape: RoundedRectangleBorder(
																					borderRadius: BorderRadius.circular(6),
																				),
																				padding: EdgeInsets.zero,
																			),
																			child: const Text(
																				'View',
																				style: TextStyle(
																					color: Colors.white,
																					fontSize: 14,
																					fontWeight: FontWeight.bold,
																					fontFamily: 'Kumbh Sans',
																				),
																			),
																		),
																	),
																	const SizedBox(height: 12),
																	SizedBox(
																		width: 60,
																		height: 32,
																		child: ElevatedButton(
																			onPressed: () => editAnnouncement(idx),
																			style: ElevatedButton.styleFrom(
																				backgroundColor: const Color(0xFF348AA7),
																				shape: RoundedRectangleBorder(
																					borderRadius: BorderRadius.circular(6),
																				),
																				padding: EdgeInsets.zero,
																			),
																			child: const Text(
																				'Edit',
																				style: TextStyle(
																					color: Colors.white,
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
