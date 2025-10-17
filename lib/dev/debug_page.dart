import 'package:flutter/material.dart';
import '../pages/splash_screen.dart';
import '../pages/user/user_login.dart';
import '../pages/user/user_signup.dart';
import '../pages/user/user_homepage.dart';
import '../pages/user/user_profile.dart';
import 'template.dart';
import 'template_with_menu.dart';
import '../pages/admin/admin_login.dart';
import '../pages/admin/admin_dashboard.dart';
import '../pages/admin/admin_user_management.dart';
import '../pages/user/user_travel_requirments.dart';
import '../pages/user/user_fticket.dart';
import '../pages/user/user_documents_checklist.dart';
import '../pages/user/user_view_document_with_ai.dart';
import '../pages/admin/admin_announcement.dart';
import '../pages/admin/admin_requirement_configuration.dart';
import '../pages/admin/admin_document_veification.dart';
import '../pages/master/master_login.dart';
import '../pages/master/master_dashboard.dart';
import '../pages/master/master_admin&user_management.dart';
import '../pages/master/master_document_veification.dart';
import '../pages/master/master_announcement.dart';

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
              'User Profile',
              'User profile page with personal information and security settings',
              Icons.person,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfilePage()),
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
              'Template (with Menu)',
              'Template page that uses the menu-style app bar',
              Icons.menu,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TemplateWithMenuPage()),
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

            _buildDebugButton(
              context,
              'Document Checklist (Japan)',
              'View document checklist for Japan',
              Icons.checklist,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserDocumentsChecklistPage(country: 'Japan'),
                ),
              ),
            ),

            _buildDebugButton(
              context,
              'View Document with AI (Flight Ticket)',
              'View document details with AI analysis',
              Icons.analytics,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserViewDocumentWithAIPage(
                    documentName: 'Flight Ticket',
                    country: 'Japan',
                  ),
                ),
              ),
            ),

            _buildDebugButton(
              context,
              'User Flight Ticket',
              'Configure/view User Flight ticket',
              Icons.rule,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FlightTicketPage()),
              ),
            ),

            _buildDebugButton(
              context,
              'Admin Announcement',
              'Configure/view Admin Announcement',
              Icons.rule,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminAnnouncementPage()),
              ),
            ),

            _buildDebugButton(
              context,
              'Admin Document Verification',
              'Configure/view Admin Document Verification',
              Icons.rule,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDocumentVerificationPage()),
              ),
            ),

            _buildDebugButton(
              context,
              'Admin Requirement Configuration',
              'Configure/view Admin Requirement Configuration',
              Icons.rule,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminReqConfigPage()),
              ),
            ),

            _buildDebugButton(
              context,
              'Master Login',
              'Configure/view Master User Login Configuration',
              Icons.rule,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MasterLoginPage()),
              ),
            ),

            _buildDebugButton(
              context,
              'Master Admin & User',
              'Configure/view Master User Admin & User Configuration',
              Icons.rule,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MasterAdminUserManagement()),
              ),
            ),

            _buildDebugButton(
              context,
              'Master Use Verification Queu',
              'Configure/view Master User Document Verification Configuration',
              Icons.rule,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MasterDocumentVerificationPage()),
              ),
            ),

            _buildDebugButton(
              context,
              'Master User Announcement',
              'Configure/view Master User Announcement Configuration',
              Icons.rule,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MasterAnnouncementPage()),
              ),
            ),

            _buildDebugButton(
              context,
              'Master User Dashboard',
              'Configure/view Master User Dashboard Configuration',
              Icons.rule,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MasterDashboardPage()),
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

