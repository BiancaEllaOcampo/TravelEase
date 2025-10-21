import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/master/master_announcement.dart';
import '../pages/master/master_admin&user_management.dart';
import '../pages/master/master_dashboard.dart';
import '../pages/master/master_document_verification.dart';
import '../pages/splash_screen.dart';

/// TravelEase Master Navigation Drawer
/// 
/// A reusable side navigation menu for master users (administrators) in the TravelEase app.
/// This drawer provides quick access to all main master user features.
/// 
/// Usage:
/// ```dart
/// Scaffold(
///   drawer: const MasterAppDrawer(),
///   ...
/// )
/// ```
class MasterAppDrawer extends StatelessWidget {
  const MasterAppDrawer({super.key});

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
                        MaterialPageRoute(builder: (context) => const MasterDashboardPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'My Profile',
                    Icons.person_outline,
                    () {
                      Navigator.pop(context);
                      /*Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserProfilePage()),
                      );*/
                    },
                    badgeCount: 3,
                  ),
                  _buildMenuItem(
                    context,
                    'Announcement Management',
                    Icons.flight_takeoff,
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MasterAnnouncementPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Document Verification',
                    Icons.checklist_rtl,
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MasterDocumentVerificationPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'User & Admin Management',
                    Icons.campaign_outlined,
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MasterAdminUserManagement()),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Log Out Button at bottom
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged out')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logout failed')),
                        );
                      }
                    }

                    // Return to splash and clear navigation history
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const SplashScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
        size: 35,
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              softWrap: true,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Kumbh Sans',
              ),
            ),
          ),
          if (badgeCount != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Kumbh Sans',
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
