import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/admin/admin_announcement.dart';
import '../pages/admin/admin_user_management.dart';
import '../pages/admin/admin_dashboard.dart';
import '../pages/admin/admin_document_verification.dart';
import '../pages/splash_screen.dart';

/// TravelEase Admin Navigation Drawer
/// 
/// A reusable side navigation menu for admin users in the TravelEase app.
/// This drawer provides quick access to all main admin user features.
/// 
/// Usage:
/// ```dart
/// Scaffold(
///   drawer: const AdminAppDrawer(),
///   ...
/// )
/// ```
class AdminAppDrawer extends StatelessWidget {
  const AdminAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 310,
      backgroundColor: const Color(0xFF125E77),
      child: SafeArea(
        child: Column(
          children: [
            // Header with logo and title
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                children: [
                  // Menu Icon/Button
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the drawer when pressed
                    },
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 50,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Text Title
                  const Text(
                    'TravelEase',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            
            const Divider(color: Colors.white24, height: 1),
            
            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    'Home',
                    Icons.home_outlined,
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Document Verification',
                    Icons.verified_outlined,
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminDocumentVerificationPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Announcements',
                    Icons.campaign_outlined,
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminAnnouncementPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'User Management',
                    Icons.group_outlined,
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminUserManagement()),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildMenuItem(
                    context,
                    'Logout',
                    Icons.logout,
                    () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const SplashScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    int? badgeCount,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Kumbh Sans',
        ),
      ),
      trailing: badgeCount != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      dense: true,
    );
  }
}
