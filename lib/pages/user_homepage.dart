import 'package:flutter/material.dart';
import 'user_travel_requirments.dart';
class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFD9D9D9),
          ),
          
          // Header Banner
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            height: 82,
            child: Container(
              color: const Color(0xFF125E77),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
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
                        size: 24,
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
          
          // Welcome Message
          Positioned(
            top: 161,
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
            top: 206,
            left: 34,
            right: 34,
            child: Container(
              height: 232,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
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
            top: 459,
            left: 47,
            right: 53,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF348AA7),
                borderRadius: BorderRadius.circular(50),
              ),
              child: MaterialButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserTravelRequirementsPage()),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'Travel Requirements',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kumbh Sans',
                  ),
                ),
              ),
            ),
          ),
          
          // Documents Checklist Button
          Positioned(
            top: 545,
            left: 48,
            right: 52,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF348AA7),
                borderRadius: BorderRadius.circular(50),
              ),
              child: MaterialButton(
                onPressed: () {
                  // Handle documents checklist navigation
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'Documents Checklist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kumbh Sans',
                  ),
                ),
              ),
            ),
          ),
          
          // View My Documents Button
          Positioned(
            top: 631,
            left: 50,
            right: 50,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF348AA7),
                borderRadius: BorderRadius.circular(50),
              ),
              child: MaterialButton(
                onPressed: () {
                  // Handle view documents navigation
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'View My Documents',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kumbh Sans',
                  ),
                ),
              ),
            ),
          ),
          
          // View AI Feedback Button
          Positioned(
            top: 717,
            left: 50,
            right: 50,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF348AA7),
                borderRadius: BorderRadius.circular(50),
              ),
              child: MaterialButton(
                onPressed: () {
                  // Handle AI feedback navigation
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'View AI Feedback',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kumbh Sans',
                  ),
                ),
              ),
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
    );
  }
}