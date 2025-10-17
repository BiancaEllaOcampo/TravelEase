import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_homepage.dart';

class UserSignupPage extends StatefulWidget {
  const UserSignupPage({super.key});

  @override
  State<UserSignupPage> createState() => _UserSignupPageState();
}

class _UserSignupPageState extends State<UserSignupPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          height: 130,
          color: const Color(0xFF125E77),
          child: Padding(
            padding: const EdgeInsets.only(top: 48, left: 24, right: 24),
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
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFD9D9D9),
          ),
          
          // Back Button
          Positioned(
            top: 50,
            left: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),
          
          // Main Signup Card
          Positioned(
            top: 125,
            left: 30,
            right: 30,
            child: Container(
              height: 560,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    
                    // Title
                    const Text(
                      'Create an Account',
                      style: TextStyle(
                        color: Color(0xFF125E77),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kumbh Sans',
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // First Name and Last Name Row
                    Row(
                      children: [
                        // First Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'First name',
                                style: TextStyle(
                                  color: Color(0xFF125E77),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Kumbh Sans',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 49,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: TextField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(
                                    hintText: '',
                                    hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontFamily: 'Kumbh Sans',
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Last Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Last name',
                                style: TextStyle(
                                  color: Color(0xFF125E77),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Kumbh Sans',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 49,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: TextField(
                                  controller: _lastNameController,
                                  decoration: const InputDecoration(
                                    hintText: '',
                                    hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontFamily: 'Kumbh Sans',
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Email Address Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email Address',
                          style: TextStyle(
                            color: Color(0xFF125E77),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kumbh Sans',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 49,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: '',
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Kumbh Sans',
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Password Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Password',
                          style: TextStyle(
                            color: Color(0xFF125E77),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kumbh Sans',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 49,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: '',
                              hintStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Kumbh Sans',
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Create Account Button
                    SizedBox(
                      width: 238,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _handleSignup(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF348AA7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Create Account',
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
          
        ],
      ),
    );
  }

  void _handleSignup() {
    // Validate input
    if (_firstNameController.text.isEmpty) {
      _showSnackBar('Please enter your first name');
      return;
    }
    
    if (_lastNameController.text.isEmpty) {
      _showSnackBar('Please enter your last name');
      return;
    }
    
    if (_emailController.text.isEmpty) {
      _showSnackBar('Please enter your email address');
      return;
    }
    
    
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Please enter a password');
      return;
    }
    
    // Basic email validation
    if (!_emailController.text.contains('@')) {
      _showSnackBar('Please enter a valid email address');
      return;
    }
    
    // Basic password validation
    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters long');
      return;
    }
    _performFirebaseSignup();
  }

  Future<void> _performFirebaseSignup() async {
    setState(() => _isLoading = true);
    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;
      
      // Create user account
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Update display name (first + last)
      final displayName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      await userCredential.user?.updateDisplayName(displayName);

      // Create user profile in Firestore
      if (userCredential.user != null) {
        await firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': displayName,
          'email': _emailController.text.trim(),
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
      }

      _showSnackBar('Account created successfully!');

      // Navigate to user homepage (replace stack)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserHomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      var message = 'Signup failed. Please try again.';
      if (e.code == 'email-already-in-use') {
        message = 'Email already in use. Try logging in or use another email.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      }
      _showSnackBar(message);
    } catch (e) {
      _showSnackBar('An unexpected error occurred: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}