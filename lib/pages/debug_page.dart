import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'user_login.dart';
import 'user_signup.dart';
import 'user_homepage.dart';
import 'template.dart';
import 'admin_login.dart';
import 'admin_dashboard.dart';
import 'admin_user_management.dart';
import 'user_travel_requirments.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Debug - All Pages',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF125E77),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFD9D9D9),
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Debug Menu - Navigate to Any Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF125E77),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            _buildDebugButton(
              context,
              'Splash Screen',
              'The main landing page with login/signup options',
              Icons.home,
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SplashScreen()),
              ),
            ),
            
            _buildDebugButton(
              context,
              'User Login',
              'User authentication page',
              Icons.login,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserLoginPage()),
              ),
            ),
            
            _buildDebugButton(
              context,
              'Admin Login',
              'Administrator authentication page',
              Icons.admin_panel_settings,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminLoginPage()),
              ),
            ),
            
            _buildDebugButton(
              context,
              'User Signup',
              'User registration page',
              Icons.person_add,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserSignupPage()),
              ),
            ),
            
            _buildDebugButton(
              context,
              'User Homepage',
              'Main user dashboard after login',
              Icons.dashboard,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserHomePage()),
              ),
            ),
            
            _buildDebugButton(
              context,
              'Template Page',
              'Design template for new pages',
              Icons.article,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TemplatePage()),
              ),
            ),
            
            _buildDebugButton(
              context,
              'Admin Dashboard',
              'Administrator overview and actions',
              Icons.dashboard_customize,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
              ),
            ),

            _buildDebugButton(
              context,
              'Admin User Management',
              'Manage users (add/delete)',
              Icons.group,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminUserManagement()),
              ),
            ),

            _buildDebugButton(
              context,
              'Travel Requirements',
              'Configure/view travel requirements',
              Icons.rule,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserTravelRequirementsPage()),
              ),
            ),
            
            const SizedBox(height: 30),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Text(
                '⚠️ Debug Mode\n\nThis page is for development purposes only. Remove from production build.',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugButton(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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