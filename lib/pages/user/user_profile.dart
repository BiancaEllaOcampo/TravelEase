import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../splash_screen.dart';
import '../../utils/user_app_drawer.dart';

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
                    const SizedBox(height: 16),
                    
                    // Profile Picture Section with improved design
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF348AA7), Color(0xFF125E77)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF125E77).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: _profileImageUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        _profileImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.person,
                                            size: 80,
                                            color: Color(0xFF348AA7),
                                          );
                                        },
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.person,
                                        size: 80,
                                        color: Color(0xFF348AA7),
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: _changeProfilePicture,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF348AA7),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Personal Information Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF125E77).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.person_outline,
                                      color: Color(0xFF125E77),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Personal Information',
                                    style: TextStyle(
                                      color: Color(0xFF125E77),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Kumbh Sans',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Full Name and Email
                              _buildDoubleField(
                                label1: 'Full Name',
                                controller1: _fullNameController,
                                label2: 'Email Address',
                                controller2: _emailController,
                                height: 68,
                              ),

                              const SizedBox(height: 12),

                              // Phone Number
                              _buildSingleField(
                                label: 'Phone Number',
                                controller: _phoneController,
                                height: 58,
                                icon: Icons.phone_outlined,
                              ),

                              const SizedBox(height: 12),

                              // Address
                              _buildSingleField(
                                label: 'Address',
                                controller: _addressController,
                                height: 58,
                                icon: Icons.location_on_outlined,
                              ),

                              const SizedBox(height: 12),

                              // Passport Number and Expiration Date
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFieldBox(
                                      label: 'Passport Number',
                                      controller: _passportController,
                                      height: 58,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildFieldBox(
                                      label: 'Expiration Date',
                                      controller: _expirationDateController,
                                      height: 58,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Visa Type and Travel Insurance
                              _buildDoubleFieldTall(
                                label1: 'Visa Type/Number',
                                controller1: _visaController,
                                label2: 'Travel Insurance Provider',
                                controller2: _insuranceController,
                              ),

                              const SizedBox(height: 12),

                              // Emergency Contact and Preferred Airport
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFieldBox(
                                      label: 'Emergency Contact',
                                      controller: _emergencyContactController,
                                      height: 58,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildFieldBox(
                                      label: 'Preferred Airport',
                                      controller: _preferredAirportController,
                                      height: 58,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Preferred Languages
                              _buildLanguageField(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Security Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF125E77).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.security_outlined,
                                      color: Color(0xFF125E77),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Security',
                                    style: TextStyle(
                                      color: Color(0xFF125E77),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Kumbh Sans',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Change Password Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: _changePassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF125E77),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  icon: const Icon(
                                    Icons.lock_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'Change Password',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Kumbh Sans',
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Two-Factor Authentication Toggle
                              Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _twoFactorEnabled
                                              ? const Color(0xFF34C759).withOpacity(0.1)
                                              : Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          Icons.verified_user_outlined,
                                          color: _twoFactorEnabled
                                              ? const Color(0xFF34C759)
                                              : Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'Two-Factor Authentication',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Kumbh Sans',
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value: _twoFactorEnabled,
                                        onChanged: (value) {
                                          setState(() {
                                            _twoFactorEnabled = value;
                                          });
                                          // TODO: Implement 2FA toggle
                                        },
                                        activeColor: const Color(0xFF34C759),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Data Processing Consent Checkbox
                              Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _consentToDataProcessing
                                              ? const Color(0xFF125E77).withOpacity(0.1)
                                              : Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          Icons.privacy_tip_outlined,
                                          color: _consentToDataProcessing
                                              ? const Color(0xFF125E77)
                                              : Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'I consent to data processing',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Kumbh Sans',
                                          ),
                                        ),
                                      ),
                                      Checkbox(
                                        value: _consentToDataProcessing,
                                        onChanged: (value) {
                                          setState(() {
                                            _consentToDataProcessing = value ?? false;
                                          });
                                          // TODO: Handle consent change
                                        },
                                        activeColor: const Color(0xFF125E77),
                                        checkColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Delete Account Link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: _deleteAccount,
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Color(0xFFA54547),
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Delete Account',
                                    style: TextStyle(
                                      color: Color(0xFFA54547),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
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

                    const SizedBox(height: 24),

                    // Save Information Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _saveInformation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF34C759),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            shadowColor: const Color(0xFF34C759).withOpacity(0.3),
                          ),
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                          label: const Text(
                            'Save Information',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Kumbh Sans',
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
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
    IconData? icon,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: 'Kumbh Sans',
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: controller,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Kumbh Sans',
                fontWeight: FontWeight.w500,
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
      constraints: BoxConstraints(minHeight: height),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label1,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kumbh Sans',
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: controller1,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kumbh Sans',
                        fontWeight: FontWeight.w500,
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
              Container(
                width: 1,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label2,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kumbh Sans',
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: controller2,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kumbh Sans',
                        fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildFieldBox({
    required String label,
    required TextEditingController controller,
    required double height,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: 'Kumbh Sans',
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: controller,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Kumbh Sans',
                fontWeight: FontWeight.w500,
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
      constraints: const BoxConstraints(minHeight: 68),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label1,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kumbh Sans',
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: controller1,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kumbh Sans',
                        fontWeight: FontWeight.w500,
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
              Container(
                width: 1,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label2,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kumbh Sans',
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: controller2,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Kumbh Sans',
                        fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildLanguageField() {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Preferred Language/s:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: 'Kumbh Sans',
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _preferredLanguagesController,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Kumbh Sans',
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: 'e.g., English, Spanish',
                  hintStyle: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

