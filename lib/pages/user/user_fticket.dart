import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../splash_screen.dart';

class FlightTicketPage extends StatefulWidget {
  const FlightTicketPage({super.key});

  @override
  State<FlightTicketPage> createState() => _FlightTicketPageState();
}

class _FlightTicketPageState extends State<FlightTicketPage> {
  String passengerName = '';
  String airline = '';
  String departure = '';
  String arrival = '';
  String bookingCode = '';
  String feedbackNote = '';
  String ticketStatus = '';

  @override
  void initState() {
    super.initState();
    _loadTicketData();
  }

  void _loadTicketData() {
    setState(() {
      passengerName = 'Jonathan Mouse';
      airline = 'ABC Airlines VX202';
      departure = 'May 30, 2023 9:15 AM';
      arrival = 'LAX / May 30, 2023 4:30 PM';
      bookingCode = 'ABC123';
      feedbackNote = 'Mismatch in passenger name';
      ticketStatus = 'Needs Correction';
    });
  }

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

    const primary = Color(0xFF125E77);
    const accent = Color(0xFF348AA7);
    const danger = Color(0xFFC63F3F);

    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: Container(
          color: primary,
          padding: const EdgeInsets.only(top: 65, left: 20, right: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 35),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const Text(
                'Flight Ticket',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Kumbh Sans',
                ),
              ),
              Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                ),
                child: const Icon(
                  Icons.airplanemode_active,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),

      // Added Stack to anchor footer
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 55,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'Extracted Data',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Kumbh Sans',
                            ),
                          ),

                          const SizedBox(height: 15),

                          _buildDataRow('Passenger:', passengerName),
                          _buildDataRow('Airline:', airline),
                          _buildDataRow('Departure Airport:', departure),
                          _buildDataRow('Arrival Airport:', arrival),
                          _buildDataRow('Booking Code:', bookingCode),

                          const Divider(height: 26, color: Colors.black26),

                          Text(
                            'AI Feedback: $feedbackNote',
                            style: const TextStyle(
                              fontFamily: 'Kumbh Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: () => _reuploadTicket(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Re-upload Ticket',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Kumbh Sans',
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () => _viewOriginalDocument(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: accent, width: 1.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'View Original Document',
                                style: TextStyle(
                                  color: Color(0xFFC8B3B3),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Kumbh Sans',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),


                    Positioned(
                      top: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: danger,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Text(
                          ticketStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Kumbh Sans',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 150), // space before footer
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 25,
            right: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _needHelp(context),
                  child: const Text(
                    'Need Help?',
                    style: TextStyle(
                      color: Color(0xFF125E77),
                      fontSize: 20,
                      fontFamily: 'Kumbh Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _sendTicket(context),
                  child: const Text(
                    'Send a Ticket',
                    style: TextStyle(
                      color: Color(0xFF125E77),
                      fontSize: 20,
                      fontFamily: 'Kumbh Sans',
                      fontWeight: FontWeight.w600,
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

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Kumbh Sans',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontFamily: 'Kumbh Sans'),
            ),
          ),
        ],
      ),
    );
  }

  void _reuploadTicket(BuildContext ctx) => ScaffoldMessenger.of(ctx)
      .showSnackBar(const SnackBar(content: Text('Re-upload ticket triggered')));

  void _viewOriginalDocument(BuildContext ctx) =>
      ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('View original document')));

  void _needHelp(BuildContext ctx) => ScaffoldMessenger.of(ctx)
      .showSnackBar(const SnackBar(content: Text('Open help/support')));

  void _sendTicket(BuildContext ctx) =>
      ScaffoldMessenger.of(ctx)
          .showSnackBar(const SnackBar(content: Text('Ticket submitted')));
}
