import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../utils/user_app_drawer.dart';
import '../splash_screen.dart';

class UserAnnouncementsPage extends StatefulWidget {
  const UserAnnouncementsPage({super.key});

  @override
  State<UserAnnouncementsPage> createState() => _UserAnnouncementsPageState();
}

class _UserAnnouncementsPageState extends State<UserAnnouncementsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  // Check if user is logged in
  void _checkAuthStatus() {
    final currentUser = _auth.currentUser;
    
    if (currentUser == null) {
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

  // View announcement in a dialog
  void _viewAnnouncement(Map<String, dynamic> announcement) {
    final date = announcement['date'] as Timestamp?;
    final dateStr = date != null 
        ? DateFormat('MMMM dd, yyyy • hh:mm a').format(date.toDate())
        : 'No date available';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF125E77), Color(0xFF348AA7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.campaign,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Announcement',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kumbh Sans',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        announcement['title'] ?? 'Untitled',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kumbh Sans',
                          color: Color(0xFF125E77),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Date
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Color(0xFF348AA7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'Kumbh Sans',
                              color: Color(0xFF348AA7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      // Content
                      Text(
                        announcement['content'] ?? 'No content available',
                        style: const TextStyle(
                          fontSize: 15,
                          fontFamily: 'Kumbh Sans',
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Close button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF348AA7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Close',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is still logged in
    final currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
        );
      });
      
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
      drawer: const UserAppDrawer(),
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
                // Menu Button
                Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 50,
                      ),
                    );
                  },
                ),
                // Title
                const Flexible(
                  child: Text(
                    'Announcements',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                ),
                // Logo
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
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('announcements')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF348AA7),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading announcements...',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Kumbh Sans',
                        color: Color(0xFF125E77),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Error state
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Color(0xFFA54547),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading announcements',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kumbh Sans',
                          color: Color(0xFF125E77),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Kumbh Sans',
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Empty state
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF348AA7).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.campaign_outlined,
                          size: 80,
                          color: Color(0xFF348AA7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No Announcements Yet',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kumbh Sans',
                          color: Color(0xFF125E77),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Check back later for travel updates,\nalerts, and important notices.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Kumbh Sans',
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Announcements list
            final announcements = snapshot.data!.docs;
            
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final doc = announcements[index];
                final data = doc.data() as Map<String, dynamic>;
                final date = data['date'] as Timestamp?;
                final dateStr = date != null 
                    ? DateFormat('MMM dd, yyyy').format(date.toDate())
                    : 'No date';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF348AA7).withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _viewAnnouncement(data),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with icon and date
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF348AA7).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.campaign,
                                    color: Color(0xFF348AA7),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Travel Alert',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Kumbh Sans',
                                          color: Color(0xFF348AA7),
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        dateStr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Kumbh Sans',
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFF348AA7),
                                  size: 18,
                                ),
                              ],
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
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            // Content preview
                            Text(
                              data['content'] ?? 'No content',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Kumbh Sans',
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            // Read more
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Read More',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Kumbh Sans',
                                    color: Color(0xFF348AA7),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF348AA7),
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
