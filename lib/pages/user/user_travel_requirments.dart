import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/user_app_drawer.dart';
import '../splash_screen.dart';
import 'user_documents_checklist.dart';

class UserTravelRequirementsPage extends StatefulWidget {
  const UserTravelRequirementsPage({super.key});

  @override
  State<UserTravelRequirementsPage> createState() => _UserTravelRequirementsPageState();
}

class _UserTravelRequirementsPageState extends State<UserTravelRequirementsPage> {
  String selectedCountry = 'Japan';

  final Map<String, List<Map<String, dynamic>>> requirementsByCountry = {
    'Japan': [
      {'title': 'Flight Ticket', 'subitems': []},
      {'title': 'Valid Passport', 'subitems': []},
      {'title': 'Proof of Accommodation', 'subitems': []},
      {'title': 'eTravel Registration (App)', 'subitems': []},
      {
        'title': 'Visa',
        'subitems': [
          'Visa application form',
          'Photograph',
          'Itinerary',
          'Certificate of Employment (or Enrollment if student)',
        ]
      },
    ],
    'Hong Kong': [
      {'title': 'Flight Ticket', 'subitems': []},
      {'title': 'Valid Passport', 'subitems': []},
      {'title': 'Proof of Accommodation', 'subitems': []},
      {'title': 'eTravel Registration (App)', 'subitems': []},
      {'title': 'Visa (No need if Philippine passport holder)', 'subitems': []},
    ],
    'South Korea': [
      {'title': 'Flight Ticket', 'subitems': []},
      {'title': 'Valid Passport', 'subitems': []},
      {'title': 'Proof of Accommodation', 'subitems': []},
      {'title': 'eTravel Registration (App)', 'subitems': []},
      {
        'title': 'Visa',
        'subitems': [
          'Visa application form',
          'Photograph',
          'Bank Certificate/Statement',
          'Certificate of Employment (or Enrollment if student)',
        ]
      },
    ],
    'Singapore': [
      {'title': 'Flight Ticket', 'subitems': []},
      {'title': 'Valid Passport', 'subitems': []},
      {'title': 'Proof of Accommodation', 'subitems': []},
      {'title': 'eTravel Registration (App)', 'subitems': []},
      {'title': 'Visa (No need if Philippine passport holder)', 'subitems': []},
      {'title': 'Singapore Arrival Card (SGAC)', 'subitems': []},
    ],
    'China': [
      {'title': 'Flight Ticket', 'subitems': []},
      {'title': 'Valid Passport', 'subitems': []},
      {'title': 'Proof of Accommodation', 'subitems': []},
      {'title': 'eTravel Registration (App)', 'subitems': []},
      {'title': 'Visa (Check embassy site for details)', 'subitems': []},
    ],
  };

  final Map<String, String> embassyLinks = {
    'Japan': 'https://www.ph.emb-japan.go.jp/itpr_en/00_000035.html',
    'South Korea': 'https://overseas.mofa.go.kr/ph-en/brd/m_3277/list.do',
    'China': 'https://bio.visaforchina.cn/MNL3_EN/qianzhengyewu/banliliucheng?id=199066352516993049',
  };

