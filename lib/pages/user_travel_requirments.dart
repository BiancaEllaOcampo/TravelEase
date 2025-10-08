import 'package:flutter/material.dart';


class UserTravelRequirementsPage extends StatefulWidget {
  const UserTravelRequirementsPage({super.key});

  @override
  State<UserTravelRequirementsPage> createState() => _UserTravelRequirementsPageState();
}

class _UserTravelRequirementsPageState extends State<UserTravelRequirementsPage> {
  String? selectedCountry = 'Select Country';

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

          // Header Banner
          Positioned(
            top: 48,
            left: 0,
            right: 0,
            height: 82,
            child: Container(
              color: const Color(0xFF125E77),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.menu,
                        color: Color(0xFFF3F3F3),
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

          // Content Area
          Positioned(
            top: 150,
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Destination Country:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kumbh Sans',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
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
                      selectedCountry = value;
                    });
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //Requirment Lists
          Positioned(
            top: 200,
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Required Documents',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kumbh Sans',
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Expanded(child: Container()),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle view details action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF348AA7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Add To my Checklist',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Kumbh Sans',
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),



          // Bottom Links
          Positioned(
            bottom: 52,
            left: 33,
            right: 33,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    // Handle About Us navigation
                  },
                  child: const Text(
                    'Need Help?',
                    style: TextStyle(
                      color: Color(0xFF348AA7),
                      fontSize: 25,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Kumbh Sans',
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Handle Feedback navigation
                  },
                  child: const Text(
                    'Send a Ticket',
                    style: TextStyle(
                      color: Color(0xFF348AA7),
                      fontSize: 25,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Kumbh Sans',
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
}