import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../splash_screen.dart';
import 'user_homepage.dart';
import 'user_travel_requirments.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _twoFactorEnabled = true;
  bool _consentToDataProcessing = true;
  bool _isLoading = true;
  String? _profileImageUrl;

  // Controllers for form fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passportController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  final TextEditingController _visaController = TextEditingController();
  final TextEditingController _insuranceController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _preferredAirportController = TextEditingController();
  final TextEditingController _preferredLanguagesController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final User? currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        // No user logged in, redirect to login
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SplashScreen()),
            (route) => false,
          );
        }
        return;
      }

      // Get user document from Firestore
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        
        setState(() {
          // Basic information
          _fullNameController.text = data['fullName'] ?? '';
          _emailController.text = currentUser.email ?? data['email'] ?? '';
          _phoneController.text = data['phoneNumber'] ?? '';
          _addressController.text = data['address'] ?? '';
          
          // Travel documents
          _passportController.text = data['passportNumber'] ?? '';
          _expirationDateController.text = data['passportExpiration'] ?? '';
          _visaController.text = data['visaNumber'] ?? '';
          _insuranceController.text = data['insuranceProvider'] ?? '';
          
          // Additional information
          _emergencyContactController.text = data['emergencyContact'] ?? '';
          _preferredAirportController.text = data['preferredAirport'] ?? '';
          _preferredLanguagesController.text = data['preferredLanguages'] ?? '';
          
          // Security settings
          _twoFactorEnabled = data['twoFactorEnabled'] ?? false;
          _consentToDataProcessing = data['dataProcessingConsent'] ?? false;
          
          // Profile image
          _profileImageUrl = data['profileImageUrl'];
          
          _isLoading = false;
        });
      } else {
        // Document doesn't exist, create it with default values
        await _createUserProfile(currentUser);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: const Color(0xFFA54547),
          ),
        );
      }
    }
  }

  Future<void> _createUserProfile(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'fullName': '',
        'email': user.email ?? '',
        'phoneNumber': '',
        'address': '',
        'passportNumber': '',
        'passportExpiration': '',
        'visaNumber': '',
        'insuranceProvider': '',
        'emergencyContact': '',
        'preferredAirport': '',
        'preferredLanguages': '',
        'twoFactorEnabled': false,
        'dataProcessingConsent': false,
        'profileImageUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _emailController.text = user.email ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating profile: ${e.toString()}'),
            backgroundColor: const Color(0xFFA54547),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passportController.dispose();
    _expirationDateController.dispose();
    _visaController.dispose();
    _insuranceController.dispose();
    _emergencyContactController.dispose();
    _preferredAirportController.dispose();
    _preferredLanguagesController.dispose();
    super.dispose();
  }

  void _saveInformation() async {
    try {
      final User? currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to save your profile'),
            backgroundColor: Color(0xFFA54547),
          ),
        );
        return;
      }

      // Show loading indicator
      setState(() {
        _isLoading = true;
      });

      // Update user document in Firestore
      await _firestore.collection('users').doc(currentUser.uid).update({
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'passportNumber': _passportController.text.trim(),
        'passportExpiration': _expirationDateController.text.trim(),
        'visaNumber': _visaController.text.trim(),
        'insuranceProvider': _insuranceController.text.trim(),
        'emergencyContact': _emergencyContactController.text.trim(),
        'preferredAirport': _preferredAirportController.text.trim(),
        'preferredLanguages': _preferredLanguagesController.text.trim(),
        'twoFactorEnabled': _twoFactorEnabled,
        'dataProcessingConsent': _consentToDataProcessing,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile information saved successfully'),
            backgroundColor: Color(0xFF34C759),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: ${e.toString()}'),
            backgroundColor: const Color(0xFFA54547),
          ),
        );
      }
    }
  }

  void _changePassword() {
    // TODO: Implement password change logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password functionality coming soon')),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone. '
          'All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              
              try {
                final User? currentUser = _auth.currentUser;
                
                if (currentUser == null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No user logged in'),
                        backgroundColor: Color(0xFFA54547),
                      ),
                    );
                  }
                  return;
                }

                // Show loading state
                setState(() {
                  _isLoading = true;
                });

                // Delete user data from Firestore first
                await _firestore.collection('users').doc(currentUser.uid).delete();
                
                // Delete the Firebase Auth account (this automatically logs out)
                await currentUser.delete();
                
                // Explicitly sign out to ensure logout is complete
                await _auth.signOut();

                if (mounted) {
                  // Navigate to splash screen and completely clear the navigation stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const SplashScreen()),
                    (route) => false,
                  );
                  
                  // Show success message after a brief delay
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account deleted successfully. You are logged out.'),
                          backgroundColor: Color(0xFF34C759),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  });
                }
              } on FirebaseAuthException catch (e) {
                setState(() {
                  _isLoading = false;
                });
                
                String errorMessage = 'Error deleting account';
                if (e.code == 'requires-recent-login') {
                  errorMessage = 'Please log in again before deleting your account';
                }
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: const Color(0xFFA54547),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                setState(() {
                  _isLoading = false;
                });
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting account: ${e.toString()}'),
                      backgroundColor: const Color(0xFFA54547),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFA54547)),
            ),
          ),
        ],
      ),
    );
  }

  void _changeProfilePicture() {
    // TODO: Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture change coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                const Flexible(
                  child: Text(
                    'My Profile',
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
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFD9D9D9),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF348AA7),
                ),
              ),
            ),

          // Scrollable content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 14),
                    
                    // Profile Picture Section
                    Stack(
                      children: [
                        Container(
                          width: 114,
                          height: 113,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF348AA7),
                              width: 3,
                            ),
                            image: DecorationImage(
                              image: _profileImageUrl != null
                                  ? NetworkImage(_profileImageUrl!)
                                  : const NetworkImage('https://via.placeholder.com/114'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _changeProfilePicture,
                            child: Container(
                              width: 33,
                              height: 33,
                              decoration: const BoxDecoration(
                                color: Color(0xFF348AA7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 23),

                    // Personal Information Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 38),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Personal Information',
                                style: TextStyle(
                                  color: Color(0xFF125E77),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Kumbh Sans',
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Full Name and Email
                              _buildDoubleField(
                                label1: 'Full Name',
                                controller1: _fullNameController,
                                label2: 'Email Address',
                                controller2: _emailController,
                                height: 58,
                              ),

                              const SizedBox(height: 6),

                              // Phone Number
                              _buildSingleField(
                                label: 'Phone Number',
                                controller: _phoneController,
                                height: 48,
                              ),

                              const SizedBox(height: 6),

                              // Address
                              _buildSingleField(
                                label: 'Address',
                                controller: _addressController,
                                height: 52,
                              ),

                              const SizedBox(height: 6),

                              // Passport Number and Expiration Date
                              Row(
                                children: [
                                  Expanded(
                                    flex: 151,
                                    child: _buildFieldBox(
                                      label: 'Passport Number',
                                      controller: _passportController,
                                      height: 44,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    flex: 165,
                                    child: _buildFieldBox(
                                      label: 'Expiration Date',
                                      controller: _expirationDateController,
                                      height: 44,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // Visa Type and Travel Insurance
                              _buildDoubleFieldTall(
                                label1: 'Visa Type/Number',
                                controller1: _visaController,
                                label2: 'Travel Insurance Provider',
                                controller2: _insuranceController,
                              ),

                              const SizedBox(height: 11),

                              // Emergency Contact and Preferred Airport
                              Row(
                                children: [
                                  Expanded(
                                    flex: 151,
                                    child: _buildFieldBox(
                                      label: 'Emergency Contact',
                                      controller: _emergencyContactController,
                                      height: 44,
                                    ),
                                  ),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    flex: 159,
                                    child: _buildFieldBox(
                                      label: 'Preferred Airport',
                                      controller: _preferredAirportController,
                                      height: 44,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 9),

                              // Preferred Languages
                              _buildLanguageField(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 23),

                    // Security Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 38),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Security',
                                style: TextStyle(
                                  color: Color(0xFF125E77),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Kumbh Sans',
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Change Password Button
                              SizedBox(
                                width: double.infinity,
                                height: 25,
                                child: ElevatedButton(
                                  onPressed: _changePassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF125E77),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text(
                                    'Change Password',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontFamily: 'Kumbh Sans',
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Two-Factor Authentication Toggle
                              Container(
                                height: 31,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Enable Two-Factor Authentication',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Kumbh Sans',
                                        ),
                                      ),
                                      Transform.scale(
                                        scale: 0.7,
                                        child: Switch(
                                          value: _twoFactorEnabled,
                                          onChanged: (value) {
                                            setState(() {
                                              _twoFactorEnabled = value;
                                            });
                                            // TODO: Implement 2FA toggle
                                          },
                                          activeColor: Colors.white,
                                          activeTrackColor: const Color(0xFF34C759),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Data Processing Consent Checkbox
                              Container(
                                height: 31,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      Transform.scale(
                                        scale: 0.9,
                                        child: Checkbox(
                                          value: _consentToDataProcessing,
                                          onChanged: (value) {
                                            setState(() {
                                              _consentToDataProcessing = value ?? false;
                                            });
                                            // TODO: Handle consent change
                                          },
                                          activeColor: const Color(0xFF2C2C2C),
                                          checkColor: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'I consent to data processing',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Kumbh Sans',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Delete Account Link
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: _deleteAccount,
                                  child: const Text(
                                    'Delete Account',
                                    style: TextStyle(
                                      color: Color(0xFF125E77),
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
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

                    const SizedBox(height: 16),

                    // Save Information Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 39),
                      child: SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _saveInformation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF34C759),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text(
                            'Save Information',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Kumbh Sans',
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleField({
    required String label,
    required TextEditingController controller,
    required double height,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Kumbh Sans',
              ),
            ),
            const SizedBox(height: 3),
            TextField(
              controller: controller,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Kumbh Sans',
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoubleField({
    required String label1,
    required TextEditingController controller1,
    required String label2,
    required TextEditingController controller2,
    required double height,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label1,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                  const SizedBox(height: 3),
                  TextField(
                    controller: controller1,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Kumbh Sans',
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label2,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                  const SizedBox(height: 3),
                  TextField(
                    controller: controller2,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Kumbh Sans',
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldBox({
    required String label,
    required TextEditingController controller,
    required double height,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Kumbh Sans',
              ),
            ),
            const SizedBox(height: 3),
            TextField(
              controller: controller,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Kumbh Sans',
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoubleFieldTall({
    required String label1,
    required TextEditingController controller1,
    required String label2,
    required TextEditingController controller2,
  }) {
    return Container(
      height: 54,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label1,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: controller1,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Kumbh Sans',
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label2,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: controller2,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Kumbh Sans',
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageField() {
    return Container(
      height: 30,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Preferred Language/s:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Kumbh Sans',
              ),
            ),
            Expanded(
              child: TextField(
                controller: _preferredLanguagesController,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Kumbh Sans',
                ),
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TravelEase Drawer Menu (copied from template)
class TravelEaseDrawer extends StatelessWidget {
  const TravelEaseDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 310,
      backgroundColor: const Color(0xFF125E77),
      child: SafeArea(
        child: Column(
          children: [
            // Header with logo and title
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                children: [
                  // Menu Icon/Button
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the drawer when pressed
                    },
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 50,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),

                  const SizedBox(width: 16),

                  // Text Title
                  const Text(
                    'TravelEase',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            const Divider(color: Colors.white24, height: 1),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    'Home',
                    Icons.home_outlined,
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserHomePage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'My Profile',
                    Icons.person_outline,
                    () {
                      Navigator.pop(context);
                      // Already on profile page
                    },
                    badgeCount: 3,
                  ),
                  _buildMenuItem(
                    context,
                    'Travel Requirements',
                    Icons.flight_takeoff,
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const UserTravelRequirementsPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'View My Documents',
                    Icons.folder_open_outlined,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to documents
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Announcements',
                    Icons.campaign_outlined,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to announcements
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Feedback',
                    Icons.feedback_outlined,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to feedback
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Support',
                    Icons.help_outline,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to support
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Settings',
                    Icons.settings_outlined,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to settings
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Privacy Policy',
                    Icons.privacy_tip_outlined,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to privacy policy
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Terms of Service',
                    Icons.description_outlined,
                    () {
                      Navigator.pop(context);
                      // TODO: Navigate to terms
                    },
                  ),
                ],
              ),
            ),

            // Log Out Button at bottom
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await FirebaseAuth.instance.signOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logout failed')),
                      );
                    }

                    // Return to splash and clear navigation history
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SplashScreen()),
                      (route) => false,
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    int? badgeCount,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: 35,
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              softWrap: true,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Kumbh Sans',
              ),
            ),
          ),
          if (badgeCount != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Kumbh Sans',
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