  @override
  Widget build(BuildContext context) {
    // Check if user is authenticated
    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      drawer: const UserAppDrawer(),
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
                Flexible(
                  child: const Text(
                    'Travel Requirements',
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
          // Main content
          Positioned(
            top: 20,
            left: 28,
            right: 28,
            bottom: 120,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination dropdown
                  const Text(
                    'Select Destination',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Kumbh Sans',
                      color: Color(0xFF125E77),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF348AA7), width: 2),
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedCountry,
                      items: ['Japan', 'Hong Kong', 'South Korea', 'Singapore', 'China']
                          .map((country) => DropdownMenuItem(
                                value: country,
                                child: Text(
                                  country,
                                  style: const TextStyle(
                                    fontFamily: 'Kumbh Sans',
                                    fontSize: 16,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCountry = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Requirements header
                  Text(
                    'Required Documents for $selectedCountry',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kumbh Sans',
                      color: Color(0xFF125E77),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Requirements list
                  ..._buildRequirementsList(selectedCountry),

                  // Disclaimer for countries with embassy links
                  if (embassyLinks.containsKey(selectedCountry))
                    _buildDisclaimer(selectedCountry),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Positioned(
            bottom: 20,
            left: 28,
            right: 28,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      _handleAddToChecklist();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF125E77),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Add to My Checklist',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kumbh Sans',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Handle Need Help navigation
                      },
                      child: const Text(
                        'Need Help?',
                        style: TextStyle(
                          color: Color(0xFF348AA7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Kumbh Sans',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle Send a Ticket navigation
                      },
                      child: const Text(
                        'Send a Ticket',
                        style: TextStyle(
                          color: Color(0xFF348AA7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Kumbh Sans',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddToChecklist() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to add to checklist'),
              backgroundColor: Color(0xFFA54547),
            ),
          );
        }
        return;
      }

      // Check if user already has a checklist for a different destination
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String? existingCountry;
      if (doc.exists) {
        final data = doc.data();
        final checklists = data?['checklists'] ?? {};
        if (checklists.isNotEmpty) {
          existingCountry = checklists.keys.first;
        }
      }

      // If user already has a checklist for a different country, show confirmation
      if (existingCountry != null && existingCountry != selectedCountry) {
        if (mounted) {
          final shouldProceed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Override Destination?'),
              content: Text(
                'You already have a checklist for $existingCountry.\n\n'
                'Do you want to replace it with $selectedCountry?\n\n'
                'Your $existingCountry checklist will be overwritten.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Override',
                    style: TextStyle(color: Color(0xFFA54547)),
                  ),
                ),
              ],
            ),
          );

          if (shouldProceed != true) {
            return; // User cancelled
          }
        }
      }

      // Get the requirements for the selected country
      final requirements = requirementsByCountry[selectedCountry] ?? [];
      final checklistData = <String, dynamic>{};

      // Initialize each document with pending status
      for (final req in requirements) {
        checklistData[req['title']] = {
          'status': 'pending',
          'url': '',
          'updatedAt': FieldValue.serverTimestamp(),
        };
      }

      // Save to Firestore under users/{userId}/checklists
      // This REPLACES the entire checklists map, ensuring only one destination at a time
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'checklists': {
            selectedCountry: checklistData,
          }
        });
      } catch (e) {
        // If the field doesn't exist, create it
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'checklists': {
            selectedCountry: checklistData,
          }
        }, SetOptions(merge: true));
      }

      if (mounted) {
        // Navigate to the checklist page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDocumentsChecklistPage(
              country: selectedCountry,
            ),
          ),
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checklist created! Add your documents below.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating checklist: $e'),
            backgroundColor: const Color(0xFFA54547),
          ),
        );
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link')),
        );
      }
    }
  }

  Widget _buildDisclaimer(String country) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFB8860B),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Important: Visa Requirements Disclaimer',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kumbh Sans',
                      color: Color(0xFFB8860B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'The visa requirements listed above may not be completely accurate. Please visit the official embassy website for your destination to verify the current requirements before traveling.',
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Kumbh Sans',
                color: Color(0xFF333333),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _launchURL(embassyLinks[country]!),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF348AA7),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Visit Official Embassy Site',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Kumbh Sans',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.open_in_new,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRequirementsList(String country) {
    final requirements = requirementsByCountry[country] ?? [];
    List<Widget> widgets = [];

    for (int i = 0; i < requirements.length; i++) {
      final requirement = requirements[i];
      final hasSubitems = (requirement['subitems'] as List).isNotEmpty;

      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF348AA7), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF348AA7),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Kumbh Sans',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        requirement['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Kumbh Sans',
                          color: Color(0xFF125E77),
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasSubitems) ...[
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.only(left: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final subitem in requirement['subitems'] as List)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF348AA7),
                                    fontFamily: 'Kumbh Sans',
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    subitem as String,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Kumbh Sans',
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}