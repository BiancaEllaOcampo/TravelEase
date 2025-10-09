import 'package:flutter/material.dart';

class UserTravelRequirementsPage extends StatefulWidget {
  const UserTravelRequirementsPage({super.key});

  @override
  State<UserTravelRequirementsPage> createState() => _UserTravelRequirementsPageState();
}

class _UserTravelRequirementsPageState extends State<UserTravelRequirementsPage> {
  String selectedCountry = 'Japan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Text(
                  'Travel Requirements',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kumbh Sans',
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
          // Destination
          Positioned(
            top: 20, // Reduced gap - was 150 - 48, now properly positioned after AppBar
            left: 28,
            right: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Destination',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Kumbh Sans',
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedCountry,
                    items: const [
                      DropdownMenuItem(value: 'Japan', child: Text('Japan')),
                      DropdownMenuItem(value: 'USA', child: Text('USA')),
                      DropdownMenuItem(value: 'France', child: Text('France')),
                      DropdownMenuItem(value: 'Poland', child: Text('Poland')),
                      DropdownMenuItem(value: 'Germany', child: Text('Germany')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCountry = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lists (Empty for now)
          Positioned(
            top: 250 - 48, // Adjust for removed banner offset
            left: 28,
            right: 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Required Documents',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Kumbh Sans',
                              color: Color(0xFF125E77),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            height: 2,
                            color: Colors.grey.shade200,
                            margin: const EdgeInsets.only(bottom: 8),
                          ),
                        ],
                      ),
                      // Empty lists
                      const SizedBox(height: 80),
                    ],
                  ),
                ),

                // Button 
                SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      _handleAddToChecklist();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF125E77),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Add to My Checklist',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kumbh Sans',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Links
          Positioned(
            bottom: 32,
            left: 33,
            right: 33,
            child: Row(
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
                      fontSize: 18,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Kumbh Sans',
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddToChecklist() {
    // Do nothing for now
  }
}