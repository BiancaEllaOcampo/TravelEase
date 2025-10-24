import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travelease2/firebase_options.dart';
import 'pages/splash_screen.dart';
import 'pages/user/user_homepage.dart';
import 'pages/admin/admin_dashboard.dart';
import 'pages/master/master_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading .env file: $e');
    // App will continue but with empty env variables
  }
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelEase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Kumbh Sans',
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          // Show loading while checking auth state
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // If not authenticated, show splash screen
          if (!authSnapshot.hasData || authSnapshot.data == null) {
            return const SplashScreen();
          }
          
          // User is authenticated, check their role from Firestore
          final user = authSnapshot.data!;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, userSnapshot) {
              // Show loading while fetching user data
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              
              // If user document doesn't exist or error occurred, default to user homepage
              if (!userSnapshot.hasData || userSnapshot.hasError || !userSnapshot.data!.exists) {
                return const UserHomePage();
              }
              
              // Get user role from Firestore
              final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
              final role = userData?['role'] as String?;
              
              // Route based on role
              switch (role) {
                case 'admin':
                  return const AdminDashboardPage();
                case 'master':
                  return const MasterDashboardPage();
                case 'user':
                default:
                  return const UserHomePage();
              }
            },
          );
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
