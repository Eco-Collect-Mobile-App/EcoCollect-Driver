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
          'Home',
          style: TextStyle(color: Colors.white),
        ),
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
              const Text(
                "HOME",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 30),
              Center(
                child: Image.asset(
                  "assets/images/man.png",
                  height: 200,
                ),
              ),
              ElevatedButton(
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
                onPressed: () {
                  // Navigate to QRCodeScanner page when the button is pressed
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
