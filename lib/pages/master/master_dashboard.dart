import 'package:flutter/material.dart';
import 'master_admin&user_management.dart';
import 'master_document_veification.dart';
import 'master_announcement.dart';

class MasterDashboardPage extends StatelessWidget {
  const MasterDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.menu,
                    color: Color(0xFFF3F3F3),
                    size: 24,
                  ),
                ),
                const Text(
                  'TravelEase',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kumbh Sans',
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
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFD9D9D9),
          ),

          // Stats Cards
          Positioned(
            top: 20, // Reduced gap - was 150 - 48, now properly positioned after AppBar
            left: 0,
            right: 0,
            child: Column(
              children: [
                _MasterStatCard(
                  label: 'Users:',
                  value: '',
                ),
                _MasterStatCard(
                  label: 'Pending Documents:',
                  value: '',
                ),
                _MasterStatCard(
                  label: 'Announcements:',
                  value: '',
                ),
                _MasterStatCard(
                  label: 'Tickets:',
                  value: '',
                  isLast: true,
                ),
              ],
            ),
          ),

          // Admin Action Buttons
          Positioned(
            top: 320, // Reduced gap - was 450 - 48, now properly positioned
            left: 0,
            right: 0,
            child: Column(
              children: [
                _MasterActionButton(
                  text: 'Admin and User Management',
                  onPressed: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MasterAdminUserManagement()),
                    );
                  },
                ),
                _MasterActionButton(
                  text: 'Documents Verification\nQueue',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MasterDocumentVerificationPage(),
                      ),
                    );
                  },
                ),
                _MasterActionButton(
                  text: 'Announcements',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MasterAnnouncementPage(),
                      ),
                    );
                  },
                ),
                _MasterActionButton(
                  text: 'System Settings',
                  onPressed: () {
                    /*Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MasterDocumentVerificationPage(),
                      ),
                    );*/
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterStatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _MasterStatCard({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Remove left/right margin, set width to full
      margin: EdgeInsets.only(
        left: 0,
        right: 0,
        top: 0,
        bottom: isLast ? 24 : 8,
      ),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF348AA7),
        borderRadius: BorderRadius.zero, // No border radius for full width
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Kumbh Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Kumbh Sans',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
//Stats

class _MasterActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _MasterActionButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF348AA7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontFamily: 'Kumbh Sans',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}