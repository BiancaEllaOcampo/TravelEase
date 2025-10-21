import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../splash_screen.dart';
import '../../utils/master_app_drawer.dart';

class MasterProfilePage extends StatefulWidget {
  const MasterProfilePage({super.key});

  @override
  State<MasterProfilePage> createState() => _MasterProfilePageState();
}

class _MasterProfilePageState extends State<MasterProfilePage> {
  bool _twoFactorEnabled = false;
  bool _consentToDataProcessing = false;
  bool _isLoading = true;
  String? _profileImageUrl;

  // Controllers for form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadProfile();
  }

  Future<void> _checkAuthAndLoadProfile() async {
    final currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      // User is not logged in, redirect to splash screen
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
        );
      }
      return;
    }

    // Load the profile
    await _loadMasterProfile();
  }

  Future<void> _loadMasterProfile() async {
    try {
      final User? currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        // No user logged in, redirect to splash screen
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SplashScreen()),
            (route) => false,
          );
        }
        return;
      }

      debugPrint('Current User UID: ${currentUser.uid}');
      debugPrint('Current User Email: ${currentUser.email}');

      // Try to find master document by Auth UID first
      DocumentSnapshot masterDoc = await _firestore
          .collection('master')
          .doc(currentUser.uid)
          .get();

      debugPrint('Master doc by UID exists: ${masterDoc.exists}');

      // If not found by UID, search by email
      if (!masterDoc.exists) {
        debugPrint('Searching master by email...');
        final querySnapshot = await _firestore
            .collection('master')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          masterDoc = querySnapshot.docs.first;
          debugPrint('Found master doc by email: ${masterDoc.id}');
        } else {
          debugPrint('No master document found for this user');
          // Not a master account, redirect to splash screen
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Master account not found. Please contact administrator.'),
                backgroundColor: Color(0xFFA54547),
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
              (route) => false,
            );
          }
          return;
        }
      }

      if (masterDoc.exists) {
        final data = masterDoc.data() as Map<String, dynamic>;
        
        debugPrint('Master data: $data');
        
        setState(() {
          // Basic information
          _firstNameController.text = data['first_name'] ?? '';
          _lastNameController.text = data['last_name'] ?? '';
          _emailController.text = data['email'] ?? currentUser.email ?? '';
          _userIdController.text = currentUser.uid;
          
          // Security settings
          _twoFactorEnabled = data['twoFactorEnabled'] ?? false;
          _consentToDataProcessing = data['dataProcessingConsent'] ?? false;
          
          // Profile image
          _profileImageUrl = data['profileImageUrl'];
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _userIdController.dispose();
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

      // Update master document in Firestore
      await _firestore.collection('master').doc(currentUser.uid).update({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
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
          'Are you sure you want to delete your master account? This action cannot be undone. '
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

                // Delete master data from Firestore first
                await _firestore.collection('master').doc(currentUser.uid).delete();
                
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

  void _changeProfilePicture() async {
    try {
      // Show dialog to choose between camera or gallery
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Change Profile Picture',
              style: TextStyle(fontFamily: 'Kumbh Sans'),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFF348AA7)),
                  title: const Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF348AA7)),
                  title: const Text('Take a Photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );

      if (source == null) return;

      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Show loading
      setState(() {
        _isLoading = true;
      });

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Create a reference to the storage location
      final String fileName = 'profile_${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage
          .ref()
          .child('master_profiles')
          .child(currentUser.uid)
          .child(fileName);

      // Upload file
      final File file = File(pickedFile.path);
      final UploadTask uploadTask = storageRef.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': currentUser.uid,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update Firestore with new profile image URL
      await _firestore.collection('master').doc(currentUser.uid).update({
        'profileImageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      setState(() {
        _profileImageUrl = downloadUrl;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully'),
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
            content: Text('Error updating profile picture: ${e.toString()}'),
            backgroundColor: const Color(0xFFA54547),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is still logged in
    final currentUser = _auth.currentUser;
    
    if (currentUser == null) {
      // User is not logged in, redirect to splash screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
        );
      });
      
      // Return a loading screen while navigating
      return Scaffold(
        body: Container(
          color: const Color(0xFFD9D9D9),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF348AA7),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      drawer: const MasterAppDrawer(),
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
                    'Master Profile',
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
                    
                    // Profile Picture Section
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
                              decoration: const BoxDecoration(
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
                                            Icons.admin_panel_settings,
                                            size: 80,
                                            color: Color(0xFF348AA7),
                                          );
                                        },
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.admin_panel_settings,
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

                    // Display Full Name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        '${_firstNameController.text} ${_lastNameController.text}'.trim().isEmpty
                            ? 'Master Admin'
                            : '${_firstNameController.text} ${_lastNameController.text}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Kumbh Sans',
                          color: Color(0xFF125E77),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Display Email
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        _emailController.text,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Kumbh Sans',
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Master Information Card
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
                                      Icons.admin_panel_settings_outlined,
                                      color: Color(0xFF125E77),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Master Information',
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

                              // First Name and Last Name
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFieldBox(
                                      label: 'First Name',
                                      controller: _firstNameController,
                                      height: 58,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildFieldBox(
                                      label: 'Last Name',
                                      controller: _lastNameController,
                                      height: 58,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Email Address
                              _buildSingleField(
                                label: 'Email Address',
                                controller: _emailController,
                                height: 58,
                                icon: Icons.email_outlined,
                              ),

                              const SizedBox(height: 12),

                              // User ID (Read-only)
                              _buildSingleField(
                                label: 'User ID',
                                controller: _userIdController,
                                height: 58,
                                icon: Icons.badge_outlined,
                                readOnly: true,
                              ),
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
    bool readOnly = false,
  }) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
      width: double.infinity,
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey.shade100 : const Color(0xFFF8F9FA),
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
              readOnly: readOnly,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Kumbh Sans',
                fontWeight: FontWeight.w500,
                color: readOnly ? Colors.grey.shade600 : Colors.black,
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
}