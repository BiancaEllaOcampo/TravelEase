import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../utils/master_app_drawer.dart';
import '../splash_screen.dart';

class MasterAnnouncementPage extends StatefulWidget {
  const MasterAnnouncementPage({super.key});

  @override
  State<MasterAnnouncementPage> createState() => _MasterAnnouncementPageState();
}

class _MasterAnnouncementPageState extends State<MasterAnnouncementPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  // Check if user is logged in, similar to user_homepage.dart
  void _checkAuthStatus() {
    final currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      // User is not logged in, redirect to splash screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SplashScreen()),
            (route) => false,
          );
        }
      });
    }
  }

  // Validation method to check if title and content are not empty
  bool _validateFields(String title, String content) {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both title and content'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  // Post a new announcement to Firebase (only 4 fields: id, title, content, date)
  Future<void> postAnnouncement(String title, String content) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in to post announcements')),
          );
        }
        return;
      }

      // Create a new document with auto-generated ID
      final docRef = _firestore.collection('announcements').doc();
      
      // Only 4 fields as required
      await docRef.set({
        'id': docRef.id,
        'title': title,
        'content': content,
        'date': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement posted successfully!')),
        );

        titleController.clear();
        contentController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error posting announcement: $e')),
        );
      }
    }
  }

  // View announcement in a dialog (showing ID to user)
  void viewAnnouncement(Map<String, dynamic> announcement) {
    final date = announcement['date'] as Timestamp?;
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
              // ID (visible to user)
              Text(
                'ID: ${announcement['id'] ?? 'N/A'}',
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
                announcement['title'] ?? '',
                style: const TextStyle(
                  fontSize: 22,
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
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Text(
                    announcement['content'] ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontFamily: 'Kumbh Sans',
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Close',
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
        ),
      ),
    );
  }

  // Edit announcement
  void editAnnouncement(Map<String, dynamic> announcement) {
    final TextEditingController editTitleController = 
        TextEditingController(text: announcement['title']);
    final TextEditingController editContentController = 
        TextEditingController(text: announcement['content']);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Announcement',
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
              // ID (read-only, visible)
              Text(
                'ID: ${announcement['id'] ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Kumbh Sans',
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
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
              TextField(
                controller: editTitleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 16),
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
              TextField(
                controller: editContentController,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 24),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Delete button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(announcement['id']);
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kumbh Sans',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Cancel button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kumbh Sans',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Save button
                  ElevatedButton(
                    onPressed: () {
                      if (_validateFields(editTitleController.text, editContentController.text)) {
                        _updateAnnouncement(
                          announcement['id'],
                          editTitleController.text.trim(),
                          editContentController.text.trim(),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF348AA7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kumbh Sans',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  /// Updates an announcement in Firebase.
  ///
  /// The original creation date of the announcement is preserved and not updated on edit.
  /// If you want to update the date to the current time on edit, modify this function accordingly.
  Future<void> _updateAnnouncement(String id, String title, String content) async {
    try {
      await _firestore.collection('announcements').doc(id).update({
        'title': title,
        'content': content,
        // The 'date' field is intentionally left unchanged to preserve the original creation date.
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating announcement: $e')),
        );
      }
    }
  }

  // Confirm delete dialog
  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Announcement',
          style: TextStyle(
            fontFamily: 'Kumbh Sans',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this announcement? This action cannot be undone.',
          style: TextStyle(fontFamily: 'Kumbh Sans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Kumbh Sans',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAnnouncement(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Kumbh Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Delete announcement from Firebase
  Future<void> _deleteAnnouncement(String id) async {
    try {
      await _firestore.collection('announcements').doc(id).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement deleted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting announcement: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is still logged in
    final currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      // User is not logged in, redirect to splash screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
        );
      });
      
      // Return a loading screen while navigating
      return Scaffold(
        body: Container(
          color: const Color(0xFFD9D9D9),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF348AA7),
            ),
          ),
        ),
      );
    }

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
                            onPressed: () {
                              if (_validateFields(titleController.text, contentController.text)) {
                                postAnnouncement(
                                  titleController.text.trim(), 
                                  contentController.text.trim(),
                                );
                              }
                            },
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
                
                // Announcements List Header (with StreamBuilder count)
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
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
                  // StreamBuilder to display announcements from Firebase
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
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
                          child: CircularProgressIndicator(),
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
                                            onPressed: () => viewAnnouncement(data),
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
                                            onPressed: () => editAnnouncement(data),
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

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}