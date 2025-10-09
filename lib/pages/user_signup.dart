import 'package:flutter/material.dart';

class UserSignupPage extends StatefulWidget {
  const UserSignupPage({super.key});

  @override
  State<UserSignupPage> createState() => _UserSignupPageState();
}

class _UserSignupPageState extends State<UserSignupPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
          
          // Back Button
          Positioned(
            top: 150,
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
            top: 225,
            left: 30,
            right: 30,
            child: Container(
              height: 625,
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
                                    hintText: 'Jonathan House',
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
                                    hintText: 'De Guzman',
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
                              hintText: 'dr.house@gmail.com',
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
                    
                    // Mobile Number Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mobile Number',
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
                            controller: _mobileController,
                            decoration: const InputDecoration(
                              hintText: '+63 090890742186',
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontFamily: 'Kumbh Sans',
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                            ),
                            keyboardType: TextInputType.phone,
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
                              hintText: '********************',
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
                    
                    const SizedBox(height: 25),
                    
                    // Create Account Button
                    SizedBox(
                      width: 238,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle signup logic
                          _handleSignup();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF348AA7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
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
    
    if (_mobileController.text.isEmpty) {
      _showSnackBar('Please enter your mobile number');
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
    
    // TODO: Implement actual signup logic here
    // For now, just show a success message
    _showSnackBar('Account created successfully!');
    
    // Navigate to login page or homepage
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserLoginPage()));
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