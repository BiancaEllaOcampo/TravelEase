import 'package:flutter/material.dart';
import 'user_travel_requirments.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

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
                // Menu Button
                IconButton(
                  onPressed: () {
                    // Handle menu tap
                  },
                  icon: const Icon(
                    Icons.menu,
                    color: Color(0xFFF3F3F3),
                    size: 50,
                  ),
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
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height + 200, // Extra height for scrolling
          child: Stack(
            children: [
              // Background
              Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFD9D9D9),
              ),
          
          // Welcome Message
          Positioned(
            top: 31,
            left: 36,
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Kumbh Sans',
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: 'Welcome back, ',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(
                    text: 'Bianca!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // User Alert Card
          Positioned(
            top: 76,
            left: 34,
            right: 34,
            child: Container(
              height: 232,
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
                    
                    // Go to Profile Button
                    SizedBox(
                      width: 255,
                      height: 49,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle go to profile
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
          ),
          
          // Travel Requirements Button
          Positioned(
            top: 329,
            left: 34,
            right: 34,
            child: _buildFeatureButton(
              context,
              'Travel Requirements',
              'Check requirements for your destination',
              Icons.flight_takeoff,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserTravelRequirementsPage()),
              ),
            ),
          ),
          
          // Documents Checklist Button
          Positioned(
            top: 445,
            left: 34,
            right: 34,
            child: _buildFeatureButton(
              context,
              'Documents Checklist',
              'Create and manage your travel document checklist',
              Icons.checklist_rtl,
              () {
                // Handle documents checklist navigation
              },
            ),
          ),
          
          // View My Documents Button
          Positioned(
            top: 561,
            left: 34,
            right: 34,
            child: _buildFeatureButton(
              context,
              'View My Documents',
              'Access your uploaded documents and verification status',
              Icons.folder_open,
              () {
                // Handle view documents navigation
              },
            ),
          ),
          
          // View AI Feedback Button
          Positioned(
            top: 677,
            left: 34,
            right: 34,
            child: _buildFeatureButton(
              context,
              'View AI Feedback',
              'Get AI-powered insights on your documents',
              Icons.psychology,
              () {
                // Handle AI feedback navigation
              },
            ),
          ),
          
          // Bottom Links
          Positioned(
            bottom: 52,
            left: 33,
            right: 33,
            child: Row(
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
          ),
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