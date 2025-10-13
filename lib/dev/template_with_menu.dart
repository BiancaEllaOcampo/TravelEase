import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/user/user_homepage.dart';
import '../pages/splash_screen.dart';

class TemplateWithMenuPage extends StatelessWidget {
  const TemplateWithMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const TravelEaseDrawer(),
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

                // Title
                Flexible(
                  child: const Text(
                    'Sample Text Here',
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
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFD9D9D9),
          ),

          // Back Button (keeps parity with TemplatePage)
          Positioned(
            top: 50,
            left: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// TravelEase Drawer Menu
class TravelEaseDrawer extends StatelessWidget {
  const TravelEaseDrawer({super.key});

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
                        MaterialPageRoute(builder: (context) => const UserHomePage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'My Profile',
                    Icons.person_outline,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to profile
                    },
                    badgeCount: 3,
                  ),
                  _buildMenuItem(
                    context,
                    'View My Documents',
                    Icons.folder_open_outlined,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to documents
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Travel Requirements',
                    Icons.flight_takeoff,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to travel requirements
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Announcements',
                    Icons.campaign_outlined,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to announcements
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Feedback',
                    Icons.feedback_outlined,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to feedback
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Support',
                    Icons.help_outline,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to support
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Settings',
                    Icons.settings_outlined,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to settings
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Privacy Policy',
                    Icons.privacy_tip_outlined,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to privacy policy
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Terms of Service',
                    Icons.description_outlined,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to terms
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logout failed')),
                      );
                    }

                    // Return to splash and clear navigation history
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const SplashScreen()),
                      (route) => false,
                    );
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