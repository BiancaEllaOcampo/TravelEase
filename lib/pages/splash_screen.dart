import 'package:flutter/material.dart';
import 'user_login.dart';
import 'user_signup.dart';
import 'admin_login.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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
          
          // Background Image with opacity
          Positioned(
            top: 82,
            left: 0,
            right: 0,
            height: 835,
            child: Opacity(
              opacity: 0.75,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          
          
          // Banner
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            height: 82,
            child: Container(
              color: const Color(0xFF125E77),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Welcome to TravelEase',
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
          
          // Main Tagline
          Positioned(
            top: 250,
            left: 50,
            right: 50,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'Your hassle-free travel companion',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Kumbh Sans',
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Login Button
          Positioned(
            top: 512,
            left: 45,
            right: 45,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF348AA7),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Colors.black.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: MaterialButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserLoginPage()),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'Login',
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
          
          // Create Account Button
          Positioned(
            top: 614,
            left: 45,
            right: 45,
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
                    MaterialPageRoute(builder: (context) => const UserSignupPage()),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'Create an Account',
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

          // For testing purposes: Going to admin dashboard
           Positioned(
            top: 690,
            left: 45,
            right: 45,
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
                    MaterialPageRoute(builder: (context) => const AdminLoginPage()),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'Admin Testing',
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
          // Admin Testing button remove later

          // Bottom Links
          Positioned(
            bottom: 44,
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
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Handle Mission & Vision navigation
                  },
                  child: const Text(
                    'Mission & Vision',
                    style: TextStyle(
                      color: Colors.white,
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