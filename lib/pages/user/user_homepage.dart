import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_travel_requirments.dart';
import 'user_profile.dart' as user_profile;
import '../../dev/template_with_menu.dart';
import '../../utils/checklist_helper.dart';
import '../splash_screen.dart';
  
class UserHomePage extends StatelessWidget {
  final String? username;

  const UserHomePage({super.key, this.username});

  @override
  Widget build(BuildContext context) {
    // Check if user is still logged in
    final currentUser = FirebaseAuth.instance.currentUser;
    
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
                // Menu Button (opens drawer)
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
                const Text(
                  'TravelEase',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kumbh Sans',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 31),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Builder(builder: (context) {
                // Determine display name: constructor -> Firebase displayName -> email prefix -> fallback
                final user = FirebaseAuth.instance.currentUser;
                String displayName = username ?? user?.displayName ?? (user?.email != null ? user!.email!.split('@').first : 'Traveler');
                if (displayName.trim().isEmpty) displayName = 'Traveler';

                return Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Kumbh Sans',
                        color: Colors.black,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Welcome back, ',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text: '$displayName!',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 20),
              
              // User Alert Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF348AA7),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 8),
                          // Alert Title
                          const Text(
                            'Ready to start your checklist?',
                            style: TextStyle(
                              color: Color(0xFF125E77),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Kumbh Sans',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Alert Description
                          const Text(
                            'Before you start, please complete your profile information and upload your required documents to get real-time verification.',
                            style: TextStyle(
                              color: Color(0xFF125E77),
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Kumbh Sans',
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Go to Profile Button
                      SizedBox(
                        width: 255,
                        height: 49,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const user_profile.UserProfilePage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA54547),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text(
                            'Go to Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
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
              
              const SizedBox(height: 20),
              
              // Travel Requirements Button
              _buildFeatureButton(
                context,
                'Travel Requirements',
                'Check requirements for your destination',
                Icons.flight_takeoff,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserTravelRequirementsPage()),
                ),
              ),
              
              const SizedBox(height: 6),
              
              // Documents Checklist Button
              _buildFeatureButton(
                context,
                'Documents Checklist',
                'Create and manage your travel document checklist',
                Icons.checklist_rtl,
                () => ChecklistHelper.navigateToChecklist(context),
              ),
              
              const SizedBox(height: 6),

              // View AI Feedback Button
              _buildFeatureButton(
                context,
                'View AI Feedback',
                'Get AI-powered insights on your documents',
                Icons.psychology,
                () {
                  // Handle AI feedback navigation
                },
              ),

              const SizedBox(height: 6),

              // View Announcements Button
              _buildFeatureButton(
                context,
                'View Announcements',
                'Stay updated with travel alerts and important notices',
                Icons.campaign,
                () {
                  // TODO: Handle announcements navigation
                },
              ),
              
              const SizedBox(height: 32),
              
              // Bottom Links
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Handle About Us navigation
                    },
                    child: const Text(
                      'About Us',
                      style: TextStyle(
                        color: Color(0xFF348AA7),
                        fontSize: 25,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Kumbh Sans',
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Handle Feedback navigation
                    },
                    child: const Text(
                      'Feedback',
                      style: TextStyle(
                        color: Color(0xFF348AA7),
                        fontSize: 25,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Kumbh Sans',
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF125E77),
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF348AA7), width: 2),
          ),
          elevation: 3,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF348AA7).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF348AA7),
                size: 28,
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
                      color: Color(0xFF125E77),
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF348AA7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}