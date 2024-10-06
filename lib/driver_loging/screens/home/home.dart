import 'package:eco_collect/driver_loging/screens/home/profile.dart';
import 'package:flutter/material.dart';
import 'package:eco_collect/pages/qr_code_scanner.dart';
import 'package:eco_collect/pages/all_requests.dart';

class Home extends StatelessWidget {
  final String driverId;

  const Home({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XffE7EBE8),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0Xff27AE60),
        actions: [
          ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Color(0Xff27AE60)),
            ),
            onPressed: () async {
              Navigator.pop(context);
            },
            child: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Center(
                child: Image.asset(
                  "assets/images/man.png",
                  height: 200,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0Xff27AE60), // Green color
                  foregroundColor: Colors.white, // White text color
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(driverId: driverId)),
                  );
                },
                child: const Text("Go to Profile"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0Xff27AE60), // Green color
                  foregroundColor: Colors.white, // White text color
                ),
                onPressed: () {
                  // Navigate to QRCodeScanner page when the button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QRCodeScanner(),
                    ),
                  );
                },
                child: const Text('Go to QR Code Scanner'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0Xff27AE60), // Green color
                  foregroundColor: Colors.white, // White text color
                ),
                onPressed: () {
                  // Navigate to PickupReqHistory page when the button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickupReqHistory(),
                    ),
                  );
                },
                child: const Text('All Requests'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
