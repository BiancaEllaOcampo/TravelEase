import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/user/user_documents_checklist.dart';
import '../pages/user/user_travel_requirments.dart';

/// Helper class for navigating to and managing document checklists
class ChecklistHelper {
  /// Navigates to the user's document checklist.
  /// If the user has a checklist, it loads that country.
  /// If not, redirects to Travel Requirements to create one.
  static Future<void> navigateToChecklist(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to view your checklist'),
              backgroundColor: Color(0xFFA54547),
            ),
          );
        }
        return;
      }

      // Fetch the user's checklists from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final checklists = data?['checklists'] ?? {};

        if (checklists.isNotEmpty) {
          // Get the country from the checklist
          final country = checklists.keys.first;

          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDocumentsChecklistPage(
                  country: country,
                ),
              ),
            );
          }
        } else {
          // No checklist exists, redirect to Travel Requirements
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Create a checklist first in Travel Requirements'),
                duration: Duration(seconds: 3),
              ),
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserTravelRequirementsPage(),
              ),
            );
          }
        }
      } else {
        // User document doesn't exist
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create a checklist first in Travel Requirements'),
              duration: Duration(seconds: 3),
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserTravelRequirementsPage(),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFA54547),
          ),
        );
      }
    }
  }
}
